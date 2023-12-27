#!/bin/ksh
# @(#) Pulsechain Validator Secure System Firewall
# $Id: firewall.sh,v 1.10 2023/12/27 04:59:12 root Exp root $
# 2023/05/15 - redesigned fork for Geth/Prysm based Pulsechain Validator Node
# 2003/06/08 - written by Marc O. Gloor <marc.gloor@alumni.nus.edu.sg>
# 
# Note: Generally, a firewall is a permanent work in progress, a continous improvement effort
# This wip version was a quick and dirty hack taken from an existing server to 
# suit the needs of hardening a pulsechain validator mainnet node.
# Report any issues, hints or suggestions to me and I will update this git branch accordingly
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
# Dependecies:  
#  ksh, curl, netstat (debian pkg net-tools), fail2ban
# 
# Add to your systemwide /etc/crontab:
# firewall restart every 2 odd hours (12 times a day) in order to auto update most recent banlist to firewall
# 0 1-23/2 * * * root /shell/firewall.sh -restart >/dev/null 2>&1
# 
# todo: 
# import an exported firewall policy
# 

# global definitions
OwnIP=$(curl -s ident.me)    # Own IP, either hardcode or grab using systam tools
EXIT=0
ACTION1="start"
ACTION2="end"
ACTION3="script start perm failure"
ACTION4="firewall started"
ACTION5="firewall stopped"
ACTION6="interactive operations mode"
ACTION7="IP blocked:"
ACTION8="firewall policy bkp to:"
ACTION9="IP unblocked:"
SCNAME=$0
HOST=$(hostname)

# begin script
# start logging
logger -p user.err -t $SCNAME $ACTION1

# rootcheck
if [ `id -u` != 0 ]
 then
  logger -p user.err -t $SCNAME $ACTION3
  echo "root credentials required."
  logger -p user.err -t $SCNAME $ACTION2
  exit $EXIT
fi

function int_ops {
logger -p user.err -t $SCNAME $ACTION6
while :
do
clear
  echo " +-----------------------------+"
  echo " |       PULSECHAIN PROD       |"
  echo " |       F I R E W A L L       |"
  echo " |       OPERATIONS MENU       |"
  echo " +-----------------------------+"
  echo " |  1) display current policy  |"
  echo " |  2) re/start firewall       |"
  echo " |  3) stop firewall           |"
  echo " |  4) display IP traffic      |"
  echo " |  5) count rules             |"
  echo " |  6) firewall policy backup  |"
  echo " |  q) quit                    |"
  echo " +-----------------------------+"
  echo -n " Choose: "
  read ANTW
  case $ANTW in
   q) break ;;
   1) clear;ufw status ; iptables -nL;echo "";echo "press return to continue";read;;
   2) clear;start_firewall;echo "";echo "press return to continue";read;;
   3) clear;stop_firewall;echo "";echo "press return to continue";read;;
   4) clear;traffic_mon;echo "";;
   5) clear;count_rules;echo "";echo "press return to continue";read;;
   6) clear;pol_bkp;echo "";echo "press return to continue";read;;
   6) echo " retry again..." ; sleep 1 ;
  esac
done
}

function traffic_mon {
while ! read -t0; do 
 netstat --inet
 echo ""
 echo "press return to continue"
 sleep 1
 clear
done
}

function pol_bkp {
 echo "Firewall policy backup ~/.fw_bkp_<date>_<time>"
 BKPFILE=".fw_bkp_$(hostname)_$(date '+%d-%m-%Y_%H-%M-%S').bkp"
 iptables-save > $BKPFILE
 logger -p user.err -t $SCNAME $ACTION8 $BKPFILE
 echo "Policy backup saved in root's homedir (sensitive data!)"
}

function count_rules {
 echo "Currently" $(iptables --list-rules | wc -l) "firewall rules active."
}

function start_firewall {
 stop_firewall
 echo "Re/starting firewall..."

 IP=$OwnIP

 ufw default deny incoming
 ufw default allow outgoing 

 # Setup standard DOCKER specific firewall chains (if you use docker e.g. geth & prysm)
 iptables -N DOCKER 
 iptables -N DOCKER-USER
 iptables -N DOCKER-ISOLATION-STAGE-1
 iptables -N DOCKER-ISOLATION-STAGE-2

 # Allow SSH access
 ufw allow 22/tcp comment 'SSH Port' 

 # Accept incoming NTP traffic
 ufw allow 123/udp comment 'NTP Port'

 # Accept incoming HTTP traffic (only needed for monitoring tools)
 # ufw allow 80/tcp comment 'HTTP Port 80'

 # Accept incoming HTTPS traffic (only needed for monitoring tools)
 # ufw allow 443/tcp comment 'HTTPS Port 443'

 # Allow Pulsechain/Execution/Geth network port
 ufw allow 30303/tcp comment 'geth tcp'
 ufw allow 30303/udp comment 'geth udp'
  
 # Allow Pulsechain/Consensus/Prysm network port 
 ufw allow 13000/tcp comment 'prysm tcp'
 ufw allow 12000/udp comment 'prysm udp'
  
 # Enable RPC port
 ufw allow from 127.0.0.1 to any port 8545 proto tcp comment 'RPC Port'

 ufw --force enable

 logger -p user.err -t $SCNAME $ACTION4
 echo "Firewall started (up)."
}

function stop_firewall {
 echo "Stopping firewall..."
 ufw disable 
 ufw --force reset
 logger -p user.err -t $SCNAME $ACTION5
 echo "Firewall halted (down)."
}

function show_help {
 echo " "
 echo " Synopsis: firewall.sh [-start][-stop][-i][-l][-h] "
 echo " "
 echo " Syntax:"
 echo "   -start            start firewall"
 echo "   -restart          restart firewall"
 echo "   -stop             shutdown firewall"
 echo "   -i                interactive operations (default)"
 echo "   -l                display current policy"
 echo "   -h                show help"
 echo " "
}

case "$1" in
 -l)
   iptables -nL;;
 -start)
   start_firewall;;
 -restart)
   start_firewall;;
 -stop)
   stop_firewall;;
 -h)
   show_help;;
 *)
   int_ops;;
esac

# stop logging
logger -p user.err -t $SCNAME $ACTION2
exit $EXIT

#EOF

