#!/bin/bash
# 
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)

# Config
PKG_VERSION="2.5.5" #Bump this everytime you update something.


#DO NOT TOUCH! (Unless you have a good reason...)
#Variable format is "PKG_FIELDNAME"

PKG_DESCRIPTION="Some tweaks may break jailbreaks. Let this tweak say
  \"You Shall Not Pass!\" to incompatible tweaks and you can sit back and have
  fun with your jailbreak."
PKG_DEPICTION="https://ethanrdoesmc.github.io/gandalf/depictions/?p=io.github.ethanrdoesmc.gandalf102"
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_ARCHITECTURE='iphoneos-arm'

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)

#Main script

#Sanity Checks
if [ -z "$1" ]; then
  echo "${BOLD}Usage:${NORMAL} './build.sh <version>'"
  exit 0
fi

if [ ! -d "$1" ] || [ ! -f "$1/conflicts.txt" ] || [ ! -f "$1/firmware.txt" ] || [ ! -f "$1/name.txt" ] || [ ! -f "$1/replaces.txt" ] || [ ! -f "$1/section.txt" ]; then
	echo "${BOLD}${RED}ERROR:${NORMAL} Please check if these files or folders exist:"
	echo 
	echo " - $1"
	echo " - $1/conflicts.txt"
	echo " - $1/firmware.txt"
	echo " - $1/name.txt"
	echo " - $1/replaces.txt"
	echo " - $1/section.txt"
	exit 1
fi

#Confirmation to continue
read -p "${BOLD}Packaging ${PKG_NAME} will start. Press any key to continue...${NORMAL}"

FIRMWARE=$(cat $1/firmware.txt)
CONFLICTS_FILE="$1/conflicts.txt"

PKG_PACKAGE="io.github.ethanrdoesmc.gandalf$1"
PKG_PACKAGE_REGEX="io\.github\.ethanrdoesmc\.gandalf$1"
PKG_NAME="Gandalf for $(cat $1/name.txt)"

# for security add a allow-multiple-installs parameter. It won't add all other Gandalf version to the replaces section. 
if [ "$2" != "allow-multiple-installs" ]; then 
 # Check if the version we are currently building is added to all_versions.txt

 # First remove all possible spaces at the end of the line to make the $ (anchor for end of line) work

 sed -i 's/ *$//' all_versions.txt

 if [ "$(cat all_versions.txt | grep ${PKG_PACKAGE_REGEX}$)" = "" ]; then
   echo "Adding currently building version to all_versions.txt..."
   printf "${PKG_PACKAGE}\n" >> all_versions.txt

 fi

 # Set and make tempdir. Thanks to https://unix.stackexchange.com/a/84980
 # should work on macOS and Linux. 

 GDN_TEMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir.XXXXXX')

 # Get all Gandalf versions, except the one we are building, parse them in one line and save them in the variable "OTHER_VERSIONS"

 OTHER_VERSIONS=$(cat all_versions.txt | grep -v ${PKG_PACKAGE_REGEX}'$')

 # Save them in a temporary file
 printf "${OTHER_VERSIONS}\n" > $GDN_TEMPDIR/tmp_replaces.tmp
 # Add all packages which are in replaces.txt to the temporary file
 cat $1/replaces.txt >> $GDN_TEMPDIR/tmp_replaces.tmp
 # Sort them, parse them in one line and save them in "PKG_REPLACES"

 PKG_REPLACES=$(cat $GDN_TEMPDIR/tmp_replaces.tmp | sort | sed ':a;N;$!ba;s/\n/,\ /g')

else 
 read -p "--- You are now building gandalf without adding all other versions to the REPLACES section. Press any key to continue. ---"
 PKG_REPLACES=$(cat $1/replaces.txt | sed ':a;N;$!ba;s/\n/,\ /g')

fi

PKG_SECTION=$(cat $1/section.txt)
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed ':a;N;$!ba;s/\n/,\ /g')
PKG_DEPENDS="firmware ${FIRMWARE}, sudo, com.officialscheduler.mterminal, mobilesubstrate"

#Start message
echo "Started packaging ${PKG_NAME}"

#Prepare the package structure
echo "Creating package structure..."

mkdir "${PKG_PACKAGE}"
mkdir "${PKG_PACKAGE}/DEBIAN"
mkdir -p "${PKG_PACKAGE}/usr/bin"
mkdir -p "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Create the control file
echo "Creating the control file..."

cat <<EOF > "${PKG_PACKAGE}/DEBIAN/control";
Package: ${PKG_PACKAGE}
Name: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${PKG_ARCHITECTURE}
Replaces: ${PKG_REPLACES}
Description: ${PKG_DESCRIPTION}
Depiction: ${PKG_DEPICTION}
Maintainer: ${PKG_MAINTAINER}
Author: ${PKG_AUTHOR}
Depends: ${PKG_DEPENDS}
Section: ${PKG_SECTION}
Breaks: ${PKG_BREAKS}
EOF

#Compress the application
echo "Compressing and moving Gandalf.app..."

tar -czf "Gandalf.app.tar.gz" "Gandalf.app"
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf/"

#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cp "gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable 
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"

#macOS issues fix
find . -type f -name '.DS_Store' -exec rm {} +

#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"
rm -rf "${GDN_TEMPDIR}"

echo "Packaging done."
echo "Filename: ${BOLD}${PKG_PACKAGE}.deb${NORMAL}"
