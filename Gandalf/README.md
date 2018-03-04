# Gandalf
### DANGEROUS TWEAKS SHALL NOT PASS

Did you know? Control file fields can be entered in any order. This means the death of a bajillion folders! We can just print the contents of 2 files (and maybe one day, 1!) instead of 4! ...Those are new files that have to be tracked, aren't they... I'll get that when this refurbishment is done.

# How to install?
Install via my repo: https://ethanrdoesmc.github.io/gandalf/
Tap [this](https://tinyurl.com/gandrepo) to open in Cydia.
There's also a little repo installer thing on my personal repo. https://ethanrdoesmc.github.io/repo
# Contribute
Fork this repository with the *Fork* button on the top right.
Add an incompatible package identifier to the conflicts.txt file in the folder of the Gandalf version. 

E.g. If you want to add a packet identifier to Gandalf for Yalu102, open the folder *102* and there add it to the file *conflicts.txt*.
After that make a pull request. 
> Packages have to be added **by starting a new line**
Be sure the conflicts are in alphabetical order, or run `sh gdn-dev.sh clean`. It'll do that for you. 

> If the release is behind, use `bash` to compile:
`sh build.sh <version>` while `<version>` must be replaced by the internal name. E.g. If you want to compile Gandalf for Yalu102 you must run `sh build.sh 102`. If you aren't sure which internal name you should use you can look at all_versions.txt. The last few characters after io.github.ethanrdoesmc.gandalf are the ones you should type. If you are still not sure, just compile all versions at once: `sh gdn-dev.sh compile-all`

# The gdn-dev.sh script

The gdn-dev.sh script is a script which should make the whole work with gandalf easier. 
The script can be used to:

* Compile all versions of Gandalf at once: `sh gdn-dev.sh compile-all`
* Compile all versions and upload it to the Gandalf repo: `sh gdn-dev.sh compile-for-repo`
* Sort all identifiers in replaces.txt and conflicts.txt in alphabetical order: `sh gdn-dev.sh clean` This should be run before compile-all or compile-for-repo. 
* Make a new version of Gandalf: `sh gdn-dev.sh new` TODO: -> Better description!!
* Setup your Mac to be able to build gandalf on your Mac. This feature is not yet tested on a clean Mac but it installs brew and dpkg if needed. Run it with `sh gdn-dev.sh setup-mac`
* Check if the most important tools for compiling gandalf are installed on your system. This isn't complete yet but it's in late beta. Run it with `sh gdn-dev.sh check`

# The GandalfApp
The new app for gandalf is in very early development, and we need testing. I can transfer the ownership to @EthanRDoesMC or @mehulrao if they want, since I won't develop it further. (Not skilled enough...)
The app can be compiled on macOS with Xcode and will be patched during the install of Gandalf on iOS. So just upload it and name `GandalfApp.app` the name is **case-sensitive**!

# Pull requests

Create a pull request. Most requests *will* be merged.

# Notes
- You can test Gandalf using the *New Package* from https://supermamon.github.io/Reposi3 in Cydia.

[1]: http://tinyurl.com/gandalfios
