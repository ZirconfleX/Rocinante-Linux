#!/bin/bash

# Script modified by Marc Defossez, Jan 2024
# Add Linux Mint 20, 20.01, 20.02 and 20.03 to the list of supported OSses.
# Done this because Linux Mint is a full compatible OS with Ubuntu.
# Mint versions use all a LTS version of Ubuntu.
# Example Linux Mint 20, 20.01, 20.02 and 20.03 are all build on Ubuntu 20.04
#
#PetaLinux environment setup script
#original version by Tony McDowell (tmcdowe@xilinx.com)
#updated version by Sandeep Gundlupet Raju (sandeep.gundlupet-raju@xilinx.com)

# Enable debug=1 mode -- this disables actual changes on the host machine using dry-run options.
# Disable debbug=0 to proceed with installation
debug=0;

#get OS pretty name
osPrettyName=`cat /etc/os-release | grep PRETTY_NAME | sed 's/.*="\(.*\)"/\1/'`;
centosVersion=`cat /etc/centos-release | sed 's/[^0-9.]*\([0-9.]*\).*/\1/'`;
osKernelVer=`uname -r`

echo "***************************************************************";
echo "PetaLinux Environment Setup Tool";
echo "Running on $osPrettyName ($osKernelVer)";
echo "***************************************************************";
#print the debug message header
if [ $debug -eq 1 ]; then echo "***DEBUG MODE ON!***"; fi;
echo " "

echo -n "NOTE: Check for superuser..."
#get the actual user
if [ $SUDO_USER ]; then actualUser=$SUDO_USER; else actualUser=`whoami`; fi
#get the effective user
currentUser=`whoami`
if [ $currentUser != "root" ]; then echo "FAILED! \r\n Please re-run this script as sudo"; exit 1; else echo "SUCCESS! (from "$actualUser")"; fi;

#determine the host OS from the pretty_name
if [[ $(echo $osPrettyName | grep buntu) ]]; then
	hostOS="ubuntu";
	#echo "Running on Ubuntu";
elif [[ $(echo $osPrettyName | grep -e Mint -e 20) ]]; then
	hostOS="ubuntu";
	#echo "Running on Linux Mint";
elif [[ $(echo $osPrettyName | grep CentOS) ]]; then
	hostOS="centos";
	echo "Running on CentOS version $centosVersion";
elif [[ $(echo $osPrettyName | grep "Red Hat") ]]; then
	hostOS="rhel";
	#echo "Running on Red Hat";
else
	echo "ERROR: Cannot determine host operating system!"
	echo "This script is only supported on Ubuntu, CentOS, and RHEL Linux distribution!"
	exit 1;
fi;

#update shell on UBUNTU only
#place this portion near the start of the script so that it runs before sudo expires if package installation takes a long time
if [ $hostOS == "ubuntu" ]; then
	echo -n "NOTE: Checking for DASH shell as default (Ubuntu only)...";
	if echo `echo $0` | grep 'dash'; then
		echo "FOUND!";
		echo -n "NOTE: Changing default shell to from DASH to BASH...";
		export DEBIAN_FRONTEND=noninteractive;
		export DEBCONF_NONINTERACTIVE_SEEN=true;

		echo "dash dash/sh boolean false" | debconf-set-selections;
		dpkg-reconfigure dash;

		unset DEBIAN_FRONTEND;
		unset DEBCONF_NONINTERACTIVE_SEEN;
		echo "DONE!";
		echo "INFO: You must log out of this shell and back in for change to take effect";
	else
		echo "NOT FOUND!";
	fi;
fi;

echo "INFO: Shell update done!";
