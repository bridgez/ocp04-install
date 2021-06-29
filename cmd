ocp_path=/data/ocp/ocp0628; mkdir -p $ocp_path; cd $ocp_path
curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable-4.7/release.txt |awk '/Name:/{print $NF}' 
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.7.16/openshift-install-linux.tar.gz; tar xvf openshift-install-linux.tar.gz 
./openshift-install create manifests 
./openshift-install create ignition-configs

dnf install -y httpd
mkdir /var/www/html/ignitions/
/usr/bin/cp  *ign /var/www/html/ignitions/
chmod 755 /var/www/html/ignitions/*
systemctl enable httpd --now

dnf install -y haproxy
wget  https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.7/4.7.13/rhcos-4.7.13-x86_64-live.x86_64.iso


for i in 159 160 161 162
do
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i power off
sleep 2
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i chassis bootdev cdrom #disk/pxe
sleep 1
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i power on
done

for i in 159 160 161 162
do
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i power off
sleep 2
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i chassis bootdev disk
sleep 1
ipmitool -I lanplus -U admin -P password  -H 127.0.0.1 -p 3$i power on
done

./openshift-install wait-for bootstrap-complete --log-level=debug 
./openshift-install wait-for install-complete --log-level=debug 

wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.7/openshift-client-linux-4.7.16.tar.gz -P /tmp

