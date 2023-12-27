#!/bin/sh
# @(#) Highspeed Pulsechain datadir cloning on a ZFS volume/pool
# $Id: prod-bkp-clone.sh,v 1.2 2023/12/27 06:55:48 root Exp $
#
# 2023/05/17 - written by Marc O. Gloor <marc.gloor@u.nus.edu>
#
# Crontab Job that crates a ZFS datadir clone & rsyncs it to a backup directory
# followed by cleaning up ZFS snapshots and ZFS snapshot clones
# ONLY NEEDED IF YOU USE A ZFS FILESYSTEM
# Add this to your systemwide /etc/crontab
# 0 0 * * * root /mnt/pulsechain/prod/bin/prod-bkp-clone.sh >/dev/null 2>&1

# This program is free software but comes WITHOUT ANY WARRANTY.
# You can redistribute and/or modify it under the same terms as Perl itself.
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

# create ZFS snapshot (should be done instantly, e.g. 1TB in a couple of seconds)
/sbin/zfs snapshot pool0/pulsechain@mnt-zpool0-pulsechain-prod_daily.snapshot >/dev/null 2>&1

# creates a clone of the ZFS snapshot just produced (created instantly in a couple of seconds)
/sbin/zfs clone pool0/pulsechain@mnt-zpool0-pulsechain-prod_daily.snapshot pool0/daily.snapshot.clone >/dev/null 2>&1

# rsyncs the snapshot clone just produced into a real filesystem
# (takes a while and produces I/O traffic but no significant CPU load)
/usr/bin/rsync -av ‐‐delete /mnt/zpool0/daily.snapshot.clone/prod /mnt/backup/pulsechain.prod.daily.rsync/ >/dev/null 2>&1

# cleanup snapshot clone
/sbin/zfs destroy pool0/daily.snapshot.clone >/dev/null 2>&1

# cleanup snapshot
/sbin/zfs destroy pool0/pulsechain@mnt-zpool0-pulsechain-prod_daily.snapshot >/dev/null 2>&1

