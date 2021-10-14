#!/bin/bash
NUM=$1 
ISO=/home/rhel-8.4-x86_64-dvd.iso
IMG_PATH=/home/kvm
GW=10.0.0.1
DNS=10.0.0.1

pre_check()
{
virsh list --all|grep node$NUM
if [ $? -eq 0 ];then
    virsh destroy node$NUM
    virsh undefine node$NUM
fi
}

ks_create()
{
cat > /tmp/ks$NUM.cfg << EOF
#install
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
#url --url="http://192.168.122.1/cdrom"

graphical
# repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream
# Keyboard layouts
keyboard --xlayouts='us'


# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# Reboot after installation
reboot
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=ens3 --gateway=$GW --ip=10.0.0.$NUM --nameserver=$DNS --netmask=255.255.255.0 --ipv6=auto --activate  
network  --hostname=node$NUM.ocp0209.nip.io

# Root password
rootpw --iscrypted \$6\$bkhALDhuppF0ExEU\$5Fa6R40H2j7DuaEQihaNjmqtvtp8dKstTNvjGY3fdsMmvvSoQSQ6CJ.zlZbaMaQrMtTR5ZTvwFOWp1liYSKYN/
# System services
services --enabled="chronyd"
firewall --disabled
selinux --disabled
# System timezone
timezone Asia/Shanghai --isUtc

# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=vda
#System Bootloader configuration
bootloader --location=mbr
#Clear the Master Boot Record
zerombr
#Partition clearing information
clearpart --all --initlabel 
#bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=lvm

%packages
@^server-product-environment

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

#skipx

%post  --log=/var/log/kickstart_post.log
grubby --update-kernel=ALL --args="console=ttyS0"
# yes | /bin/ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
mkdir /root/.ssh
chmod 700 /root/.ssh
 echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKksR6mvfck7taVyQk8ArtEdDqUJ8G9o3TZ6c7vfaX6WLj5KqN2yS5VFPGC0J+jVGPChl4zJQZfP9ewingN34JFkNLsIPyKl7XLOJeOlTI4vMOAua7BF2wv1594IWtFUta4HC9TYG3MaT2qG3z9qDkqqEHG0GtT8jVnK2agq5e8zKlbKbdT0ugwIm/eL2F6QIQYeBGD+9rejlHBQXMQacKfoeImH7rFePzZvPnJH8IC2xcFQHC7qqr5K0fS8fFyfHj4XcQJE8AavYrziCwQ1xmeyuj3yNJuqPee/oa5uBMkpOtG/+/3TlZLmMhSF/lrQLvXt964hzBytfZUoN6m9sH xuepz' >> /root/.ssh/authorized_keys 

echo "Kickstart post install script completed at: `date`"
echo "=============================="

%end
EOF
}

img_create()
{
cd /$IMG_PATH; qemu-img create -f qcow2 -o size=20G,preallocation=metadata node$NUM.img 20G
}

vm_create()
{
virt-install --os-variant rhel7 --name node$NUM --vcpu 2 --memory 4096 --disk $IMG_PATH/node$NUM.img --mac=00:16:3e:50:9b:`echo $NUM | awk '{printf "%x",$0}'` --location $ISO --initrd-inject=/tmp/ks$NUM.cfg --extra-args "ks=file:/ks$NUM.cfg" -x "ip=10.0.0.$NUM netmask=255.255.255.0 dns=$DNS gateway=$GW"
}
pre_check $NUM
ks_create $NUM
img_create $NUM
vm_create $NUM
