/* sysdep.h

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: August 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#ifndef __SYSDEP_H__
#define __SYSDEP_H__

#if linux
#include "asm/fcntl-linux.h"
#elif __FreeBSD__
#include "asm/fcntl-freebsd.h"
#endif

#include "syscall.h"

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1

#define PTR_SIZE 8

#define FUNC_ENTER \
	pushq	%rbp; \
	movq	%rsp, %rbp;

#define FUNC_EXIT \
	movq	%rbp, %rsp; \
	popq	%rbp;

#define DECL_FUNC(name) \
	.global name; \
	.type name, @function; \
	.align 16;

#endif /* __SYSDEP_H__ */
