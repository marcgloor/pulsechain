#!/usr/bin/env perl
# @(#) MONITOR - pulsechain validator console & session manager
# $Id: mon.sh,v 1.20 2023/12/18 07:47:32 root Exp $
#
# 2023/05/17 - written by Marc O. Gloor <marc.gloor@u.nus.edu> 
# Modified screene wrapper for running a pulsechain validator node
# 
# 2010/02/06 - written by Jiri Nemecek (nemecek<dot>jiri<at>gmail<dot>com)
# Enhanced Perl-reimplementation of 'screenie' by Marc O. Gloor
#   (http://pubwww.fhzh.ch/~mgloor/screenie.html)
#
# 2005/08/28 - initial version of screenie(1) written by Marc O. Gloor
#  released version screenie-1.17.0
#
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

use Time::HiRes qw(sleep);  # Module required for the sleep() function
my $SCREEN = '/bin/screen'; # optionally configure location of screen

$0 =~ s{^.*/}{};
if ( @ARGV ) { # non-interactive mode
	&help() if $ARGV[0] =~ /^-(?:h|-?help)$/;
	if ( $ARGV[0] eq '-j' ) {
		my $name = defined $ARGV[1] ? $ARGV[1] : '';
		$name =~ tr/ /_/;
		my $job = $ARGV[2] || '';
		my ( $code, $msg ) = &start_session ( $name, $job );
		$code ? die "$msg\n" : exit 0;
	} else {
		warn 'Unknown parameters: ' . join ( ' ', @ARGV ) . "\n";
		&help();
	}
} else { # interactive mode
        my ( $sessions, $error_msg, $selection );
        while ( 1 ) {
                $sessions = &get_sessions();
                &print_menu ( $sessions, $error_msg );
                chomp ( $selection = lc <> );
                exit 0 if $selection =~ /^[q]$/;
                if ( $selection =~ /^[m]$/ ) { # new session
                
                # Check if the process exists
                my $stop_mon = "killall nmon iptraf tail speedometer; kill \$(pgrep -f \"PROC MONITOR\") > /dev/null 2>&1";
                my $process_check = `pgrep nmon`;
                  if ($process_check) { # monitors running
                          system($stop_mon);    
                          sleep(0.2);
                  } else {              # monitor not running
                          my ( $name, $job );
                          my ( $code, $msg ) = &start_session ( "d) SYST MONITOR", nmon || $ENV{'SHELL'} );
                          my ( $code, $msg ) = &start_session ( "e) PROC MONITOR", "bashtop" || $ENV{'SHELL'} );
                          my ( $code, $msg ) = &start_session ( "f) NETW MONITOR", "/usr/bin/speedometer -l -r eth0 -m \$(( 1024 * 1024 * 3 / 2 ))" || $ENV{'SHELL'} );
                          my ( $code, $msg ) = &start_session ( "g) TRAF MONITOR", "/usr/sbin/iptraf -d eth0 " || $ENV{'SHELL'} );
                          my ( $code, $msg ) = &start_session ( "h) DISK MONITOR", "/usr/bin/tail -n 25 -f /var/log/pulsechain-df.log" || $ENV{'SHELL'} );
                    } 
                 } elsif ( $selection == /^[bn]$/ ) { # stop monitoring
                        my ( $name, $job );
                        my ( $code, $msg ) = &start_session ( "stop", "./stop-monitoring.sh" || $ENV{'SHELL'} );
                        if ( $code ) {
                                $error_msg = $msg;
                        } else {
                                $sessions = &get_sessions();
                                undef $error_msg;
                        }
                } elsif ( $selection =~ /^(\d+)([dx])?$/ ) { # session selected
                        my ( $id, $arg, $pid ) = ( $1, lc ( $2 || '' ), 0 );
                        ( $error_msg = "Incorrect selection: $selection\n" ), next
                                unless $sessions->[$id-1];
                        $pid = $sessions->[$id-1]->[0];
                        my ( $code, $msg ) = &attach_session ( $pid, $arg );
                        $error_msg = $code ? $msg : undef;
                } else { # incorrect selection
                        $error_msg = "Incorrect selection: $selection\n";
                }
        }
        sleep 5;
}

exit 0;

sub get_sessions {
	my @s = ();
	for ( split "\n", `$SCREEN -ls 2>&1` ) {
		next unless /^\s*(\d+)\.(.*?)\s+\((?:At|De)tached\)/;
		push @s, [ $1, $2 ];
	}
	@s = sort { $a->[1] cmp $b->[1] } @s; # sort according to names
	return \@s;
}

# Attach session with pid $_[0]; optional arg $_[1] is one of [xd]
# as described in menu for 'screen -x' and 'screen -rd' respectively.
# Return ( code, message ), where
#   code - 0 for normal operation, screen exit code for unsuccessful session
#          resume attempt (session exited in the same second).
#   message - error message in case of error
sub attach_session {
	my $cmd = "$SCREEN " . ( $_[1] && $_[1] eq 'x' ? '-x ' : $_[1] && $_[1] eq 'd' ? '-rd ' : '-r ' );
	my $t0 = time();
	my $std = `$cmd $_[0] 2>&1`;
	if ( $? ) { # non-zero exit status
		my ( $code, $t ) = ( $? >> 8, time() );
		return ( $code, "Failed to attach session with PID $_[0]:\n$std" )
			if $t0 == $t; # attachment failure
		return ( 0, '' );
	}
}

# Return ( code, message ), where
#   code - 1 for empty session name, screen return code otherwise
#   message - error message in case of error
sub start_session {
	return [ 1, 'Non-empty session name expected!' ]
		unless ( defined $_[0] and $_[0] !~ /^\s*$/ );
	my $job = defined $_[1] ? $_[1] : '';
	#my $std = qx{$SCREEN -S "$_[0]" -dm /usr/bin/top 2>&1};
	my $std = qx{$SCREEN -S "$_[0]" -dm $job 2>&1};
	return ( $? >> 8, "Failed to start session: $std" ) if $?;
	return ( 0, '' );
}

# Accepts arrayref parameter of the sessions (returned by get_sessions),
# optional second parameter specifies a message to be printed first.
sub print_menu {
	system 'clear' unless system 'which clear >/dev/null 2>&1';
	my @scr_lines = ();
	my ( $maxl, $l ) = ( 0, 0 );
	( $l = length $_->[0] ) > $maxl && ( $maxl = $l ) for @{$_[0]};
	for ( 0 .. $#{$_[0]} ) {
		push @scr_lines, sprintf "%2u) %${maxl}u.%s", $_+1, @{$_[0]->[$_]}[0,1];
	}
	print <<EOMENU;
  ______________________________________________________________ 
 |   _____ __ __ __    _____ _____                              |
 |  |     \\  |  |  |  |   __|   __|   |       PULSECHAIN        |
 |  |   __/  |  |  |__|__   |   __|   |    VALIDATOR CONSOLE    |
 |  |__|  |_____|_____|_____|_____|   |    & SESSION MANAGER    |
 |______________________________________________________________|

@{[ $_[1] ? "$_[1]\n" : '' ]}@{[ join "\n", @scr_lines ]}
 ________________________________________________________________
 
             Switch between sessions using ctrl-a-d
 ________________________________________________________________

 m) monitors on/off
 q) quit
 ________________________________________________________________

EOMENU
 print "select: "
}

sub help {

	print <<EOHELP;

$0 - terminal screen-session handler.

Usage:

 $0
   - interactive mode

 $0 -h|--help
   - show this description

 $0 -j <name> <job>
   - non-interactive mode: create a new session.

Licence & Author:

  Enhanced Perl-reimplementation of 'screenie' by Marc O. Gloor
    (http://pubwww.fhzh.ch/~mgloor/screenie.html)

  2010/02/06 - written by Jiri Nemecek (nemecek<dot>jiri<at>gmail<dot>com)

  This program is free software but comes WITHOUT ANY WARRANTY.
  You can redistribute and/or modify it under the same terms as Perl itself.

EOHELP
	exit 1;
}

