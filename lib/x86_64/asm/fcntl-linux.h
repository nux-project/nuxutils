/* fcntl.h

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

/* fcntl() command arguments
 */
#define F_DUPFD   0
#define F_GETFD   1
#define F_SETFD   2
#define F_GETFL   3
#define F_SETFL   4
#define F_GETLK  12
#define F_SETLK  13
#define F_SETLKW 14
#define F_GETOWN  9
#define F_SETOWN  8

#if __POSIX_VISIBILITY == 200809
#define F_DUPFD_CLOEXEC 1030
#endif

/* fcntl() file descriptor flags
 */
#define FD_CLOEXEC 1

/* fcntl() l_type arguments
 */
#define F_RDLCK 0
#define F_UNLCK 1
#define F_WRLCK 2

/* File open flags
 */
#define O_RDONLY   0
#define O_WRONLY  01
#define O_RDWR    02
#define O_ACCMODE 03

/* File creation modifier flags
 */
#define O_CREAT  0100
#define O_EXCL   0200
#define O_NOCTTY 0400
#define O_TRUNC 01000

#if _POSIX_VERSION >= 200809
#define O_DIRECTORY 0200000
#define O_NOFOLLOW  0400000
#define O_CLOEXEC  02000000
#endif

/* File status modifier flags
 */
#define O_APPEND   02000
#define O_DSYNC   010000
#define O_NONBLOCK 04000
#define O_RSYNC 04010000
#define O_SYNC  04010000
