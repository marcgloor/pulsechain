#!/bin/ksh
# @(#) console.sh - pulsechain validator console & session manager
# $Id: console.sh,v 1.31 2023/12/20 01:04:20 root Exp $
# 2023/10/12 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
#
# Dependency package: dialog (preferrably) or whiptail
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

dialog --timeout 3 --title "Pulsechain Validator Console" --ok-button "Start" --msgbox "
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████▓▓▓█████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███████████▓▓▓██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████▓▓▓▓██████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████▓▓▓▓▓████▓▓█████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████▓▓█▓▓████▓▓▓█████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████▓▓██▓▓███▓▓▓▓▓█████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█▓▓██▓▓▓██▓▓█▓▓▓█████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████▓▓▓▓████▓▓█▓▓█████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███████████▓▓████▓▓▓▓▓████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████████▓▓▓▓████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓███████████████▓▓▓▓███████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████████▓▓████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██████████████████████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
Written by Marc Gloor <marc.gloor@u.nus.edu>
\$Revision: 1.31 $
" 30 70

while true; do
    choice=$(dialog --title "Pulsechain Validator Console" --cancel-button "Exit" --menu "\nChoose an option:" 26 55 20 \
        "1" "Session Manager" \
        "l" "Monitor Loop 2min" \
        " " "---------------------" \
        "u" "Validator uptime" \
        "v" "VPS system uptime" \
        "a" "VPS system availability"  \
        " " "---------------------" \
        "s" "Validator Status" \
        "5" "Start Validator" \
        "6" "Restart Validator" \
        "7" "Stop Validator" \
        " " "---------------------" \
        "d" "Firewall Status" \
        "e" "Re/Start Firewall" \
        "f" "Stop Firewall" \
        " " "---------------------" \
        "q" "Exit" \
        3>&1 1>&2 2>&3)
    
    case $choice in
        "1") echo "Monitor"
		/mnt/pulsechain/prod/bin/mon.sh
            ;;
        "l")
            echo "Monitor"
		/mnt/pulsechain/prod/bin/rotmon r2
            ;;
        "s")
            clear
		/mnt/pulsechain/prod/bin/selftest.sh
            echo
            echo "press enter to continue"
            read 
            ;;
        "u")
            dialog --title "Pulsechain Server Info" --msgbox "\nValidator uptime: $(ps -p $(pgrep  -f "EXECUTION SERVER") -o etimes | tail -n1  | awk '{printf "%02dh %02dmin\n", int($1/3600), int(($1%3600)/60)}')" 8 45 
            ;;
        "v")
            dialog --title "Pulsechain Server Info" --msgbox "\nVPS system uptime: $(ps -p $(pgrep  -f "init") -o etimes | tail -n1  | awk '{printf "%02dh %02dmin\n", int($1/3600), int(($1%3600)/60)}')" 8 45 
            ;;
        "a")
            dialog --title "Pulsechain Server Info" --msgbox "\nVPS availability : $(tuptime | grep "System uptime" | awk '{print $3}') " 8 45 
            ;;
        "5")
            dialog --stdout --yesno "Start Validator?" 7 60
            dialog_status=$?

            if [ "$dialog_status" -eq 0 ]; then

            echo "Start Pulsechain Validator"
                clear
                cd /mnt/pulsechain/prod/bin
                screen -S "a) EXECUTION SERVER" -m ./go-pulse.sh
                screen -S "b) CONSENSUS SERVER" -m ./prysm-beacon.sh
                screen -S "c) VALIDATOR SERVER" -m ./prysm-validator.sh
             dialog --title "Pulsechain Validator" --msgbox "\nValidator started..." 10 40

            else
                   echo
            fi
            ;;
        "6")
            dialog --stdout --yesno "Restart Validator?" 7 60
            dialog_status=$?

            if [ "$dialog_status" -eq 0 ]; then

            echo "Restart Pulsechain Validator"
                clear
                echo "Initiating Pulsechain Validator restart..."
                cd /mnt/pulsechain/prod/bin

                echo "Stopping validator..."
                stop-monitors.sh 2>&1 
                docker stop --time=30 go-pulse
                docker stop --time=30 prysm
                docker stop --time=30 validator
                docker rm go-pulse prysm validator
                docker container prune -f
                docker ps -a
                sleep 1

                echo "Starting validator..."
                screen -S "a) EXECUTION SERVER" -m ./go-pulse.sh
                screen -S "b) CONSENSUS SERVER" -m ./prysm-beacon.sh
                screen -S "c) VALIDATOR SERVER" -m ./prysm-validator.sh

             dialog --title "Pulsechain Validator" --msgbox "\nValidator halted, pruned and restarted..." 10 40

            else
                   echo
            fi
            ;;
        "7")
            # Gracefully shutdown (SIGTERM), terminate and cleanup the validator and the monitors
            dialog --stdout --yesno "Shutdown Validator?" 7 60
            dialog_status=$?

            if [ "$dialog_status" -eq 0 ]; then

            echo "Stop Pulsechain Validator"
                clear
                echo "Initiating Pulsechain Validator shutdown..."
                cd /mnt/pulsechain/prod/bin

                # Stop all the detached monitors
                killall nmon iptraf bash tail speedometer > /dev/null 2>&1
                kill $(pgrep -f "/usr/bin/SCREEN -S f\) PROC MONITOR -dm bashtop") > /dev/null 2>&1

                docker stop --time=30 go-pulse
                docker stop --time=30 prysm
                docker stop --time=30 validator
                docker rm go-pulse prysm validator
                docker container prune -f
                docker ps -a
             dialog --title "Pulsechain Validator" --msgbox "\nValidator halted and pruned..." 10 40

            else
                   echo
            fi
            ;;
        "d")
             if [ "`ufw status | head -n1 | awk '{print $2}'`" != 'active' ]; then
                dialog --title "Pulsechain Validator" --msgbox "\nFirewall is not running" 10 40
              else
                dialog --title "Pulsechain Validator" --msgbox "\nFirewall is running" 10 40
             fi
	    clear
            ;;
        "e")
            clear
	    /shell/firewall.sh -start
            dialog --title "Pulsechain Firewall" --msgbox "\nFirewall re/started..." 10 40
            ;;
        "f")
            clear
	    /shell/firewall.sh -stop 
            dialog --title "Pulsechain Firewall" --msgbox "\nFirewall stopped..." 10 40
            ;;
        *)
            # Handle any other options or cancel
            clear
            break
            ;;
    esac
done
