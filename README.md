# Gandalf
### DANGEROUS TWEAKS SHALL NOT PASS

Install via repo: https://ethanrdoesmc.github.io/repo
Tap [This Link](cydia://url/https://cydia.saurik.com/api/share#?source=https://ethanrdoesmc.github.io/repo/) to open in Cydia.

# Contribute
Add an incompatible package identifier to the conflicts.txt file.
> Packages are **comma space separated** with **no comma closing the list**.
e.x. `[my.package], [your.package]`

New lines are **not** permitted excluding the 1 line break at the end of the file.

Be sure the conflicts are in alphabetical order.

> If the release is behind, use `bash` to compile:
`sh build.sh`

Create a pull request. Most requests *will* be merged.

If something is wrong, run `sh filestructure.sh` and see if you can figure it out.

# Notes
- You can test Gandalf using the *New Package* in my repo. (removed! get it from https://supermamon.github.io/Reposi3 in Cydia.)

- Installation will be finalized in Manager when Manager is a thing. Shell scripts are fine for us but not for the masses. 

- Will be in both the repo and Manager. 

- Porting to other versions. Gandalf Pangu 7 is a test. Was seeing if Gandalf had a point in time where it broke that I could get it to work. Nothing. Guess we'll never know why it worked for that time.
