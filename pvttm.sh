#!/bin/ksh
#
# @(#) PulseChain Validator Backlog Time to Maturity Forecasting
# $Id: pvttm.sh,v 1.13 2024/06/02 13:47:15 gloor Exp $
# 01/Jun/2024 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
#
# DEPENDENCIES: 
#   ksh, curl, jq, awk (mawk or gawk), bc (apt-get install <...>)
#   bash/sh - change shebang header to sh or bash if you can't take the heat in the kitchen
#
# INSTALLATION: 
#   set exec flag: chmod +x pvttm.sh (or set perm to 750/754/755)
#   In config section below, choose the suitable BEACON address

# ---- begin of config section -------------------------------------------------

# Global settings
# Note: In case PulseChain beacon is down or not updating, use alternative beacons
#       for example G4MM4's beacon node (don't forget to tip g4mm4.io)
#
#BEACON="https://beacon.pulsechain.com/api/v1/validator/"
BEACON="https://rpc-pulsechain.g4mm4.io/beacon-api/eth/v1/beacon/states/head/validators?id="

# ---- end of config section ---------------------------------------------------

echo "PulseChain Validator Backlog Time To Maturity Forecasting"    # Header
echo "\$Id: pvttm.sh,v 1.13 2024/06/02 13:47:15 gloor Exp $"  # RCS rev control tag
echo "written by Marc O. Gloor <marc.gloor@u.nus.edu>"              # Author's note
echo ""

echo -n "Validator ID (5-digit): " 
 read VALIDATORID

echo -n "Current avg PLS payoff per attestation: "
 read AVGPLSPAYOFF

# Set beacon URL
BEACON_URL="$BEACON$VALIDATORID"

# Display summary 
# Validator Balance / use cmd-line arg $1 as validator-ID
VALBALANCE=$(curl -s -X GET "$BEACON_URL" -H "accept: application/json" | jq | grep "\"balance\":" | tr -d "\""  | awk -F: '{printf "%.0f\n", $2 / 1000000000}' )

if [ $VALBALANCE -lt 32000000 ]; then  # quick validation if validator is lagging or not
     echo 
  else
     echo "Your validator is not lagging and above the 32m baseline. All good."
     exit 0
fi

# Validator backlog / balance lagging behind
VALBACKLOG=`expr \( 32000000 - $VALBALANCE \)` 

# PLS recovery rate per day using the given avg attestation in cmd-line arg $2
VALPLSRECPERDAY=$(echo "scale=2; ($AVGPLSPAYOFF * 270)"|bc)

# Recovery TTM (Time to Maturity) in hours (decimal)
VALRECTIMEHOURS=$(echo "scale=2; ($VALBACKLOG / $AVGPLSPAYOFF * 320 / 3600 )"|bc)

# Recovery TTM (Time to Maturity) in days (decimal)
VALRECTIMEDAYS=$(echo "scale=2; ($VALRECTIMEHOURS / 24 )"|bc)

# Forecasted TTM date where PLS balance equals 32m
VALRECDATE=$(date -d "+$(echo $VALRECTIMEHOURS | awk '{printf "%d hours %d minutes", $1, ($1-int($1))*60}')" +"%d-%b-%Y %H:%M")

echo "-----------------------------------------------------"
echo -n "Validator ID                      : " ; echo $VALIDATORID
echo -n "Validator Balance                 : " ; echo $VALBALANCE
echo -n "PLS Backlog                       : " ; echo $VALBACKLOG
echo -n "Avg PLS Payoff per attestation    : " ; echo $AVGPLSPAYOFF
echo -n "PLS recovery rate per day         : " ; echo $VALPLSRECPERDAY
echo -n "Estimated recovery time in hours  : " ; echo $VALRECTIMEHOURS
echo -n "Estimated recovery time in days   : " ; echo $VALRECTIMEDAYS
echo -n "Validator Time to Maturity        : " ; echo $VALRECDATE
echo "-----------------------------------------------------"

exit $EXIT
