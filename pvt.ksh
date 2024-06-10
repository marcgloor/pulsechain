#!/bin/ksh
#
# @(#) PulseChain Validator Telemetry (pvt.ksh)
# $Id: pvt.ksh,v 1.24 2024/06/10 09:52:21 root Exp $
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
#   bash/sh - change shebang to sh or bash and modify script accordingly
#             in case you need bash for your convenience
#
# INSTALLATION:
#   set exec flag: chmod +x pvt.ksh (or chmod to 750/754/755)
#   In config section below, choose the suitable BEACON address
#
# TODO:
# Add multiple validators (interactive and commandline)
# Increase interoperability, migrate code to Python
# WhatsApp push module
# Telegram push module
#

# ---- begin config section -------------------------------------------------

# Global settings
# Note: In case PulseChain beacon is down or not updating, use alternative beacons
#       for example G4MM4's RPC-JSON API Endpoint (don't forget to tip g4mm4.io)
#
#BEACON="https://beacon.pulsechain.com/api/v1/validator/"
BEACON="https://rpc-pulsechain.g4mm4.io/beacon-api/eth/v1/beacon/states/head/validators?id="

# ---- end config section ---------------------------------------------------

# Set cmd-line args if non-interactive mode (-q) has been requested
VALIDATORID=$2
AVGPLSPAYOFF=$3

# Set report date
QUERYDATE=$(date "+%d-%b-%Y %H:%M:%S")

# Perform validator calculations module
function query_balances { 
	# Validator backlog / balance lagging behind
	VALBACKLOG=`expr \( 32000000 - $VALBALANCE \)`

	# PLS recovery rate per day using the given avg attestation in cmd-line arg $2
	VALPLSRECPERDAY=$(echo "scale=2; ($AVGPLSPAYOFF * 270)"|bc)

	# Recovery TTM (Time to Maturity) in hours (decimal)
	VALRECTIMEHOURS=$(echo "scale=2; ($VALBACKLOG / $AVGPLSPAYOFF * 320 / 3600 )"|bc)

	# Recovery TTM (Time to Maturity) in days (decimal)
	VALRECTIMEDAYS=$(echo "scale=2; ($VALRECTIMEHOURS / 24 )"|bc)

	# Forecasted TTM date where PLS balance equals 32m
	VALRECDATE=$(date -d "+$(echo $VALRECTIMEHOURS | awk '{printf "%d hours %d minutes", \
                   $1, ($1-int($1))*60}')" +"%d-%b-%Y %H:%M")
}

# Interactive function module
function interactive_cfg {
	echo -n "Validator ID (5-digit): "
	read VALIDATORID
	BEACON_URL="$BEACON$VALIDATORID" # Set beacon URL
	echo -n "Current avg PLS payoff per attestation: "
	read AVGPLSPAYOFF

	if [ -z "$VALIDATORID" ] || [ -z "$AVGPLSPAYOFF" ]; then
		echo "  Error: No metric(s) provided. Please start over again."
		exit 1
	fi

	entry_check
}

# Check if cmdline args $2 and $3 have been provided and set beacon URL
function query_beacon {
	if [ -z "$VALIDATORID" ] || [ -z "$AVGPLSPAYOFF" ]; then
		echo "  Error: -q option implies two subsequent arguments"
		echo "  Example: pvt.ksh -q <Validator-ID> <Avg-PLS-Attestation-Rate>"
		exit 1
	fi
 
	# Set beacon URL
	BEACON_URL="$BEACON$VALIDATORID"
	entry_check
}

# Validator Balance / use cmd-line arg $1 as validator-ID
function entry_check {
        # Check package/commands dependencies are met
        check_commands

        VALBALANCE=$(curl -s -X GET "$BEACON_URL" -H "accept: application/json" | jq | grep "\"balance\":" |\
                   tr -d "\""  | awk -F: '{printf "%.0f\n", $2 / 1000000000}' )
        PLSPRICE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=pulsechain&vs_currencies=usd" \
                     | jq -r ".pulsechain.usd" | xargs printf "%.6f\n")  
	VALMRKTSTKVAL=$(echo "scale=2; ($PLSPRICE * 32000000 )"|bc|  awk -F: '{printf "%.0f$\n", $1}')

	if [ $VALBALANCE -lt 32000000 ]; then  # quick validation if validator is lagging or not
		 query_balances
		 display_telemetry
                 display_telemetry_backlog
	         echo "--------------------------------------------------------"
	  else
                 # Validator is not lagging behind the 32m threshold. All good.
	         VALBACKLOG="no backlog (ok)"
		 display_telemetry
	         echo "--------------------------------------------------------"
		 exit 0
	fi
}

# display validator telemetry
function display_telemetry {
	echo "--------------------------------------------------------"
	echo -n "Report date                       : " ; echo $QUERYDATE
	echo -n "Validator ID                      : " ; echo $VALIDATORID
	echo -n "Validator PLS Balance             : " ; echo $VALBALANCE
	echo -n "Validator PLS Backlog             : " ; echo $VALBACKLOG
	echo -n "Validator Stake Market Value      : " ; echo $VALMRKTSTKVAL
	echo -n "PLS price                         : " ; echo $PLSPRICE
	echo -n "Avg PLS Payoff per attestation    : " ; echo $AVGPLSPAYOFF
}

# Show validator backlog telemetry when detected
function display_telemetry_backlog {
        echo -n "PLS recovery rate per day         : " ; echo $VALPLSRECPERDAY
        echo -n "Estimated recovery time [h/d]     : " ; echo "$VALRECTIMEHOURS / $VALRECTIMEDAYS"
        echo -n "Validator Time to Maturity (ETC)  : " ; echo $VALRECDATE
}

# Display RCS rev control version tag
function show_version {
	echo "PulseChain Validator Backlog Time To Maturity Forecasting"
	echo "\$Id: pvt.ksh,v 1.24 2024/06/10 09:52:21 root Exp $"
	echo "written by Marc O. Gloor <marc.gloor@u.nus.edu>"
	echo ""
}

# Display help screen
function show_help {
	echo " "
	echo " Usage: pvt.ksh [-i][-v][-h][-q] <Validator-ID> <Avg-PLS-Attestation-Rate>"
	echo " "
	echo " Syntax:"
	echo "   -i (*)         interactive configuration (default)"
	echo "   -v             version information (RCS tag)"
	echo "   -h             show help"
	echo "   -q arg1 arg2   query beacon <Validator-ID> <Avg-PLS-Attestation-Rate>"
	echo " "
}

check_commands() {
    # Array of commands to check
    typeset -A commands
    commands=(
        [ksh]="ksh"
        [curl]="curl"
        [jq]="jq"
        [awk]="awk"
        [mawk]="mawk"
        [gawk]="gawk"
        [bc]="bc"
    )

    # Loop through commands and check if they are installed
    for cmd in "${!commands[@]}"; do
        if ! command -v "${commands[$cmd]}" >/dev/null 2>&1; then
            if [[ "$cmd" == "awk" ]]; then
                # Special case for awk: check for either mawk or gawk
                if ! command -v "mawk" >/dev/null 2>&1 && ! command -v "gawk" >/dev/null 2>&1; then
                    echo "Neither mawk nor gawk is installed. Please install."
                    return 1
                fi
            else
                echo "${commands[$cmd]} is not installed. Please install."
                return 1
            fi
        fi
    done

    # all pkgs deps pre-reqs met, proceed with the program
    return 0
}

case "$1" in
	-i)
	  interactive_cfg;;
	-q)
	  query_beacon;;
	-v)
	  show_version;;
	-h)
	  show_help;;
	*)
	  interactive_cfg;;
esac

exit $EXIT
