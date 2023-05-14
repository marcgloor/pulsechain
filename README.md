2023/05/14 - written by Marc O. Gloor <marc.gloor @ alumni.nus.edu.sg>

# README for my pulsechain scripts git repository
Contact me if you need more support: @go4mark on Telegram -> Marculix. Also check my alumni page: https://marcgloor.github.io/ or my twitter account https://twitter.com/go_marcgloor

## Let's start
If you feel ready to build up your own pulsechain validator full-sync node, here I share my scripts with you. Note that this is not a step-by-step manual to build up a pulsechain validator from scratch. There are fantatic sources, one of them is e.g. Hodldogs scripts: https://hodldog.notion.site/PulseChain-Mainnet-Node-Validator-Guide-390243a66f3449a9a2425db25370ad89

## Pulsechain Operations / Screenie demo & Pulsechain firewall
![alt text](https://github.com/marcgloor/pulsechain/blob/main/Pulsechain_Firewall_Screenshot.png "Pulsechain Validator Firewall")

https://github.com/marcgloor/pulsechain/assets/41461000/4f1c0c7f-e0de-473a-90c6-41901d449d29

## General Remarks
If you intend to become a Pulsechain validator, wisely consider your ambitions. Becoming a pulsechain validator is imperative for building up a sustainable and stable pulsechain blockchain infrastructure.

Nobody want to see pulsechain validators that are not capable of bringing back their nodes after facing minor issues. Note that you need to be skilled in hardware and software managemenet, in particular Linux system administration and engineering, redundancy management and system automation, especially relevant if you run into issues and incidents on mainnet. Learn everything relevant about journaling and copy-on-write filesystems for software RAID management and snapshots.

You also need to gain networking and security skills, knowing how to protect your system. Also acquire skills in high availability computing and gain knowledge in remote system administration as well e.g. using SSH and GNU Screen to remotely re-connect to detached pulsechain docker sessions. Learn more about Docker and containers as well, perhaps you start with '$ man chroot' in order to understandd container basics.

In order to protect your staked funds on pulsechain mainnet, download respective HOWTOS, Manuals and purchase relevant books. Only operate on pulsechain testnet prior to go-live on mainnet and connect yourself with your pulsechain developers peer-group as well in telegram & discord.

## Pulsechain Validator Design
Hardware:
I configured 5 physical disks in 4 bays on a HP Enterprise Microserver Gen 8.
1. 2 RAID1 mirrored operating system EXT4 SSD Sata III disks in 1st disk bay
2. 2 Pulsechain validator and RAID1 mirrored SSD disks in 2nd & 3rd disk bay
3. 1 General backup HDD disk to run incremental rsync backup rotation & retention management in 4th disk bay

Software:
1. Operating System: Debian (stable branch) in a redundant dual-bay 2.5" SSD (2 Western Digital RED) to 3.5" hardware RAID1 mirrored enclosure -> https://www.startech.com/en-ch/hdd/35sat225s3r
2. I keep my Debian linux up to date using regular '$ apt-get -u upgrade && apt-get -u dist-upgrade' jobs that pull the latest packages from the main, contrib and most importantly from the security archives.
3. Go-eth execution client, Prysm consenus client and Prysm Validator client are running in docker containers that I manually prune from time to time.
4. I am running my validator behind a physical router firewall and a linux software firewall in tty independent, detached GNU screen sessions that can be re-attached remotely using screenie, a GNU screen wrapper that I wrote 20 years ago -> https://marcgloor.github.io/screenie.html
5. My pulsechain validator disk holding the full-synced blockchain tree is part of a massive enterprise high-avalability computing capable ZFS diskarray pool that is software RAID1 mirrored among two physical disks. From the respective pulsechain dataset (/blockchain), a time triggered crontab job is generating regular recurring snapshots in a 10min, 1h, daily and weekly intervals that allows me to quickly redirect a new symlink to my mounted pulsedchain root. Using this technique, the business continuity recovery of e.g. 1TB of blockchain data takes a couply of seconds only.

Networking:
1. Failover / BCP: I got a second spare (slave) internet router that is identical to my (master) router
2. Regular latency checks / Bandwith of 1000 Mbit/s.
3. Access to a configurable router for firewall, static routes and port-forwarding (even to temporarily activate a DMZ to your validator if needed).
4. Fix IP ideally (I don't have one but use dynamic DNS and homebuilt scripts to mitigate unforseen effects should my ISP or my router change the IP address (e.g. via DHCP after a lease expired).

