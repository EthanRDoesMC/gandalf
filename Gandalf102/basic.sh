#!/bin/bash

#Please run with a Linux flavor. macOS makes a lot of dummy files.

# Aliases
basename="io.github.ethanrdoesmc.gandalf102"
conflictfile="conflicts.txt"

# package
echo "Creating package."
dpkg-deb -Zgzip -b $basename
