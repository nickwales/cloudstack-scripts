#!/bin/sh

## cloudstack host cleanup script


service cloud-agent stop

yum remove cloud-agent -y


# Find and destroy any virt storage pools
pool_count=`virsh pool-list | grep active | awk $'{print $1}' | wc -l`

for i in `seq 1 $pool_count`
do 
	pool=`virsh pool-list | grep active | awk $'{print $1}' | head -1`
	virsh pool-destroy $pool
done

rm -rf /etc/cloud/*

# Delete any associated xml files

rm -rf /etc/libvirt/storage/*.xml

# Create the images folder
mkdir -p /var/lib/libvirt/images


# Remove any nfs mounts from mtab

sed -i '/cloudstack/d' /etc/mtab


# Unmount anything in /mnt and delete the mount point

umount /mnt/*

rm -rf /mnt/*

# Restart libvirt

service libvirtd restart

# Re-install cloud-agent

yum install -y cloud-agent

# Edit the cloud-agent properties file

cat << 'EOF' >> /etc/cloud/agent/agent.properties
guest.network.device=public
private.network.device=private
public.network.device=public
EOF


service cloud-agent start