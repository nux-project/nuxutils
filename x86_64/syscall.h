/* syscall.h

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: August 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#ifndef __SYSCALL_H__
#define __SYSCALL_H__

#include <sys/syscall.h>

#define __syscall(num) \
	movl	$num, %eax; \
	syscall

#define sys_access __syscall(SYS_access)

#define sys_chdir __syscall(SYS_chdir)

#define sys_chroot __syscall(SYS_chroot)

#define sys_close __syscall(SYS_close)

#define sys_creat __syscall(SYS_creat)

#define sys_execve __syscall(SYS_execve)

#define sys_exit __syscall(SYS_exit)

#define sys_fsync __syscall(SYS_fsync)

#define sys_fdatasync __syscall(SYS_fdatasync)

#define sys_getcwd __syscall(SYS_getcwd)

#define sys_getpid __syscall(SYS_getpid)

#define sys_gettimeofday __syscall(SYS_gettimeofday)

#define sys_ioctl __syscall(SYS_ioctl)

#define sys_link __syscall(SYS_link)

#define sys_mkdir __syscall(SYS_mkdir)

#define sys_nanosleep __syscall(SYS_nanosleep)

#define sys_open __syscall(SYS_open)

#define sys_read __syscall(SYS_read)

#define sys_readlink __syscall(SYS_readlink)

#define sys_rmdir __syscall(SYS_rmdir)

#define sys_sigaction __syscall(SYS_rt_sigaction)

#define sys_sync __syscall(SYS_sync)

#define sys_syncfs __syscall(SYS_syncfs)

#define sys_unlink __syscall(SYS_unlink)

#define sys_write __syscall(SYS_write)

#endif /* __SYSCALL_H__ */
