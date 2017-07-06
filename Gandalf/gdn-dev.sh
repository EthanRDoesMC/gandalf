#!/bin/bash
# This script is the main script for managing the repository in an user friendlier way. 
# You can: Create new gandalf versions, push all gandalf versions to the repo and compile all versions of gandalf with this script.
# Style
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)

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

function list_options () {
  # Print all available options on terminal
  echo
  echo "  ${BOLD}Available options:${NORMAL}"
  echo "    - '$0 compile-all' or short '$0 ca': Compile all versions of gandalf at once"
  echo "    - '$0 compile-for-repo' or short '$0 c4r': Compile all versions of gandalf at once and update repository"
  echo "    - '$0 clean' or short '$0 cln': Sort all conflicts.txt and replaces.txt alphabetically"
  echo "    - '$0 new': Create a new version of gandalf"
  echo "    - '$0 setup-mac': Doing nothing at the moment"
  echo
}

# Check if script is launched without parameters and output error and available options
if [ "$1" = "" ]; then
 echo "${BOLD}USAGE:${NORMAL} '$0 <option>'"
  list_options
 exit 1
fi
# Regular expression of gandalf bundle identifier, we need 2 '\' because bash eats up the first one. 
PACKAGE_REGEX="io\\.github\\.ethanrdoesmc\\.gandalf"


# Main Switch: check with which parameter script is launched

case $1 in
"compile-for-repo"|"c4r")
  # Check if dpkg-scanpackages exists via checking with "command -v"; if command -v exitcode != 0 then command doesn't exist output the output to the black hole /dev/null

  command -v dpkg-scanpackages >> /dev/null
  # Save exitcode in a variable
  COMMANDV_EXITC=$(echo $?)
  if [ "${COMMANDV_EXITC}" -ne "0" ]; then
    echo "${RED}FATAL:${NORMAL} dpkg-scanpackages is not installed on this system. You won't be able to update the repo."
    exit 1
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

"compile-all"|"ca")
  # Compile all known gandalf versions
  build_all
;;

"new")
  # Create new gandalf version
  # In a while Loop check if we already have a version called like the input / input is empty 
  while true; do
    read -p "Please enter shortname (eg. 'c'): " FOLDER_NAME
    if [ "${FOLDER_NAME}" = "$(cat all_versions.txt | sed 's/io\.github\.ethanrdoesmc\.gandalf//' | grep ^${FOLDER_NAME}\$)" ]; then
      echo "${RED}ERROR:${NORMAL} You can't use this name, since it's invalid. We either have already gotten a version called like this, or you have left this field empty."
    else
      echo ${FOLDER_NAME}
      mkdir ${FOLDER_NAME}
      break
    fi
  done

  while true; do
    read -p "Please enter the supported firmware (format: <=10.2 or >=8.4): " FILE_FIRMWARE
    if [ "$(echo ${FILE_FIRMWARE} | sed "s/ //g")" = "" ]; then
      echo "ERROR: This mustn't be empty"
      else
      printf "FIRMWARE: \"${FILE_FIRMWARE}\"\n" >> ${FOLDER_NAME}/config.cfg
      break
    fi
  done

  echo "Gandalf is usually named after a jailbreak: Gandalf for <jailbreakname>. So: "
  while true; do
    read -p "Please enter the name of the jailbreak here: " FILE_NAME
    if [ "$(echo ${FILE_NAME} | sed "s/ //g")" = "" ]; then
      echo "ERROR: This mustn't be empty"
      else
      printf "NAME: \"${FILE_NAME}\"\n" >> ${FOLDER_NAME}/config.cfg
      break
   fi
  done

  while true; do
  read -p "Please enter the section now: " FILE_SECTION

  if [ "$(echo ${FILE_SECTION} | sed "s/ //g")" = "" ]; then
      echo "ERROR: This mustn't be empty"
      else
      printf "SECTION: \"${FILE_SECTION}\"\n" >> ${FOLDER_NAME}/config.cfg
      break
    fi
  done
  # Add VERSION: to configfile (standard 2.0.0)
  printf "BUILD: \"2.0.0\"\n" >> ${FOLDER_NAME}/config.cfg
  echo "Now there comes the most important step: you must now add all bundle identifiers to the file conflicts.txt."
  read -p "--- Press any key to continue --- "
  nano ${FOLDER_NAME}/conflicts.txt
  read -p "--Now please add the tweaks which should be removed if Gandalf is installed. Press any key to continue. --"
  nano ${FOLDER_NAME}/replaces.txt
  echo "Starting to build current version..."
  # Add version to all_versions.txt
  printf "io.github.ethanrdoesmc.gandalf${FOLDER_NAME}\n" >> all_versions.txt
  ./build.sh ${FOLDER_NAME}
  # Check if build was not successfull
  BUILDSH_ERRORCODE=$(echo $?)
  if [ "${BUILDSH_ERRORCODE}" != "0" ]; then
    echo "${RED}ERROR:${NORMAL} Couldn't build current version. Exitcode: ${BUILDSH_ERRORCODE}"
    exit ${BUILDSH_ERRORCODE}
  fi
  build_all
;;

"clean"|"cln")
  # Sort file contents alphabetically
  # Set and make tempdir. Thanks to https://unix.stackexchange.com/a/84980
  # should work on macOS and Linux.

  TEMPDIRECTORY=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir.XXXXXX')
  # Sort versions in all_versions.txt alphabetically. 
  echo 'Sorting all_versions.txt...'
  cat all_versions.txt | sort > ${TEMPDIRECTORY}/all_versions.txt
  cat ${TEMPDIRECTORY}/all_versions.txt > all_versions.txt
  # Clean all_versions.txt
  echo 'Removing all possible spaces at the end of the line to make the $ (anchor for end of line) work'
  sed -i 's/ *$//' all_versions.txt
  # Get shortname of versions in all_versions.txt by deleting io.github.ethanrdoesmc.gandalf; Sort conflicts.txt and replaces.txt of every known version. 
  echo "Sorting packages in conflicts.txt and replaces.txt"
 echo "Sorting config file"
  for VERSION in $(cat all_versions.txt | sed "s/^${PACKAGE_REGEX}//g"); do
  # output file content, sort it, save it to a temporary file, and rewrite them back
   CONFLICTS_SORTED=$(cat ${VERSION}/conflicts.txt | sort)
   printf "${CONFLICTS_SORTED}" > ${VERSION}/conflicts.txt
   REPLACES_SORTED=$(cat ${VERSION}/replaces.txt | sort)
   printf "${REPLACES_SORTED}" > ${VERSION}/replaces.txt
  CONFIG_SORTED=$(cat ${VERSION}/config.cfg | sort)
  printf "${CONFIG_SORTED}" > ${VERSION}/config.cfg
  done
  # Cleanup
  echo "Cleaning up temporary folder..."
  rm -rf  ${TEMPDIRECTORY}
;;

"setup-mac")
  # To be done...
  # Eye candy
# Prints ascii art "Gandalf" on terminal
echo "WELCOME TO"
cat << "EOF"
  _____                 _       _  __ 
 / ____|               | |     | |/ _|
| |  __  __ _ _ __   __| | __ _| | |_ 
| | |_ |/ _` | '_ \ / _` |/ _` | |  _|
| |__| | (_| | | | | (_| | (_| | | |  
 \_____|\__,_|_| |_|\__,_|\__,_|_|_|  

EOF

  echo "This will once setup your Mac, so that you can compile gandalf on it."
;;

*)
  # If the option is invalid get here and output error & available options
  echo "${RED}ERROR:${NORMAL} Unknown parameter '$1'."
  list_options
  exit 1
;;

esac
