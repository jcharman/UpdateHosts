#!/bin/bash --noprofile

# Static hosts.
staticHosts=\
('10.10.1.1 router
10.10.1.2 pihole
10.10.1.12 wlc')

# Create a temporary directory.
tempDir=$(mktemp -d /tmp/updateHosts.XXXX)

# Get the current DHCP leases back from PiHole.
dhcpLeases=$(cat /etc/pihole/dhcp.leases | grep -v "*" | awk '{ print $3,$4 }')

# Create a hosts file to use.
touch $tempDir/hosts

# Change IFS so that our loops break on newline only.
oldIFS=$IFS
IFS=$'\n'

# Echo leases out to the temp directory, adding the static hosts listed.
for host in $staticHosts
do
    echo $host >> $tempDir/hosts
done

for lease in $dhcpLeases
do 
    echo $lease >> $tempDir/hosts
done

# Reset IFS.
IFS=$oldIFS

# Copy our new hosts file to /etc/hosts, backing up the original.
mv /etc/hosts /etc/hosts.old
mv $tempDir/hosts /etc/hosts

# Delete the temporary directory
rm -rf $tempDir

# Restart PiHole to pull in the new records.
pihole restartdns
