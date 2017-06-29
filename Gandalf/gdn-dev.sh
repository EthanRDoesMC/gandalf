#!/bin/bash
# This script is the main script for managing the repository
# You can: Create new gandalf versions, push all gandalf versions to the repo and compile all versions of gandalf with this script.
# Style
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)

# Check if script is launched without parameters and output error.
if [ "$1" = "" ]; then
 echo "${BOLD}USAGE:${NORMAL} '$0 <option>'"
 exit 1
fi
# Regular expression of gandalf bundle identifier, we need 2 '\' because bash eats up the first one. 
PACKAGE_REGEX="io\\.github\\.ethanrdoesmc\\.gandalf"
# Functions

function build_all () {
  # build_all: Build all gandalf versions at once
  echo "Building all gandalf versions..."
  # Get number of lines of the file all_versions.txt and save them in a variable (uncomment for debug)
  # echo "We currently have $(wc -l < all_versions.txt) known Gandalf versions."
  # First remove all possible spaces at the end of the line to make the $ (anchor for end of line) work
  sed -i 's/ *$//' all_versions.txt
  # Get shortname of versions in all_versions.txt by deleting io.github.ethanrdoesmc.gandalf and compile gandalf as long as there is still a version --Comment not good, please edit--

  for VERSION in $(cat all_versions.txt | sed "s/^${PACKAGE_REGEX}//g"); do
   ./build.sh "${VERSION}"

   # Check if packaging was not successful; First save exitcode of build.sh in variable to make it possible to better work with it. 
   BUILDSH_ERRORCODE=$(echo $?)

   if [ "${BUILDSH_ERRORCODE}" -ne "0" ]; then
    echo "${RED}FATAL:${NORMAL} build.sh exited with error code '${BUILDSH_ERRORCODE}'. Build was most likely NOT successful."
    exit ${BUILDSH_ERRORCODE}
   fi
  done
}

# Main Switch: check with which parameter script is launched
case $1 in
"compile-for-repo")
  # check if we're running the script on an iPhone/iPad/iPod with uname -m 
  if [[ "$(uname -m)" =~ iPhone.* || "$(uname -m)" =~ iPad.* || "$(uname -m)" =~ iPod.* ]]; then
    # Output warning
    echo "${RED}Note: if you're on iOS this will most likely fail.${NORMAL} Do you want to continue?"
    echo "Please select one number of the following options:"
    # Ask if you want to continue to build
    select CHOICE in "Yes" "No"; do
    # check which answer was given  
    case $CHOICE in
        Yes)
          echo "Continue..."
          break # get out of this select loop
        ;;
        No)
          echo "Exit..."
          exit 1 # exit the loop
        ;;
      esac
    done
  fi
  # Compile all known gandalf versions
  build_all
  # Move all debs to repo
  echo "Move packages to repo..."
  mv *.deb ../docs/debs/
  echo "Update repo..."
  # Remove old files
  rm ../docs/Packages
  rm ../docs/Packages.gz
  rm ../docs/Packages.bz2
  # Create repo structure
  dpkg-scanpackages ../docs/debs > ../docs/Packages
  # Check if dpkg-scanpackages was not successful
  DPKG_SCANPKGERRORC=$(echo $?)
  if [ "$DPKG_SCANPKGERRORC" -ne "0" ]; then
   echo "${RED}ERROR:${NORMAL} dpkg-scanpackages exited with errorcode '${DPKG_SCANPKGERRORC}'. Repo is most likely NOT useable. Please contact us on GitHub."
  fi
  gzip -c9 ../docs/Packages > ../docs/Packages.gz
  bzip2 -c9 ../docs/Packages > ../docs/Packages.bz2
;;

"compile-all")
  # Compile all known gandalf versions
  build_all
;;

"new")
  # Create new gandalf version
  read -p "Please enter shortname (eg. 'c'):" FOLDER_NAME
  echo ${FOLDER_NAME}
  mkdir ${FOLDER_NAME}
  read -p "Please enter the supported firmware (format: =10.2 or <8.4):" FILE_FIRMWARE
  printf "(${FILE_FIRMWARE})" > ${FOLDER_NAME}/firmware.txt
  echo "Gandalf is usually named after a jailbreak: Gandalf for <jailbreakname>. So: "
  read -p "Please enter the name of the jailbreak here:" FILE_NAM
  printf "${FILE_NAME}" > ${FOLDER_NAME}/name.txt
  read -p "Please enter the section now:" FILE_SECTION
  printf "${FILE_SECTION}" > ${FOLDER_NAME}/section.txt
  echo "Now there comes the most important step: you must now add all bundle identifiers to the file conflicts.txt."
  read -p "--- Press any key to continue --- "
  nano ${FOLDER_NAME}/conflicts.txt
  read -p "--Now please add the tweaks which should be removed if Gandalf is installed. Press any key to continue. --"
  nano ${FOLDER_NAME}/conflicts.txt
  echo "Starting to build current version..."
  # Add version to all_versions.txt
  printf "io.github.ethanrdoesmc.gandalf${FOLDER_NAME}\n" >> all_versions.txt
  ./build.sh ${FOLDER_NAME}
  build_all
;;

"clean")
  # Sort file contents alphabetically
  # Set and make tempdir. Thanks to https://unix.stackexchange.com/a/84980
  # should work on macOS and Linux.

  TEMPDIRECTORY=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir.XXXXXX')
  # Sort versions in all_versions.txt alphabetically. 
  echo 'Sorting all_versions.txt...'
  cat all_versions.txt > ${TEMPDIRECTORY}/all_versions.txt
  cat ${TEMPDIRECTORY}/all_versions.txt > all_versions.txt
  # Clean all_versions.txt
  echo 'Removing all possible spaces at the end of the line to make the $ (anchor for end of line) work'
  sed -i 's/ *$//' all_versions.txt
  # Get shortname of versions in all_versions.txt by deleting io.github.ethanrdoesmc.gandalf; Sort conflicts.txt and replaces.txt of every known version. 
  echo "Sorting packages in conflicts.txt and replaces.txt"
  for VERSION in $(cat all_versions.txt | sed "s/^${PACKAGE_REGEX}//g"); do
  # output file content, sort them, save them to a temporary file, and rewrite them back
   cat ${VERSION}/conflicts.txt | sort > ${TEMPDIRECTORY}/conflicts.txt
   cat ${TEMPDIRECTORY}/conflicts.txt > ${VERSION}/conflicts.txt
   cat ${VERSION}/replaces.txt | sort > ${TEMPDIRECTORY}/replaces.txt
   cat ${TEMPDIRECTORY}/replaces.txt > ${VERSION}/replaces.txt
  done
  # Cleanup
  echo "Cleaning up temporary folder..."
  rm -rf  ${TEMPDIRECTORY}
;;

"setup-mac")
  # To be done...
  echo "This will once setup your Mac, so that you can compile gandalf on it."
;;

*)
  echo "${RED}ERROR:${NORMAL} Unknown parameter '$1'."
;;

esac
