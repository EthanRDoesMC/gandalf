Everyone, look! It's the
# Gandalf Repo!
*delivering Gandalf versions since 2017* 
#
So, how does one use, share the correct URL of, and update the **Gandalf Repo**?
*You've come to the right place, ¡mi amigo/a!*
# Using the repo
*/debs* is the folder that holds .deb files. Place new packages into it.
*/depictions* holds depictions. In a control file, you'd type:
Depiction: https://ethanrdoesmc.github.io/gandalf/depictions?p=packageid
where packageid is the package id. 
To create a depiction, be lazy and copy one of the other folders. Edit it to your needs.
# The correct URL/Using the repo *parte dos*
This is very important. Because of the way GitHub Pages works, the URL for this repo is *exactly*
https://ethanrdoesmc.github.io/gandalf/
**Note the / at the end!**
Otherwise, the link will point to ethanrdoesmc.github.io (the GitHub Repository) and look for a non-existant /gandalf in said repo.
I should probably make a redirect page, but if you're looking to be professional, you should use the correct repo.
There is also another way to get to this repo!
https://ethanrdoesmc.github.io/repo/depictions?p=io.github.ethanrdoesmc.gandalf
# Updating the repo
This is simple. But you have to be on Ubuntu or have dpkg-scanpackages. I could fix this by adding my own version, and I probably should.
> sh update.sh

Thanks for helping out the Gandalf project!
