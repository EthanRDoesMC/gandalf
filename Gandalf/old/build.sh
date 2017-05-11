#!/bin/bash
# 
# Packages "Gandalf" into a deb
#
# Follow https://google.github.io/styleguide/shell.xml
# for the most part (You can ignore some, like error checking for mv)

if [ "${1}" == "" ]
 then
	echo "USAGE: './build.sh version.conf conflictsfile.txt'"
	echo "ERROR: please specify the version."
	exit 1
 elif [ -f "${1}" ]

  then
	echo "${1} found."
        echo "Specified '${1}' as config file."
  else
	echo
	echo "--- ERROR ---"
	echo
	echo "You now have following files in the current directory:"
	echo "----------"
	ls
	echo "----------"
	echo "FATAL ERROR: ${1} not found. Please check if you have typed correctly."
	echo "Abort."
	exit 1
fi

if [ "${2}" == "" ]
 then
	echo "USAGE: './build.sh version.conf conflictsfile.txt'"
	echo "ERROR: please specify the conflicts file."
	exit 1
 elif [ -f "${2}" ]

  then
	echo "${2} found."
        echo "Specified '${2}' as conflicts file."
  else
	echo
	echo "--- ERROR ---"
	echo
	echo "You now have following files in the current directory:"
	echo "----------"
	ls
	echo "----------"
	echo "FATAL ERROR: ${2} not found. Please check if you have typed correctly."
	echo "Abort."
	exit 1
fi


# Get configuration

source ${1}
# Parse conflicts
CONFLICTS_FILE="${2}"
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

tar -czf "Gandalf.app.tar.gz" "Gandalf.app"
mv "Gandalf.app.tar.gz" "${PKG_PACKAGE}/var/mobile/Downloads/Gandalf"


#Copy over the executable
echo "Bundling ${GANDALF_COMMAND_NAME}..."

cp "gandalf" "${PKG_PACKAGE}/usr/bin"

#Make it executable 
chmod +x "${PKG_PACKAGE}/usr/bin/gandalf"

#Copy the DEBIAN scripts
echo "Copying the DEBIAN scripts"

cp "prerm" "${PKG_PACKAGE}/DEBIAN"
cp "postinst" "${PKG_PACKAGE}/DEBIAN"

echo "If you have anything else you need to put into Gandalf, now's the time. You have 15 seconds from the moment this message appears."
sleep 15

#Create the package
echo "Creating the package..."

dpkg-deb -Zgzip -b "${PKG_PACKAGE}"


#Clean up
echo "Cleaning up temporary files and folders..."
rm -rf "${PKG_PACKAGE}"

echo "Packaging done."
echo "Filename: ${PKG_PACKAGE}.deb"
