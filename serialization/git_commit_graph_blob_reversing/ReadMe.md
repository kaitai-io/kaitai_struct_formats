Black-box reversing of Git commit graph format
================================================

Copyright holders of Git behave like copyright trolls. It is very unsurprisengly, since willfully using GPL - a restrictive license pretending to be free but in fact serving the purpose of proliferating GPL itself and forcing people who are not wiling to proliferate GPL to pay  money to copyright holders - is relying on **copyright** and promoting and reinforcing it is a one of signs of a copyright troll.

So we have to black-box reverse-engineer the format, as Junio Hamano has noticed that we must do it do satisfy the terms of the license.

Here is the blog of reverse-engineering

0. We observe the files and notice signatures. We create a preliminary rough KS spec for the format.
1. We create a repo, add there commits one-by-one, doing `git gc --aggressive` and then generate test files with `git commit-graph write --reachable`.
2. We create a graphviz of commit graph by another tool, https://github.com/rpmiskin/git-graphviz
3. We hd these files.
4. We see some sequences of `u4`s , incrementing. We separate them visually from the rest of hexdump.
5. We find commit hashes within these files and separate them visually from the rest of hexdump.
6. We diff these files to each other.
7. We investigate the bytes after commit hashes in the diffs. We notice that some parts of them duplicate between files (though not caught by `hd` because of alignment`). 
8. We split them by boundaries.
9. We notice `70 00 00 00 00 00 00 0X` sequence of bytes, that seems to be 4-byte aligned, and we notice that the block ends 4 bytes after this sequence.
10. We spot such sequencies in all the files and split them.
11. These sequences are usually 36 bytes. It is a structure!

