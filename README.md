# Gandalf
DANGEROUS TWEAKS SHALL NOT PASS!



# How to contribute
- add a conflicting package-identifier to the conflicts.txt
- every line ends with a Comma (,), except the last
- make sure the conflicts are in alphabetical order
- create a pull request
- if release is behind in the future use ubuntu to compile (sh create.sh)


# Live updates on Twitter
- twitter.com/ethanrdoesmc_ (with an underscore)

# Notes
- there is a possibility that having new lines in the conflicts.txt breaks things
- this is why there are two of almost every file: one with line breaks, one without

- com.github.ethanrdoesmc.gandalf was done with controlwithconflicts
- create.sh was not used to make it and line breaks were ommited
- its also made to replace all bad tweaks entirely and needs testing

- gandalf10.deb was made with create-maybe-works.sh
- points to conflictsnonewlines.txt
- removing -e in all cases allowed it to compile

- gandalf.deb was compiled with create-without-e.sh
- it's a direct copy of create.sh without -e
- this one has line breaks in the control file

- there is a test dummy package called NewPackage in my repo
- Gandalf auto blocks it
- testing is safer this way
