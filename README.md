Nucleus Utilities
=================

Nucleus utilities is meant as a POSIX-compliant implementation of the GNU Core
Utilities written in assembly language. These utilities are meant to be
portable across multiple operating systems, including, but not limited to,
Linux and the BSD family (FreeBSD, OpenBSD, etc).

Project Goals
-------------

The primary goal of the project, as stated above, is to provide POSIX-compliant
implementations of the tools included in the GNU Core Utilities package. In
addition to this goal, the following are also important:

1. Learn assembly programming
   No reason in writing yet another implementation of the included tools if
   one of your goals is not learning from the experience.
1. Portability across POSIX-compliant operating systems
   Some people do not realize that you can write portable assembly. A little
   more care must be taken when doing it, but this project hopes to be portable
   across many operation systems.
1. Unobfuscated code
   Assembly is already harder to follow, as it is, no reason to make it even
   more so.
1. Small footprint and fast code
   Assembly code is inherently faster than code written in a high-level
   language.  However, however there are things that can be done to improve
   that speed, such as using the registers for temporary variables.

The project currently only supports the x86 _ 64 platform, but plans to add
ports to the x86, ARM and other processor families.

POSIX Compliance
----------------

The project aims to implement, at a minimum, the functionality descibed in the
[POSIX.1-2008 Specification][http://pubs.opengroup.org/onlinepubs/9699919799/].

Installation
------------

To assemble, run:

	mkdir build && cd build
	../configure
	make

And to install, run `make install` as root.

License
-------

The project is licensed under the Mozilla Public License, version 2.0. A full
copy of the license can be found in COPYING.md. If a copy of the MPL was not
included with this distribution, then see <https://mozilla.org/MPL/2.0/>.
