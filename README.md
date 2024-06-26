# README for my pulsechain scripts git repository
Contact me if you need more support: @marculix on Telegram (username: Marculix) or by e-mail that you find on [my website](https://marcgloor.github.io). Also checkout my [twitter account/X](https://twitter.com/go_marcgloor) and my older pulsechain validator [youtube demo](https://www.youtube.com/watch?v=9654UtYcnE8) (note: demo does not show the fancy interactive console yet).

## Pulsechain Operations / Screenie demo & Pulsechain firewall

![Console](https://github.com/marcgloor/pulsechain/blob/main/pulsechain-console_etcissue.net.png "Pulsechain agetty console banner")

![Console2](https://github.com/marcgloor/pulsechain/blob/main/validator-console.png "Pulsechain Validator Console")

![Firewall](https://github.com/marcgloor/pulsechain/blob/main/Pulsechain_Firewall_Screenshot.png "Pulsechain Validator Firewall")

![IBM RS/6000 nmon](https://github.com/marcgloor/pulsechain/blob/main/nmon.png "Pulsechain benchmark tool")

https://github.com/marcgloor/pulsechain/assets/41461000/4f1c0c7f-e0de-473a-90c6-41901d449d29

## Target audience
This pulsechain validator archive is NOT dependent or based on any 3rd party installation scripts and primarily useful if you run your validators on headless servers remotely administered using ssh/screen (on-premise or cloud). This is neither a beginners level pulsechain validator archive nor a entry level set of instructions on howto setup or run validator nodes. This page might be useful for sysadmins and operators of pulsechain nodes with advanced Linux skills and the aim to improve and tweak their servers. 

## Why Pulsechain?
Fun fact from the Pulsechain validator community: 
Today's (Oct 23) global Pulsechain validator processing power would be equal to the massive performance of the 4th fastest supercomputer on earth, listed on [top500.org](http://top500.org). 

You can measure the peak floatingpoint performance of your validator system using my modified [Supercomputing Benchmark for Linux](https://marcgloor.github.io/floatingpoint.html). 

Calculation (rough ballpark)
The fastest supercomputer on earth in 1988, CRAY's Y-MP delivered as little as 2.1 GFLOPS, its weight was ~650kg, liquid cooled and it consumed approx. 800 times the power of a modern fridge. It's main use was for military, fluid dynamics or atmospherical sciences. I compared the performance of my own bare-metal pulsechain validator which was 5.4 TFLOPS. Clearly we validators all strongly contribute to the growth of a massive blockchain!

Let's assume ~45k validators times avg. 5 TFLOP (rough ballpark) equals 225 PFLOPS overall pulsechain validator power. 

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
Choose your OS and Linux distribution wisely. I personally prefer a highly stable and not volatile Linux distribution that is entreprise datacenter proof like the [Debian stable Linux](https://www.debian.org/releases) distribution. Debian pushes approx. every 2 year a major release to production and regular minor security related fixes that do not need downtime. Downtime is the worst for a validator, you will lose attestations and money if not scheduled and planned accordingly. Why not Ubuntu? I am fine with Ubuntu on my desktop but they push every 2nd or 3rd day new kernels which is a total no-go on a validator.

One of my validtor is based on Debian (stable branch) in a redundant dual-bay 2.5" SSD (2 Western Digital RED) to 3.5" [hardware RAID1 mirrored enclosure](https://www.startech.com/en-ch/hdd/35sat225s3r). I keep my Debian linux up to date using regular '$ apt-get -u upgrade && apt-get -u dist-upgrade' jobs that pull the latest packages from the main, contrib and most importantly from the security archives. I use Debian as they developed the most reliable package system and they follow the most reliable release politics, apart from that, Debian is the mother of numerous clone distributions.
Packages required to use the scripts in my repository:
```
apt-get install dialog speedometer bashtop iptraf-ng nmon net-tools ntpdate fail2ban ufw rcs ufw tuptime ksh curl net-tools systemd-timesyncd.
```
Your system time need to be ideally synced against an NTP timeserver. Howto setup your timesync is widely documented. A short summary as follows:
```
systemd-timesyncd (simple NTP system client)
systemctl list-units -t service | grep systemd-timesyncd.service
vi /etc/systemd/timesyncd.conf (NTP server, check https://www.ntppool.org, use main and fallback servers)
restarting: systemctl restart systemd-timesyncd.service
cfg check : timedatectl show-timesync --all
testing   : timedatectl timesync-status 
```
Ensure when fine-tuning that timesyncd is up & running and in best-case synced against a Stratum 1 server that you find at ntppool.org (timedatectl timesync-status). Some admins also forget to open their incoming NTP port for UDP after setting their rules to denying incoming traffic (also missed in some of the validator install scripts that are floating around). In large datacenters, hardware clocks are set to UTC which just makes sense in distributed networks. An unacceptable NTP offset value in milliseconds is any value that falls outside the range of -128ms to 127ms. I currently see on one of my validators the offset is 1.15ms which is great. 
#### Execution and Consensus Layer
[Go-eth execution client](go-pulse.sh), [Prysm consenus client](prysm-beacon.sh) and [Prysm validator client](prysm-validator.sh) are running in a GNU Screen held docker containers that I manually [pruned](prune-and-purge.sh) from time to time. I also ensure every once in a while that I pull the latest docker packages by stoping the validator, prune and remove all docker images to enforce the re-downloading of the latest vesions when restarting the node.
```
docker container prune -f
docker stop go-pulse <execution-client> <consensus-client> <validator-client>
docker rm go-pulse <execution-client> <consensus-client> <validator-client>
docker system prune -a
docker rmi <execution-client> <consensus-client> <validator-client>
```
Please refer to the geth manual in order to find out more information about [pruning](https://geth.ethereum.org/docs/fundamentals/pruning).
#### Security
You will find in the github repo a [firewall.sh](firewall.sh) script which gives you an idea how to lockdown your pulsechain validator node. Also stop and disable all unwanted services on the server and close unused ports. 

If you run a validator in the public cloud, do not leave your keystore.json files on the server. It contains your encrypted private keys. Keep backups of your keystore files in an encrypted offline cold storage (e.g. in a gpg file) or secure it through a hardware wallet.

I also run my validator behind a physical router firewall and an additional linux software firewall in detached GNU screen sessions that can be re-attached remotely using [screenie](https://marcgloor.github.io/screenie.html), a GNU screen wrapper that I wrote 20 years ago.

#### Disaster Recovery, Rollback and Business Continuity
The goal is Fives Nines high availablility, the lowest MTTR and the highest MTBF.

You should also ensure and track your historical and statistical real time data of the system with the linux commands [hm](https://marcgloor.github.io/hourmeter.html) and [tuptime](https://packages.debian.org/stable/tuptime). I also keep an /etc/history file on every server as a log of server specific milestones, incidents or issues.
```
$ cat /etc/history
hm>   32h / 12-Dec-2023 Start of Operations / Validator activated 03:15am CET
hm>  153h / 17-Dec-2023 Validator registered / set online 03:45am CET

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
My pulsechain validator disk that is holding the full-synced blockchain data structure is part of an enterprise level high-avalability capable ZFS diskarray that is software RAID1 mirrored among two physical 8TB SSD disks. From the respective pulsechain dataset, a time triggered crontab job is generating regular snapshots in a 10min interval for up to 10 days. Using ZFS snapshots allows you to quickly redirect a new symlink (ln -s) to your mounted pulsedchain root directory in case of an incident such as e.g. a corrupted consensus or execution database. This way, you can rollback the entire validator on the timeline back to a desired point in history (like a time capsule on a filesystem level). For example, rolling back a 1TB blockchain validator takes a couple of seconds using copy-on-write technique rather than hours using conventional tools such as dd, rsync, scp, cp or tar commands.

#### Monitoring:
Currently I use [MRTG](https://oss.oetiker.ch/mrtg) developed at ETH Zurich and my [pulsechain rotation monitor](rotmon.sh). However, there are more specific monitoring solutions available to monitor your validator.

PulseChain Validator Telemetry: I wrote [pvt.ksh](pvt.ksh), a korn-shell script that queries the validator status and forecasts the recovery Time-to-Maturity for a validator that was falling behind the 32m balance.

![Console](https://github.com/marcgloor/pulsechain/blob/main/pvttm-1.13.png "Pulsechain Time To Maturity Forecasting")

The script alternatively uses the official [PulseChain beacon](https://beacon.pulsechain.com/validators) or [G4MM4's RPC-JSON API Endpoint](https://www.g4mm4.io) to query the validator data. However, I will enrich the script going forward to be supporting the configuratio and launch via commandline args in order so support multiple validator checks. Feel free to send me diff patches if you have smart ideas.

### Networking
<update-follows>

#### Failover / BCP
I got a second spare (slave) internet router that is identical to my (master) router

#### Regular latency checks 
Bandwith of 1000 Mbit/s. Measure using the tool speedtest. 

#### Routing 
Access to a configurable router for firewall, static routes and port-forwarding (even to temporarily activate a DMZ to your validator if needed).

#### IP Address
Static IP (I don't have one but I use dynamic DNS and homebuilt scripts to mitigate unforseen effects should my ISP or my router change the IP address (e.g. via DHCP after a lease expired). I also log my public IP address using the attached crontab job, see [etc-crontab](etc-crontab) and search for 'Daily IP watchlog'.

