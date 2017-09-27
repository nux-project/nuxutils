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
#define F_GETLK  11
#define F_SETLK  12
#define F_SETLKW 13
#define F_GETOWN  5
#define F_SETOWN  6

#if __POSIX_VISIBILITY == 200809
#define F_DUPFD_CLOEXEC 17
#endif

/* fcntl() file descriptor flags
 */
#define FD_CLOEXEC 1

/* fcntl() l_type arguments
 */
#define F_RDLCK 1
#define F_UNLCK 2
#define F_WRLCK 3

/* File open flags
 */
#define O_RDONLY  0x00
#define O_WRONLY  0x01
#define O_RDWR    0x02
#define O_ACCMODE 0x03

/* File creation modifier flags
 */
#define O_CREAT  0x0200
#define O_EXCL   0x0800
#define O_NOCTTY 0x8000
#define O_TRUNC  0x0400

#if __POSIX_VISIBILITY >= 200809
#define O_DIRECTORY 0x00020000
#define O_NOFOLLOW      0x0100
#define O_CLOEXEC   0x00100000
#endif

/* File status modifier flags
 */
#define O_APPEND   0x0004
#define O_DSYNC    0x0000
#define O_NONBLOCK 0x0004
#define O_RSYNC    0x0000
#define O_SYNC     0x0080
