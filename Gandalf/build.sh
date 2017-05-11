#!/bin/bash
# 
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)

if [ "${1}" == "" ]
 then
   echo "USAGE: './build.sh version (directory name)'"
   echo "ERROR: please specify the version."
   exit 1
fi

# Check if directory exists
if [ ! -d "${1}" ] 
 then
   echo "FATAL ERROR: Directory ${1} doesn't exist."
   echo "Please check your spelling (linux is case sensitive)."
   echo "Abort."
   exit 1
fi

# change directory
cd ${1}

# Get configuration
source config.conf

# Set variables
PKG_MAINTAINER="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_AUTHOR="EthanRDoesMC <ethanrdoesmc@gmail.com>"
PKG_ARCHITECTURE='iphoneos-arm'
# Parse conflicts
CONFLICTS_FILE="conflicts.txt"
PKG_BREAKS=$(cat ${CONFLICTS_FILE} | sed ':a;N;$!ba;s/\n/,\ /g')


#Main script

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
# Workaround for tar
cd ..
tar -czf "${1}/Gandalf.app.tar.gz" "Gandalf.app"
cd ${1}
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cp "../gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable 
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "../prerm" "${PKG_PACKAGE}/DEBIAN"
cp "../postinst" "${PKG_PACKAGE}/DEBIAN"

bold=$(tput bold)
normal=$(tput sgr0)
echo 
echo "|"
echo "|--- If you have anything else you need to put into Gandalf, just add it now. ---"
echo "|"
echo "| --- ${bold}If you're finished press any key to continue. If you don't want to add anything just press any key now. ---${normal}"
echo "|"
echo
read -p "Press any key to continue... "
echo
 
#Remove macOS related stuff to avoid braking packages - thanks to 1Conan
find . -type f -name '.DS_STORE' -exec rm {} +
#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"

echo "Packaging done."
echo "Filename: ${PKG_PACKAGE}.deb"
echo "Move ${PKG_PACKAGE}.deb to Gandalf folder..."
mv ${PKG_PACKAGE}.deb ../${PKG_PACKAGE}.deb
