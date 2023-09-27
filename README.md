# README for my pulsechain scripts git repository
Contact me if you need more support: @go4mark on Telegram --> Marculix. Also check my alumni page: https://marcgloor.github.io/ or my twitter account https://twitter.com/go_marcgloor. The pulsechain validator demo can be found here: https://www.youtube.com/watch?v=9654UtYcnE8

## Pulsechain Operations / Screenie demo & Pulsechain firewall

![Console](https://github.com/marcgloor/pulsechain/blob/main/pulsechain-console_etcissue.net.png "Pulsechain agetty console banner")

![Firewall](https://github.com/marcgloor/pulsechain/blob/main/Pulsechain_Firewall_Screenshot.png "Pulsechain Validator Firewall")

![IBM RS/6000 nmon](https://github.com/marcgloor/pulsechain/blob/main/nmon.png "Pulsechain benchmark tool")

https://github.com/marcgloor/pulsechain/assets/41461000/4f1c0c7f-e0de-473a-90c6-41901d449d29

## Target audience
This pulsechain validator archive is NOT dependent or based on any fancy 3rd party installation scripts and primarily useful if you run your validators on headless servers remotely administered using ssh/screen (on-premise or cloud). This is neither a beginners level pulsechain validator archive nor a entry level set of instructions on howto setup or run validator nodes. This page might be useful for sysadmins and operators of pulsechain nodes with advanced Linux skills and the aim to improve and tweak their servers. 

## General Remarks
If you intend to become a Pulsechain validator, wisely consider your plans. Becoming a pulsechain validator is imperative for building up a sustainable and stable pulsechain blockchain infrastructure. It does come with substantial risks.

Don't play around on Pulsechain mainnet if you qualify your Linux skills entry level. Do not execute install scripts and think that's all you need to run a validator --> **You will lose money**. 
In order to protect your staked funds on pulsechain mainnet, download respective HOWTOS, Manuals and purchase relevant books. Wiesely test on pulsechain testnet prior to deploy on mainnet and connect yourself with your pulsechain developers peer-group as well in telegram & discord.

Nobody want to see pulsechain validators that are not capable of bringing back their nodes after facing minor issues. Note that you need to be skilled in hardware and software managemenet, in particular Linux system administration and engineering, redundancy management and system automation, especially relevant if you run into issues and incidents on mainnet. Learn everything relevant about journaling and copy-on-write filesystems for software RAID management and snapshots.

You also need to gain networking and security skills, knowing how to protect your system. Also acquire skills in high availability computing and gain knowledge in remote system administration as well e.g. using SSH and GNU Screen to remotely re-connect to detached pulsechain docker sessions. Learn more about Docker and containers as well, perhaps you start with '$ man chroot' in order to understandd container basics.

## Pulsechain Validator High Availability Design
### Hardware
I configured 5 physical disks in 4 bays on a HP Enterprise Microserver Gen 8.
- Two 500GB hardware RAID1 mirrored operating system SSD disks (ext4 partitions) in 1st disk bay
- Two 8TB Pulsechain validator and software RAID1 mirrored SSD disks (zfs partitions) in 2nd & 3rd disk bay
- One general backup HDD to run incremental rsync backup rotation & retention management in 4th disk bay

### Software

#### Operating System
Debian (stable branch) in a redundant dual-bay 2.5" SSD (2 Western Digital RED) to 3.5" hardware RAID1 mirrored enclosure --> https://www.startech.com/en-ch/hdd/35sat225s3r. I keep my Debian linux up to date using regular '$ apt-get -u upgrade && apt-get -u dist-upgrade' jobs that pull the latest packages from the main, contrib and most importantly from the security archives. I use Debian as they developed the most reliable package system and they follow the most reliable release politics, apart from that, Debian is the mother of numerous clone distributions.

#### Execution and Consensus Layer
Go-eth execution client, Prysm consenus client and Prysm validator clients are running in docker containers that I manually prune from time to time. I also ensure every once in a while that I pull the latest docker packages by stoping the validator, prune and remove all docker images to enforce the re-downloading of the latest vesions when restarting the node.
```
docker container prune -f
docker stop go-pulse <execution-client> <consensus-client> <validator-client>
docker rm go-pulse <execution-client> <consensus-client> <validator-client>
docker system prune -a
docker rmi <execution-client> <consensus-client> <validator-client>
```
#### Security
I stoped all unwanted services on the server, closed the unused porrts and I am running my validator behind a physical router firewall and an additional linux software firewall in detached GNU screen sessions that can be re-attached remotely using screenie, a GNU screen wrapper that I wrote 20 years ago --> https://marcgloor.github.io/screenie.html

#### Disaster Recovery, Rollback and Business Continuity
The goal is Fives Nines high availablility, the lowest MTTR and the highest MTBF. My pulsechain validator disk that is holding the full-synced blockchain data structure is part of an enterprise level high-avalability capable ZFS diskarray that is software RAID1 mirrored among two physical 8TB SSD disks. From the respective pulsechain dataset, a time triggered crontab job is generating regular snapshots in a 10min interval for up to 10 days. Using ZFS snapshots allows you to quickly redirect a new symlink (ln -s) to your mounted pulsedchain root directory in case of an incident such as e.g. a corrupted consensus or execution database. This way, you can rollback the entire validator on the timeline back to a desired point in history (like a time capsule on a filesystem level). For example, rolling back a 1TB blockchain validator takes a couple of seconds using copy-on-write technique rather than hours using conventional tools such as dd, rsync, scp, cp or tar commands.

You should measure and report your historical and statistical real time data of the system with the commands hm (https://marcgloor.github.io/hourmeter.html) and tuptime. I also keep an /etc/history file on every server as a log of server specific milestones, incidents or issues.
```
$ hm
hm> 882.5h

$ tuptime
System startups:        1  since  02:20:52 24/05/23
System shutdowns:       1 ok  +  0 bad
System life:            5d 0h 9m 26s

System uptime:          99.97%  =  5d 0h 7m 22s
System downtime:        0.03%  =  2m 4s

Average uptime:         2d 12h 3m 41s
Average downtime:       2m 4s

Current uptime:         3d 15h 37m 11s  since  10:53:07 25/05/23
```
#### Monitoring:
<update-follows> (currently using MRTG) and a pulsechain rotation monitor (see rotmon.sh)

### Networking
<update-follows>

#### Failover / BCP
I got a second spare (slave) internet router that is identical to my (master) router

#### Regular latency checks 
Bandwith of 1000 Mbit/s. Measure using the tool speedtest. 

#### Routing 
Access to a configurable router for firewall, static routes and port-forwarding (even to temporarily activate a DMZ to your validator if needed).

#### IP Address
Static IP (I don't have one but I use dynamic DNS and homebuilt scripts to mitigate unforseen effects should my ISP or my router change the IP address (e.g. via DHCP after a lease expired). I also log my public ip using the attached crontab job (see etc-crontab)

