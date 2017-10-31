/* stat.h

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: October 2017

   This file is part of Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#ifndef __ASM_STAT_H__
#define __ASM_STAT_H__

/* File types encoded in type mode_t
 */
#define S_IFMT	0170000
#define S_IFBLK	0060000
#define S_IFCHR	0020000
#define S_IFIFO	0010000
#define S_IFREG	0100000
#define S_IFDIR	0040000
#define S_IFLNK	0120000
#define S_IFSOCK	0140000

/* File mode bits encoded in mode_t
 */
#define S_IRWXU	0700
#define S_IRUSR	0400
#define S_IWUSR	0200
#define S_IXUSR	0100
#define S_IRWXG	070
#define S_IRGRP	040
#define S_IWGRP	020
#define S_IXGRP	010
#define S_IRWXO	07
#define S_IROTH	04
#define S_IWOTH	02
#define S_IXOTH	01
#define S_ISUID	04000
#define S_ISGID	02000
#define S_ISVTX	01000

#endif /* __ASM_STAT_H__ */
