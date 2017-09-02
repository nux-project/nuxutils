/* unlink.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "inc/errno.h"
#include "inc/syscall.h"

.section .text
	.global _start

_start:
	movq	(%rsp), %rbx	/* %rbx = argc */
	cmpq	$2, %rbx
	jg	.Ltoo_many_arg
	jl	.Ltoo_few_arg

	movq	16(%rsp), %rdi	/* get argv[1] */
	sys_unlink
	test	%rax, %rax
	jnz	.Lunlink_fail

	movl	$0, %edi
	sys_exit

.Ltoo_few_arg:
	movl	$EINVAL, %edi
	sys_exit

.Ltoo_many_arg:
	movl	$E2BIG, %edi
	sys_exit

.Lunlink_fail:
	negl	%eax
	movl	%eax, %edi
	sys_exit
