#!/bin/bash
#
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)

# Config

#DO NOT TOUCH! (Unless you have a good reason...)
#Variable format is "PKG_FIELDNAME"

PKG_DESCRIPTION="Some tweaks may break jailbreaks. Let this tweak say \"You Shall Not Pass!\" to incompatible tweaks and you can sit back and have fun with your jailbreak."
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_ARCHITECTURE='iphoneos-arm'

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)

# check if dpkg-deb is not installed
if [ $(command -v dpkg-deb > /dev/null; echo $?) -ne "0" ]; then
  echo "${RED}FATAL:${NORMAL} dpkg-deb is not installed. You will not be able to make the deb package."
  echo "Please install dpkg-deb. (Google how to do that. We can not tell you how to do that exactly, since it depends on your distribution.)"
  exit 1
fi
#Main script

#Sanity Checks
if [ -z "$1" ]; then
  echo "${BOLD}Usage:${NORMAL} './build.sh <version>'"
  exit 0
fi

if [ ! -d "$1" ] || [ ! -f "$1/conflicts.txt" ] || [ ! -f "$1/config.cfg" ] || [ ! -f "$1/replaces.txt" ]; then
  echo "${BOLD}${RED}ERROR:${NORMAL} Please check if these files or folders exist:"
  echo
  echo " - $1"
  echo " - $1/conflicts.txt"
  echo " - $1/replaces.txt"
  echo " - $1/config.cfg"
  exit 1
fi
# read config file, print only the line containing 'NAME:' (the ^ represents beginning of line, if we don't add this it might also match 'N0NAME:' etc.), now delete everything before and after the ' " ' and voila: we have the value.
PKG_NAME="Gandalf for $(cat $1/config.cfg | grep '^NAME:' | sed -e 's/^NAME:\ *\"//;s/\".*//' )"
#Confirmation to continue
# read -p "${BOLD}Packaging ${PKG_NAME} will start. Press any key to continue...${NORMAL}"

echo "${BOLD}Packaging ${PKG_NAME} will start...${NORMAL}"
FIRMWARE=$(cat $1/config.cfg | grep '^FIRMWARE:' | sed -e 's/^FIRMWARE:\ *\"//;s/\".*//')
FIRMWARE=$(echo "($FIRMWARE)")
CONFLICTS_FILE="$1/conflicts.txt"

PKG_PACKAGE="io.github.ethanrdoesmc.gandalf$1"
PKG_PACKAGE_REGEX="io\\.github\\.ethanrdoesmc\\.gandalf$1"

# Set and make tempdir. Thanks to https://unix.stackexchange.com/a/84980
# should work on macOS and Linux.
GDN_TEMPDIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir.XXXXXX')

# for security add a allow-multiple-installs parameter. It won't add all other Gandalf version to the replaces section.
if [ "$2" = "allow-multiple-installs" ]; then
  read -p "--- You are now building gandalf without adding all other versions to the REPLACES section. Press any key to continue. ---"
  PKG_REPLACES=$(cat $1/replaces.txt | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/, /g')

else

  # Check if the version we are currently building is added to all_versions.txt

  # First remove all possible spaces at the end of the line to make the $ (anchor for end of line) work
  cat all_versions.txt | tr -d " " > ${GDN_TEMPDIR}/tmp_all_versions.tmp
  cat ${GDN_TEMPDIR}/tmp_all_versions.tmp > all_versions.txt
  # sed -i  's/ *$//' all_versions.txt
  rm ${GDN_TEMPDIR}/tmp_all_versions.tmp
  if [ "$(cat all_versions.txt | grep ${PKG_PACKAGE_REGEX}$)" = "" ]; then
    echo "Adding currently building version to all_versions.txt..."
    printf "${PKG_PACKAGE}\n" >> all_versions.txt

  fi

  # Get all Gandalf versions, except the one we are building, parse them in one line and save them in the variable "OTHER_VERSIONS"

  OTHER_VERSIONS=$(cat all_versions.txt | grep -v ${PKG_PACKAGE_REGEX}'$')

  # Save them in a temporary file
  printf "${OTHER_VERSIONS}\n" > $GDN_TEMPDIR/tmp_replaces.tmp
  # Add all packages which are in replaces.txt to the temporary file
  cat $1/replaces.txt >> $GDN_TEMPDIR/tmp_replaces.tmp
  # Sort them, parse them in one line and save them in "PKG_REPLACES"

  PKG_REPLACES=$(cat $GDN_TEMPDIR/tmp_replaces.tmp | sort | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/, /g' )

fi

# Get the values of the config file and save them in the matching variable
# Check if configfile is valid
# Make sure that we can get the exitcode of a command in the pipe which failed
set -o pipefail

cat $1/config.cfg | grep '^BUILD:' | sed -e 's/^BUILD:\ *\"//;s/\".*//' >> /dev/null
if [ "$?" -ne "0" ]; then
  echo "${RED}ERROR:${NORMAL} Config file $1/config.cfg is invalid! Check line VERSION:"
  exit 1
fi
cat $1/config.cfg | grep '^SECTION:' | sed -e 's/^SECTION:\ *\"//;s/\".*//' >> /dev/null
if [ "$?" -ne "0" ]; then
  echo "${RED}ERROR:${NORMAL} Config file $1/config.cfg is invalid! Check line SECTION:"
  exit 1
fi
cat $1/config.cfg | grep '^NAME:' | sed -e 's/^NAME:\ *\"//;s/\".*//' >> /dev/null
if [ "$?" -ne "0" ]; then
  echo "${RED}ERROR:${NORMAL} Config file $1/config.cfg is invalid! Check line NAME:"
  exit 1
fi
cat $1/config.cfg | grep '^FIRMWARE:' | sed -e 's/^FIRMWARE:\ *\"//;s/\".*//' >> /dev/null
if [ "$?" -ne "0" ]; then
  echo "${RED}ERROR:${NORMAL} Config file $1/config.cfg is invalid! Check line FIRMWARE:"
  exit 1
fi
cat $1/config.cfg | grep '^DEPICTION:' | sed -e 's/^DEPICTION:\ *\"//;s/\".*//' >> /dev/null
if [ "$?" -ne "0" ]; then
  echo "${RED}ERROR:${NORMAL} Config file $1/config.cfg is invalid! Check line DEPICTION:"
  exit 1
fi
# Read configfile, get the right line, and remove everything before the " and after the " -> we now have the value in between the "
PKG_VERSION=$(cat $1/config.cfg | grep '^BUILD:' | sed -e 's/^BUILD:\ *\"//;s/\".*//' )
PKG_SECTION=$(cat $1/config.cfg | grep '^SECTION:' | sed -e 's/^SECTION:\ *\"//;s/\".*//' )
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/, /g')
PKG_DEPENDS="firmware ${FIRMWARE}, sudo, com.officialscheduler.mterminal, mobilesubstrate"
PKG_DEPICTION=$(cat $1/config.cfg | grep '^DEPICTION:' | sed -e 's/^DEPICTION:\ *\"//;s/\".*//')
#Start message
echo "Started packaging ${PKG_NAME}"

#Prepare the package structure
echo "Creating package structure..."

mkdir "${PKG_PACKAGE}"
mkdir "${PKG_PACKAGE}/DEBIAN"
mkdir -p "${PKG_PACKAGE}/usr/bin"
mkdir -p "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"
mkdir -p "${PKG_PACKAGE}/etc/gandalf/"

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

tar -czf "GandalfApp.app.tar.gz" "GandalfApp.app"
mv "GandalfApp.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf/"

#Copy over the executable
echo "Bundling executable..."

cp "gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"

#Make the property file for the GandalfApp (includes Version and bundle Identifier from gandalf tweak) (for the update function)

cat <<EOF > "${PKG_PACKAGE}/etc/gandalf/properties.plist";
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Version</key>
	<string>${PKG_VERSION}</string>
	<key>BundleIdentifier</key>
	<string>${PKG_PACKAGE}</string>
</dict>
</plist>

EOF
#macOS issues fix
find . -type f -name '.DS_Store' -exec rm {} +

#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"
# Check if packaging was not successful; First save exitcode of dpkg-deb in variable to make it possible to better work with it.

DPKG_ERRORCODE=$(echo $?)
if [ "${DPKG_ERRORCODE}" -ne "0" ]; then
  echo "${RED}FATAL:${NORMAL} dpkg-deb exited with error code '${DPKG_ERRORCODE}'. Build was most likely NOT successful."
  echo "Deleting temporary folder '${GDN_TEMPDIR}'"
  echo "Please also check if all_versions.txt file is corrupted."
  rm -rf "${GDN_TEMPDIR}"
  exit ${DPKG_ERRORCODE}
fi

#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"
rm -rf "${GDN_TEMPDIR}"

echo "Packaging done."
echo "Filename: ${BOLD}${PKG_PACKAGE}.deb${NORMAL}"
