#!/bin/ksh
# @(#) ROTMON - pulsechain rotation monitor
# $Id: rotmon.sh,v 1.9 2023/12/27 07:05:46 root Exp $
# 2023/10/12 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
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

# set working directory 
cd /mnt/pulsechain/prod/bin

# Get a list of attached screen sessions
screen_list=$(screen -ls | cut -d'.' -f1 | sed '1d;$d')

function show_help {
 echo " "
 echo " Synopsis: rotmon.sh [start][stop][-h]"
 echo " "
 echo " Syntax:"
 echo "   si               start infinite looping"
 echo "   r2               run for 2 minutes"
 echo "   stop             shutdown "
 echo "   -h               show help"
 echo " "
 exit
}

function start_mon {

	# Iterate through the screen sessions and switch between them
	while true; do
  		for session in $screen_list; do
    		timeout 6 screen -r "$session"
    		screen -S "$session" -X detach
  		done
	done
}

function start_iter {

	# Iterate through the screen sessions for n-iterations,
        # switch between them followed by stop
        # 1 iteration are the sum of all screen cycles (3 main sessions)

	c=1
	end_time=$((SECONDS + 120))  # n seconds

	while [[ $SECONDS -lt $end_time ]]; do
	    for session in $screen_list; do
	        timeout 5 screen -r "$session"
	        screen -S "$session" -X detach
	        (( c++ ))
	    done
	done
}

function stop_mon {

	# Iterate through the screen sessions and switch between them
  	for session in $screen_list; do
	    screen -S "$session" -X detach
	done

	./stop-monitors.sh
	kill -TERM -$(pgrep -f "rotmon") >/dev/null 2>&1
	echo "Terminated the rotation monitor..."
}

case "$1" in
 si)
   start_mon;;
 r2)
   start_iter;;
 stop)
   stop_mon;;
 -h)
   show_help;;
 *)
   show_help;;
esac

