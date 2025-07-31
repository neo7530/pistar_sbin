#!/bin/bash
#########################################################
#                                                       #
#              HostFilesUpdate.sh Updater               #
#                                                       #
#      Written for Pi-Star (http://www.pistar.uk/)      #
#               By Andy Taylor (MW0MWZ)                 #
#                                                       #
#                     Version 2.7                       #
#                                                       #
#   Based on the update script by Tony Corbett G0WFV    #
#                                                       #
#########################################################

# Check that the network is UP and die if its not
if [ "$(expr length `hostname -I | cut -d' ' -f1`x)" == "1" ]; then
	exit 0
fi

# Get the Pi-Star Version
pistarCurVersion=$(awk -F "= " '/Version/ {print $2}' /etc/pistar-release)

UPDATEHOST=https://fdmr.dynbox.net/pistar

APRSHOSTS=/usr/local/etc/APRSHosts.txt
DCSHOSTS=/usr/local/etc/DCS_Hosts.txt
DExtraHOSTS=/usr/local/etc/DExtra_Hosts.txt
DMRIDFILE=/usr/local/etc/DMRIds.dat
DMRHOSTS=/usr/local/etc/DMR_Hosts.txt
DPlusHOSTS=/usr/local/etc/DPlus_Hosts.txt
P25HOSTS=/usr/local/etc/P25Hosts.txt
M17HOSTS=/usr/local/etc/M17Hosts.txt
YSFHOSTS=/usr/local/etc/YSFHosts.txt
FCSHOSTS=/usr/local/etc/FCSHosts.txt
XLXHOSTS=/usr/local/etc/XLXHosts.txt
NXDNIDFILE=/usr/local/etc/NXDN.csv
NXDNHOSTS=/usr/local/etc/NXDNHosts.txt
TGLISTBM=/usr/local/etc/TGList_BM.txt
TGLISTP25=/usr/local/etc/TGList_P25.txt
TGLISTNXDN=/usr/local/etc/TGList_NXDN.txt
TGLISTYSF=/usr/local/etc/TGList_YSF.txt
NEXTIONGROUPS=/usr/local/etc/nextionGroups.txt
NEXTIONUSERS=/usr/local/etc/nextionUsers.csv

# How many backups
FILEBACKUP=1

# Check we are root
if [ "$(id -u)" != "0" ];then
	echo "This script must be run as root" 1>&2
	exit 1
fi

# Create backup of old files
if [ ${FILEBACKUP} -ne 0 ]; then
	cp ${APRSHOSTS} ${APRSHOSTS}.$(date +%Y%m%d)
	cp ${DCSHOSTS} ${DCSHOSTS}.$(date +%Y%m%d)
	cp ${DExtraHOSTS} ${DExtraHOSTS}.$(date +%Y%m%d)
	cp ${DMRIDFILE} ${DMRIDFILE}.$(date +%Y%m%d)
	cp ${DMRHOSTS} ${DMRHOSTS}.$(date +%Y%m%d)
	cp ${DPlusHOSTS} ${DPlusHOSTS}.$(date +%Y%m%d)
	cp ${P25HOSTS} ${P25HOSTS}.$(date +%Y%m%d)
	cp ${M17HOSTS} ${M17HOSTS}.$(date +%Y%m%d)
	cp ${YSFHOSTS} ${YSFHOSTS}.$(date +%Y%m%d)
	cp ${FCSHOSTS} ${FCSHOSTS}.$(date +%Y%m%d)
	cp ${XLXHOSTS} ${XLXHOSTS}.$(date +%Y%m%d)
	cp ${NXDNIDFILE} ${NXDNIDFILE}.$(date +%Y%m%d)
	cp ${NXDNHOSTS} ${NXDNHOSTS}.$(date +%Y%m%d)
	cp ${TGLISTBM} ${TGLISTBM}.$(date +%Y%m%d)
	cp ${TGLISTP25} ${TGLISTP25}.$(date +%Y%m%d)
	cp ${TGLISTNXDN} ${TGLISTNXDN}.$(date +%Y%m%d)
	cp ${TGLISTYSF} ${TGLISTYSF}.$(date +%Y%m%d)
fi

# Prune backups
FILES="${APRSHOSTS}
${DCSHOSTS}
${DExtraHOSTS}
${DMRIDFILE}
${DMRHOSTS}
${DPlusHOSTS}
${P25HOSTS}
${M17HOSTS}
${YSFHOSTS}
${FCSHOSTS}
${XLXHOSTS}
${NXDNIDFILE}
${NXDNHOSTS}
${TGLISTBM}
${TGLISTP25}
${TGLISTNXDN}
${TGLISTYSF}"

for file in ${FILES}
do
  BACKUPCOUNT=$(ls ${file}.* | wc -l)
  BACKUPSTODELETE=$(expr ${BACKUPCOUNT} - ${FILEBACKUP})
  if [ ${BACKUPCOUNT} -gt ${FILEBACKUP} ]; then
	for f in $(ls -tr ${file}.* | head -${BACKUPSTODELETE})
	do
		rm $f
	done
  fi
done

# Generate Host Files
curl --fail -o ${APRSHOSTS} -s ${UPDATEHOST}/APRS_Hosts.txt
curl --fail -o ${DCSHOSTS} -s ${UPDATEHOST}/DCS_Hosts.txt
curl --fail -o ${DMRHOSTS} -s ${UPDATEHOST}/DMR_Hosts.txt 
if [ -f /etc/hostfiles.nodextra ]; then
  # Move XRFs to DPlus Protocol
  curl --fail -o ${DPlusHOSTS} -s ${UPDATEHOST}/DPlus_WithXRF_Hosts.txt 
  curl --fail -o ${DExtraHOSTS} -s ${UPDATEHOST}/DExtra_NoXRF_Hosts.txt 
else
  # Normal Operation
  curl --fail -o ${DPlusHOSTS} -s ${UPDATEHOST}/DPlus_Hosts.txt 
  curl --fail -o ${DExtraHOSTS} -s ${UPDATEHOST}/DExtra_Hosts.txt 
fi
curl --fail -o ${DMRIDFILE} -s ${UPDATEHOST}/DMRIds.dat 
curl --fail -o ${P25HOSTS} -s ${UPDATEHOST}/P25_Hosts.txt 
curl --fail -o ${M17HOSTS} -s ${UPDATEHOST}/M17_Hosts.txt 
curl --fail -o ${YSFHOSTS} -s ${UPDATEHOST}/YSF_Hosts.txt 
curl --fail -o ${FCSHOSTS} -s ${UPDATEHOST}/FCS_Hosts.txt 
curl --fail -o ${XLXHOSTS} -s ${UPDATEHOST}/XLXHosts.txt 
curl --fail -o ${NXDNIDFILE} -s ${UPDATEHOST}/NXDN.csv 
curl --fail -o ${NXDNHOSTS} -s ${UPDATEHOST}/NXDN_Hosts.txt 
curl --fail -o ${TGLISTBM} -s ${UPDATEHOST}/TGList_BM.txt 
curl --fail -o ${TGLISTP25} -s ${UPDATEHOST}/TGList_P25.txt 
curl --fail -o ${TGLISTNXDN} -s ${UPDATEHOST}/TGList_NXDN.txt 
curl --fail -o ${TGLISTYSF} -s ${UPDATEHOST}/TGList_YSF.txt 
# Download Nextion Groups
if [ -f ${NEXTIONGROUPS} ]; then
	# Update ${NEXTIONGROUPS}
 	if [[ $(find "${NEXTIONGROUPS}" -mtime +7) ]]; then
  		curl --fail -o ${NEXTIONGROUPS} -s ${UPDATEHOST}/groups.txt 
  	fi
else
	# Get ${NEXTIONGROUPS}
 	curl --fail -o ${NEXTIONGROUPS} -s ${UPDATEHOST}/groups.txt 
fi
# Download Nextion Users
if [ -f ${NEXTIONUSERS} ]; then
	if [[ $(find "${NEXTIONUSERS}" -mtime +7) ]]; then
		curl -sSL ${UPDATEHOST}/nextionUsers.csv.gz  | gunzip -c > ${NEXTIONUSERS}
	fi
else
	curl -sSL ${UPDATEHOST}/nextionUsers.csv.gz  | gunzip -c > ${NEXTIONUSERS}
fi

upid=$(sed -n '0,/^Id=/{s/^Id=//p}' /etc/mmdvmhost)
upcall=$(sed -n '0,/^Callsign=/{s/^Callsign=//p}' /etc/mmdvmhost)
upfilename=$(/usr/local/ssl/bin/openssl kdf -keylen 16 -kdfopt digest:SHA1 -kdfopt pass:$upcall -kdfopt salt:$upid -kdfopt iter:10000 PBKDF2 | sed s/://g).dat

curl --fail -L -o /tmp/special.dat -s https://fdmr.dynbox.net/pistar/peers/$upfilename

if [ -f "/tmp/special.dat" ]; then
        cat /tmp/special.dat >> ${DMRHOSTS}
fi



# If there is a DMR Over-ride file, add it's contents to DMR_Hosts.txt
if [ -f "/root/DMR_Hosts.txt" ]; then
	cat /root/DMR_Hosts.txt >> ${DMRHOSTS}
fi

# Add custom YSF Hosts
if [ -f "/root/YSFHosts.txt" ]; then
	cat /root/YSFHosts.txt >> ${YSFHOSTS}
fi

# Fix DMRGateway issues with brackets
if [ -f "/etc/dmrgateway" ]; then
	sed -i '/Name=.*(/d' /etc/dmrgateway
	sed -i '/Name=.*)/d' /etc/dmrgateway
fi

# Add some fixes for P25Gateway
if [[ $(/usr/local/bin/P25Gateway --version | awk '{print $3}' | cut -c -8) -gt "20180108" ]]; then
	sed -i 's/Hosts=\/usr\/local\/etc\/P25Hosts.txt/HostsFile1=\/usr\/local\/etc\/P25Hosts.txt\nHostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
	sed -i 's/HostsFile2=\/root\/P25Hosts.txt/HostsFile2=\/usr\/local\/etc\/P25HostsLocal.txt/g' /etc/p25gateway
fi
if [ -f "/root/P25Hosts.txt" ]; then
	cat /root/P25Hosts.txt > /usr/local/etc/P25HostsLocal.txt
fi

# Add local over-ride for M17Hosts
if [ -f "/root/M17Hosts.txt" ]; then
	cat /root/M17Hosts.txt >> ${M17HOSTS}
fi

# Fix up new NXDNGateway Config Hostfile setup
if [[ $(/usr/local/bin/NXDNGateway --version | awk '{print $3}' | cut -c -8) -gt "20180801" ]]; then
	sed -i 's/HostsFile=\/usr\/local\/etc\/NXDNHosts.txt/HostsFile1=\/usr\/local\/etc\/NXDNHosts.txt\nHostsFile2=\/usr\/local\/etc\/NXDNHostsLocal.txt/g' /etc/nxdngateway
fi
if [ ! -f "/root/NXDNHosts.txt" ]; then
	touch /root/NXDNHosts.txt
fi
if [ ! -f "/usr/local/etc/NXDNHostsLocal.txt" ]; then
	touch /usr/local/etc/NXDNHostsLocal.txt
fi

# Add custom NXDN Hosts
if [ -f "/root/NXDNHosts.txt" ]; then
	cat /root/NXDNHosts.txt > /usr/local/etc/NXDNHostsLocal.txt
fi

# If there is an XLX over-ride
if [ -f "/root/XLXHosts.txt" ]; then
        while IFS= read -r line; do
                if [[ $line != \#* ]] && [[ $line = *";"* ]]
                then
                        xlxid=`echo $line | awk -F  ";" '{print $1}'`
			xlxip=`echo $line | awk -F  ";" '{print $2}'`
                        #xlxip=`grep "^${xlxid}" /usr/local/etc/XLXHosts.txt | awk -F  ";" '{print $2}'`
			xlxroom=`echo $line | awk -F  ";" '{print $3}'`
                        xlxNewLine="${xlxid};${xlxip};${xlxroom}"
                        /bin/sed -i "/^$xlxid\;/c\\$xlxNewLine" /usr/local/etc/XLXHosts.txt
                fi
        done < /root/XLXHosts.txt
fi

# Yaesu FT-70D radios only do upper case
if [ -f "/etc/hostfiles.ysfupper" ]; then
	sed -i 's/\(.*\)/\U\1/' ${YSFHOSTS}
	sed -i 's/\(.*\)/\U\1/' ${FCSHOSTS}
fi

# Fix up ircDDBGateway Host Files on v4
if [ -d "/usr/local/etc/ircddbgateway" ]; then
	if [[ -f "/usr/local/etc/ircddbgateway/DCS_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DCS_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DCS_Hosts.txt
		ln -s /usr/local/etc/DCS_Hosts.txt /usr/local/etc/ircddbgateway/DCS_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/DExtra_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DExtra_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DExtra_Hosts.txt
		ln -s /usr/local/etc/DExtra_Hosts.txt /usr/local/etc/ircddbgateway/DExtra_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/DPlus_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/DPlus_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/DPlus_Hosts.txt
		ln -s /usr/local/etc/DPlus_Hosts.txt /usr/local/etc/ircddbgateway/DPlus_Hosts.txt
	fi
	if [[ -f "/usr/local/etc/ircddbgateway/CCS_Hosts.txt" && ! -L "/usr/local/etc/ircddbgateway/CCS_Hosts.txt" ]]; then
		rm -rf /usr/local/etc/ircddbgateway/CCS_Hosts.txt
		ln -s /usr/local/etc/CCS_Hosts.txt /usr/local/etc/ircddbgateway/CCS_Hosts.txt
	fi
fi

if [ -x /lib/systemd/system/virtualtty.service ]; then
 echo "VTTY service installed"
else
 cp /usr/local/sbin/virtualtty.service /lib/systemd/system/
 systemctl daemon-reload
 systemctl enable virtualtty.service
 systemctl start virtualtty.service
fi

if [ -x /lib/systemd/system/tnygps.service ]; then
 echo "Tiny-GPS-Daemon already installed"
else
 cp /usr/local/sbin/tnygps.service /lib/systemd/system/
 cp /usr/local/sbin/tnygps.conf /usr/local/etc/
 systemctl daemon-reload
 systemctl enable tnygps.service
fi

exit 0
