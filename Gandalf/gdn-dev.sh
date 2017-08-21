#!/bin/bash
# This script is the main script for managing the repository in an user friendlier way.
# You can: Create new gandalf versions, push all gandalf versions to the repo and compile all versions of gandalf with this script.
# Style
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
#

# Set and make tempdir. Thanks to https://unix.stackexchange.com/a/84980
# should work on macOS and Linux.

TEMPDIRECTORY=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir.XXXXXX')

# Functions

function build_all () {
  # build_all: Build all gandalf versions at once
  echo "Building all gandalf versions..."
  # Get number of lines of the file all_versions.txt and save them in a variable (uncomment for debug)
  # echo "We currently have $(wc -l < all_versions.txt) known Gandalf versions."
  # First remove all possible spaces at the end of the line to make the $ (anchor for end of line) work
  cat all_versions.txt | tr -d " " > ${TEMPDIRECTORY}/tmp_all_versions.tmp
  cat ${TEMPDIRECTORY}/tmp_all_versions.tmp > all_versions.txt
  # Get shortname of versions in all_versions.txt by deleting io.github.ethanrdoesmc.gandalf and compile gandalf as long as there is still a version --Comment not good, please edit--

  for VERSION in $(cat all_versions.txt | sed -e "s/^${PACKAGE_REGEX}//g"); do # sth wrong here
    ./build.sh "${VERSION}"

    # Check if packaging was not successful; First save exitcode of build.sh in variable to make it possible to better work with it.
    BUILDSH_ERRORCODE=$(echo $?)

    if [ "${BUILDSH_ERRORCODE}" -ne "0" ]; then
      echo "${RED}FATAL:${NORMAL} build.sh exited with error code '${BUILDSH_ERRORCODE}'. Build was most likely NOT successful."
      echo "Removing ${TEMPDIRECTORY}"
      rm -rf ${TEMPDIRECTORY}
      exit ${BUILDSH_ERRORCODE}
    fi
  done
}

function list_options () {
  # Print all available options on terminal
  echo
  echo "  ${BOLD}Available options:${NORMAL}"
  echo "  - '$0 compile-all' or short '$0 ca': Compile all versions of gandalf at once"
  echo "  - '$0 compile-for-repo' or short '$0 c4r': Compile all versions of gandalf at once and update repository"
  echo "  - '$0 clean' or short '$0 cln': Sort all conflicts.txt and replaces.txt alphabetically"
  echo "  - '$0 new': Create a new version of gandalf"
  echo "  - '$0 check': Check if anything important is missing and if you can install gandalf."
  echo "  - '$0 setup-mac': Setup your mac for building gandalf"
  echo
}

# Check if script is launched without parameters and output error and available options
if [ "$1" = "" ]; then
  echo "${BOLD}USAGE:${NORMAL} '$0 <option>'"
  list_options
  # remove ${TEMPDIRECTORY}
  rm -rf ${TEMPDIRECTORY}
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
      # remove ${TEMPDIRECTORY}
      rm -rf ${TEMPDIRECTORY}
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
      if [ "${FOLDER_NAME}" = "$(cat all_versions.txt | sed -e 's/io\.github\.ethanrdoesmc\.gandalf//' | grep ^${FOLDER_NAME}\$)" ]; then
        echo "${RED}ERROR:${NORMAL} You can't use this name, since it's invalid. We either have already gotten a version called like this, or you have left this field empty."
      else
        echo ${FOLDER_NAME}
        mkdir ${FOLDER_NAME}
        break
      fi
    done

    while true; do
      read -p "Please enter the supported firmware (format: <=10.2 or >=8.4): " FILE_FIRMWARE
      if [ "$(echo ${FILE_FIRMWARE} | sed -e "s/ //g")" = "" ]; then
        echo "ERROR: This mustn't be empty"
      else
        printf "FIRMWARE: \"${FILE_FIRMWARE}\"\n" >> ${FOLDER_NAME}/config.cfg
        break
      fi
    done

    echo "Gandalf is usually named after a jailbreak: Gandalf for <jailbreakname>. So: "
    while true; do
      read -p "Please enter the name of the jailbreak here: " FILE_NAME
      if [ "$(echo ${FILE_NAME} | sed -e "s/ //g")" = "" ]; then
        echo "ERROR: This mustn't be empty"
      else
        printf "NAME: \"${FILE_NAME}\"\n" >> ${FOLDER_NAME}/config.cfg
        break
      fi
    done

    while true; do
      read -p "Please enter the section now: " FILE_SECTION

      if [ "$(echo ${FILE_SECTION} | sed -e "s/ //g")" = "" ]; then
        echo "ERROR: This mustn't be empty"
      else
        printf "SECTION: \"${FILE_SECTION}\"\n" >> ${FOLDER_NAME}/config.cfg
        break
      fi
    done
    # Add VERSION: to configfile (standard 2.0.0)
    printf "BUILD: \"2.0.0\"\n" >> ${FOLDER_NAME}/config.cfg
    printf "DEPICTION: \"https://ethanrdoesmc.github.io/gandalf/depictions/?p=io.github.ethanrdoesmc.gandalf102\"\n" >> ${FOLDER_NAME}/config.cfg
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
      echo "${RED}ERROR:${NORMAL} Couldn't build current version. Please fix all_versions.txt and for other folders. Exitcode: ${BUILDSH_ERRORCODE}"
      echo "Remove tempdir: '${TEMPDIRECTORY}'"
      rm -rf ${TEMPDIRECTORY}
      exit ${BUILDSH_ERRORCODE}
    fi
    build_all
  ;;

  "clean"|"cln")
    # Sort file contents alphabetically

    # Sort versions in all_versions.txt alphabetically.
    echo 'Sorting all_versions.txt...'
    cat all_versions.txt | sort > ${TEMPDIRECTORY}/all_versions.txt
    cat ${TEMPDIRECTORY}/all_versions.txt > all_versions.txt
    # Clean all_versions.txt
    echo 'Removing all possible spaces at the end of the line to make the $ (anchor for end of line) work'
    cat all_versions.txt | tr -d " " > ${TEMPDIRECTORY}/tmp_all_versions.tmp
    cat ${TEMPDIRECTORY}/tmp_all_versions.tmp > all_versions.txt
    # Get shortname of versions in all_versions.txt by deleting io.github.ethanrdoesmc.gandalf; Sort conflicts.txt and replaces.txt of every known version.
    echo "Sorting packages in conflicts.txt and replaces.txt"
    echo "Sorting config file"
    for VERSION in $(cat all_versions.txt | sed -e "s/^${PACKAGE_REGEX}//g"); do
      # output file content, sort it, save it to a temporary file, and rewrite them back
      CONFLICTS_SORTED=$(cat ${VERSION}/conflicts.txt | sort)
      printf "${CONFLICTS_SORTED}" > ${VERSION}/conflicts.txt
      REPLACES_SORTED=$(cat ${VERSION}/replaces.txt | sort)
      printf "${REPLACES_SORTED}" > ${VERSION}/replaces.txt
      CONFIG_SORTED=$(cat ${VERSION}/config.cfg | sort)
      printf "${CONFIG_SORTED}" > ${VERSION}/config.cfg
    done
  ;;

  "setup-mac")
    echo "Welcome to gandalf setup-mac. We are going to install homebrew and dpkg-deb."
    echo "This is needed to properly compile gandalf on macOS."
    echo "Homebrew is a package manager (like an AppStore), see: https://brew.sh"

    # Ask for confirmation
    read -p "Do you want to continue? Y/N: " CHOICE

    case ${CHOICE} in
      Y|y|yes|YES)
      ;;
      N|n|no|NO)
        echo "Exiting..."
        # cleanup
        rm -rf ${TEMPDIRECTORY}
        exit 1
      ;;
      *)
        echo "Invalid answer! Exiting..."
        rm -rf ${TEMPDIRECTORY}
        exit 1
      ;;
    esac

    # Variables: what to install first set everything to false
    I_HOMEBREW="false"
    I_DPKG="false"

    # Check which ones are already installed (by setting the variable to "true")

    if [ $(command -v brew > /dev/null; echo $?) == "0" ]; then
      echo "Brew is already installed."
      I_HOMEBREW="true"
    fi

    if [ $(command -v dpkg-deb > /dev/null; echo $?) == "0" ]; then
      echo "dpkg-deb is already installed."
      I_DPKG="true"
    fi
    # install homebrew
    if [ "$I_HOMEBREW" == "false" ]; then
      echo "Installing homebrew..."
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" # install homebrew
      BREW_INSTEXITCODE=$(echo $?)
      if [ "${BREW_INSTEXITCODE}" -ne "0" ]; then
        echo "${RED}FATAL:${NORMAL} Brew installer exited with exitcode ${BREW_EXITCODE}"
      echo "Remove tempdir: '${TEMPDIRECTORY}'"
      rm -rf ${TEMPDIRECTORY}
      exit ${BREW_INSTEXITCODE}
      fi
    fi
    if [ "${I_DPKG}" == "false" ]; then
      echo "Installing dpkg..."
      brew install dpkg # install dpkg. We maybe must add something here...
      DPKG_EXITCODE=$(echo $?)
      if [ "${DPKG_EXITCODE}" -ne "0" ]; then
        echo "${RED}FATAL:${NORMAL} Brew exited with exitcode ${DPKG_EXITCODE}"
        echo "Removing tempdir '${TEMPDIRECTORY}'"
        rm -rf ${TEMPDIRECTORY}
        exit ${DPKG_EXITCODE}
      fi
    fi
  ;;

  check)
    # Check if all dependencies are installed
    CAN_COMPILE="true"
    echo "This command checks if you can compile gandalf on your system"
    if [ $(command -v dpkg-deb > /dev/null; echo $?) -ne "0" ]; then
      echo "${BOLD}dpkg-deb is not installed.${NORMAL} Please install it. Otherwise you will not be able to package gandalf."
      CAN_COMPILE="false"
    fi

    if [ $(command -v sed > /dev/null; echo $?) -ne "0" ]; then
      echo "${BOLD}sed is not installed.${NORMAL} Please install it. This is a core utility and should not be missing."
      CAN_COMPILE="false"
    fi

    if [ $(command -v dpkg-scanpackages > /dev/null; echo $?) -ne "0" ]; then
      echo "dpkg-scanpackages is not installed. This package is not required, but if you want to update the repo, you need it."
    fi

    if [ $(command -v ruby > /dev/null; echo $?) -ne "0" ]; then
      echo "ruby is not installed. If you are on macOS this is required if you install want to install dpkg via brew."
    fi

    if [ $(command -v brew > /dev/null; echo $?) -ne "0" ]; then
      echo "brew is not installed. This is no error. There is no need to install it if you are not on macOS."
    fi

    if [ $(command -v mktemp > /dev/null; echo $?) -ne "0" ]; then
      echo "${BOLD}mktemp is not installed.${NORMAL} Please install it. This is a core utility and should not be missing."
      CAN_COMPILE="false"
    fi

    if [ $(command -v tr > /dev/null; echo $?) -ne "0" ]; then
      echo "${BOLD}tr is not installed.${NORMAL} Please install it."
      CAN_COMPILE="false"
    fi
    if [ ${CAN_COMPILE} == false ]; then
      echo "${RED}You can not compile gandalf with this system configuration.${NORMAL}"
    else
      echo "Most likely you can compile gandalf. Be aware if you are on macOS"
    fi
    ;;
  *)
    # If the option is invalid get here and output error & available options
    echo "${RED}ERROR:${NORMAL} Unknown parameter '$1'."
    list_options
    # cleanup 
    rm -rf ${TEMPDIRECTORY}
    exit 1
  ;;

esac
# Cleanup: delete temp directory if successful
echo "Cleaning up..."
rm -rf ${TEMPDIRECTORY}
