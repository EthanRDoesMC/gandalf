# Gandalf for Yalu102
### DANGEROUS TWEAKS SHALL NOT PASS

Update: asked Saurik for suggestions, he suggested I try Pinning Gandalf. It's a dpkg setting that prevents a package from being installed, uninstalled and/or updated based on prioritization. I'm thinking of incorporating this via Manager or a post-installation script (which is ALSO a thing) but leaning toward Manager as Gandalf needs to update and I have no idea how I'd automatically unpin it. In manager I can incorporate a button!


IT WORKS YAY

Will build and update in repo tonight  

also, i never thought i'd be where i am now. thank you guys so much. 



Install via repo: https://ethanrdoesmc.github.io/repo
Tap [this][cydia://url/https://cydia.saurik.com/api/share#?source=https://ethanrdoesmc.github.io/repo/] to open in Cydia.

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

- Uninstalls old things and poor Dillan's CydiaExtenderPlus upon installation.

- To pin it, run `su` then run `echo io.github.ethanrdoesmc.gandalf102 hold | dpkg --set-selections`

2.0-Beta3

[1]: http://tinyurl.com/gandalfios
