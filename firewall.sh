#!/bin/ksh
# @(#) Pulsechain Validator Secure System Firewall
# $Id: firewall.sh,v 1.5 2023/05/21 09:11:10 root Exp root $
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
#  ksh, curl, netstat, fail2ban
# 
# Add to your systemwide /etc/crontab:
# firewall restart every 2 odd hours (12 times a day) in order to auto update most recent banlist to firewall
# 0 1-23/2 * * * root /shell/firewall.sh -restart >/dev/null 2>&1
# 
# todo: 
# import an exported firewall policy
# 

# global definitions
OwnIPscan=$(curl -s ident.me)
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
  echo " |  4) blocking intruder 48h   |"
  echo " |  5) blocking intruder perm. |"
  echo " |  6) unban fail2ban IP       |"
  echo " |  7) display IP traffic      |"
  echo " |  8) count rules             |"
  echo " |  9) firewall policy backup  |"
  echo " |  q) quit                    |"
  echo " +-----------------------------+"
  echo -n " Choose: "
  read ANTW
  case $ANTW in
   q) break ;;
   1) clear;ufw status ; iptables -nL;echo "";echo "press return to continue";read;;
   2) clear;start_firewall;echo "";echo "press return to continue";read;;
   3) clear;stop_firewall;echo "";echo "press return to continue";read;;
   4) clear;blocking_intruder_temp;echo "";echo "press return to continue";read;;
   5) clear;blocking_intruder_perm;echo "";echo "press return to continue";read;;
   6) clear;unban_IP;echo "";echo "press return to continue";read;;
   7) clear;traffic_mon;echo "";;
   8) clear;count_rules;echo "";echo "press return to continue";read;;
   9) clear;pol_bkp;echo "";echo "press return to continue";read;;
   *) echo " retry again..." ; sleep 1 ;
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

# temporary banlist - deny access for hosts and hostranges
function blocking_intruder_temp {
 echo -n "Blocking IP address [A.B.C.D/8,16,24]: "
 read INTRIP
 iptables -A BLOCKED-INTRUDER -s $INTRIP -j DROP
 echo "iptables -D BLOCKED-INTRUDER -s $INTRIP -j DROP" | at now + 14 days >/dev/null 2>&1
 logger -p user.err -t $SCNAME $ACTION7 $INTRIP
 echo "IP blocked for 14 days."
} 

# permanent banlist - deny access for hosts and hostranges
function blocking_intruder_perm {
 echo -n "Blocking IP ddress [A.B.C.D/8,16,24]: "
 read INTRIP
 echo $INTRIP >> /etc/banlist
 iptables -A BLOCKED-INTRUDER -s $INTRIP -j DROP
 logger -p user.err -t $SCNAME $ACTION7 $INTRIP
 echo "IP blocked permanently."
}

# Apache banlist auto update: Ban failed access get/post found in apache.log
function ApacheAuthIntruderScan {
 echo "Read Apache log files, identify intruders and populate /etc/banlist..."
 cp /etc/banlist/tmp/~banlist.tmp >/dev/null 2>&1 
 cat /var/log/apache2/access.log | grep -E '400|404'| awk '{print $1}' >> /tmp/~banlist.tmp 
 zcat /var/log/apache2/access.log.*.gz | grep -E '400|404'| awk '{print $1}' >> /tmp/~banlist.tmp
 cat /tmp/~banlist.tmp | sort | uniq | sort > /etc/banlist
 sed -i "/$OwnIPscan/d" /etc/banlist
 sed -i "/::1/d" /etc/banlist
 rm /tmp/~banlist.tmp
 echo "Apache intruder listing /etc/banlist updated."
}

# Auth log SSH attackers auto update: Ban failed SSH "Failed password" entries found in auth.log
function SSHAuthIntruderScan {
 echo "Read System auth.log, identify intruders and populate /etc/banlist..."
 cp /etc/banlist/tmp/~banlist.tmp >/dev/null 2>&1
 cat /var/log/auth.log | grep -E 'Failed password'| grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> /tmp/~banlist.tmp
 zcat /var/log/auth.log.*.gz | grep -E 'Failed password'| grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> /tmp/~banlist.tmp
 cat /tmp/~banlist.tmp | sort | uniq | sort > /etc/banlist
 sed -i "/$OwnIPscan/d" /etc/banlist
 sed -i "/::1/d" /etc/banlist
 rm /tmp/~banlist.tmp
 echo "SSH intruder listing /etc/banlist updated."
}

# unban fail2ban IP
function unban_IP {
 echo -n "Affected fail2ban chain: " 
 read CHAINUNBANIP
 echo -n "Unblocking IP address [A.B.C.D/8,16,24]: "
 read UNBANIP
 fail2ban-client set $CHAINUNBANIP unbanip $UNBANIP
 logger -p user.err -t $SCNAME $ACTION9 $UNBANIP
 echo "IP unblocked."
}

function start_firewall {
 stop_firewall
 echo "Re/starting firewall..."

 LOOPBACK_INTERFACE=lo          # Local Loopback
 IP=192.168.1.120               # hardcode your own homenet IP
 ANY=0/0                        # Any IP adress
 LOOPBACK=127.0.0.1             # Loopback address range
 CLASS_A=10.0.0.0/8             # reserved class A
 CLASS_B=172.16.0.0/12          # reserved class B
 CLASS_C=192.168.0.0/16         # reserved class C
 CLASS_D=224.0.0.0/4            # reserved class D 
 CLASS_E=240.0.0.0/5            # reserved class E
 BROADCAST_SRC=0.0.0.0          # Broadcast sender
 BROADCAST_DEST=255.255.255.255 # Broadcast receiver
 PRIVPORTS=0:1023               # privileged ports
 UPRVPRT=1024:65535             # unprivileged ports
 # NS=62.65.128.10              # primary nameserver
 # MYLAN=192.168.10.0/24        # LAN address

 # Flush all rules
 iptables -F ; iptables -X

 # Set main policy (drop all, not reject)
 #iptables -P INPUT DROP
 #iptables -P FORWARD ACCEPT
 #iptables -P OUTPUT DROP
 ufw default deny incoming

 # Create new fw rule to block intruder via the interactive menu option 4
 iptables -N BLOCKED-INTRUDER 

 # source address verification and spoof protection
 if [ -e /proc/sys/net/ipv4/conf/all/rp_filter ]; then
   for f in /proc/sys/net/ipv4/conf/*/rp_filter; do
    echo 1 > $f
   done
  else
   echo "PROBLEM DETERMINATED SETTING UP SPOOFING PROTECTION."
 fi

 # ----------------------- explicitely drop packages here again  --------------------------------

 # Anti-spoofing rule / Deny incoming requests which have a spoofed source address
 iptables -A INPUT -i eno1 -s 192.168.0.0/24 -j DROP
 iptables -A INPUT -i eno1 -s 127.0.0.0/8 -j DROP
 echo "Anti-spoofing activated..."

 # Drop fake packages that pretend to come from your own source IP
 iptables -A INPUT -i eno1 -s $IP -j DROP

 # Exploit protection (Outward attacks from LAN insider e.g. from an external attacker)
 iptables -A OUTPUT -m state -p icmp --state INVALID -j DROP
 echo "Exploit protection activated..."

 # Drop packages pretend to come from your own loopback device
 iptables -A INPUT -i eno1 -s $LOOPBACK -j DROP
 iptables -A OUTPUT -o eno1 -s $LOOPBACK -j DROP
 echo "Loopback spoofing protection activated..."

 # Drop packages having illegal broadcast addresses
 iptables -A INPUT -i eno1 -s $BROADCAST_DEST -j DROP
 iptables -A INPUT -i eno1 -d $BROADCAST_SRC -j DROP
 echo "Illegal broadcast spoofing protection activated..."

 # Block packages without SYN bit set
 iptables -A INPUT -i eno1 -p tcp ! --syn -m state --state NEW -j DROP
 echo "Illegal SYN bit packages protection activated (sysn-flood)..."

 # Drop incoming malformed XMAS packets
 iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
 echo "Illegal malformed XMAS packet protection filter protection activated..."

 # Drop incoming malformed NULL packets
 iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
 echo "Illegal malformed NULL packet protection filter activated..."

 # Drop packets with incoming fragments
 iptables -A INPUT -f -j DROP
 echo "Drop fragmented packets protection activated..."
 
 # Limit the Number of Concurrent Apache Connections per IP Address
 #iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 5 -j DROP

 # ---------------------- Accept the following Pulsechain Traffic FROM HERE ----------------------------------

 # Generally support outgoing traffic
 ufw default allow outgoing 

 # Setup standard DOCKER specific firewall chains
 iptables -N DOCKER 
 iptables -N DOCKER-USER
 iptables -N DOCKER-ISOLATION-STAGE-1
 iptables -N DOCKER-ISOLATION-STAGE-2

 # Pulsechain specific ports (for go-eth and prysm, change if you run other execution or consensus clients!)
 ufw allow 30303
 ufw allow 13000/tcp
 ufw allow 12000/udp 
 
 # Pulsechain specific monitoring ports
 ufw allow 3000
 ufw allow 5054
 ufw allow 5064
 ufw allow 9100 

 # Accept incoming NTP packages (Not sure this is required, but let's make it happen)
 ufw allow 123/udp

 # Accept incoming HTTP traffic
 #ufw allow 80/tcp

 # Accept incoming HTTPS traffic
 #ufw allow 443/tcp

 # Accpet incoming SSH traffic
 ufw allow 44444/tcp 

 # Releae Loopback restrictions
 iptables -A INPUT -i $LOOPBACK_INTERFACE -j ACCEPT
 iptables -A INPUT  -i lo -d $LOOPBACK -j ACCEPT
 iptables -A OUTPUT -o $LOOPBACK_INTERFACE -j ACCEPT
 iptables -A OUTPUT  -o lo -s $LOOPBACK -j ACCEPT

 # Enable UFW rules
 ufw --force enable

 # start fail2ban service
 /etc/init.d/fail2ban start
 sleep 1
 /usr/bin/fail2ban-client status 

 # read blacklisted IP's from logfiles and re-block them 
 #ApacheAuthIntruderScan 
 SSHAuthIntruderScan 
 for IP in $(cat /etc/banlist); do iptables -A BLOCKED-INTRUDER -s $IP -j DROP; done
 echo "Imported and re-activated permanently blocked IP bans..."
 # keep a Log of Dropped Network Packets on IPtables (/var/log/messages)
 iptables -A INPUT -i eth0 -j LOG --log-prefix "IPtables dropped packets:"
 
 logger -p user.err -t $SCNAME $ACTION4
 echo "Firewall started (up & running)."
}

function stop_firewall {
 echo "Stopping firewall..."
 /etc/init.d/fail2ban stop 
 iptables -F ; iptables -X
 iptables -F INPUT
 iptables -F FORWARD
 iptables -F OUTPUT
 iptables -P INPUT ACCEPT
 iptables -P FORWARD ACCEPT
 iptables -P OUTPUT ACCEPT
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

