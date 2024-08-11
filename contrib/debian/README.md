
Debian
====================
This directory contains files used to package efusd/efus-qt
for Debian-based Linux systems. If you compile efusd/efus-qt yourself, there are some useful files here.

## efus: URI support ##


efus-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install efus-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your efus-qt binary to `/usr/bin`
and the `../../share/pixmaps/efus128.png` to `/usr/share/pixmaps`

efus-qt.protocol (KDE)

