# Gandalf for Yalu102
### DANGEROUS TWEAKS SHALL NOT PASS

Update: asked Saurik for suggestions, he recommended I try Pinning Gandalf. It's a dpkg setting that prevents a package from being installed, uninstalled and/or updated based on prioritization. I'm thinking of incorporating this via Manager or a post-installation script (which is ALSO a thing) but leaning toward Manager as Gandalf needs to update and I have no idea how I'd automatically unpin it. In manager I can incorporate a button!


Hopefully that'll block packages. I'll go try it right now. If it does, we'll be back on track!

also, i never thought i'd be where i am now. thank you guys so much. 



Install via repo: https://ethanrdoesmc.github.io/repo
Tap [this][1] to open in Cydia.

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
- You can test Gandalf using the *New Package* in my repo.
- Removing from repo. Will be in manager.

2.0-Beta1

[1]: http://tinyurl.com/gandalfios
