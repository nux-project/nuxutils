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

.macro _syscall _syscall_num:req
	movl	\_syscall_num, %eax
	syscall
.endm

.macro sys_access
	_syscall $SYS_access
.endm

.macro sys_chdir
	_syscall $SYS_chdir
.endm

.macro sys_chroot
	_syscall $SYS_chroot
.endm

.macro sys_close
	_syscall $SYS_close
.endm

.macro sys_creat
	_syscall $SYS_creat
.endm

.macro sys_execve
	_syscall $SYS_execve
.endm

.macro sys_exit
	_syscall $SYS_exit
.endm

.macro sys_getcwd
	_syscall $SYS_getcwd
.endm

.macro sys_getpid
	_syscall $SYS_getpid
.endm

.macro sys_gettimeofday
	_syscall $SYS_gettimeofday
.endm

.macro sys_ioctl
	_syscall $SYS_ioctl
.endm

.macro sys_link
	_syscall $SYS_link
.endm

.macro sys_mkdir
	_syscall $SYS_mkdir
.endm

.macro sys_nanosleep
	_syscall $SYS_nanosleep
.endm

.macro sys_open
	_syscall $SYS_open
.endm

.macro sys_read
	_syscall $SYS_read
.endm

.macro sys_readlink
	_syscall $SYS_readlink
.endm

.macro sys_rmdir
	_syscall $SYS_rmdir
.endm

.macro sys_sigaction
	_syscall $SYS_rt_sigaction
.endm

.macro sys_unlink
	_syscall $SYS_unlink
.endm

.macro sys_write
	_syscall $SYS_write
.endm

#endif /* __SYSCALL_H__ */
