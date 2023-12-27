#!/bin/ksh
# @(#) Pulsechain validator purge and prune service
# $Id: prune-and-purge.sh,v 1.3 2023/12/27 06:54:48 root Exp $
# 2023/12/14 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
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

docker stop go-pulse prysm validator
docker rm go-pulse prysm validator
docker container prune -f
docker system prune -a
docker ps -a
echo "Pruning done"
sleep 4
