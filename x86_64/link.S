/* link.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "inc/syscall.h"
#include "inc/errno.h"

.section .text
	.global _start

_start:
	movq	(%rsp), %rbx	/* %rbx = argc */
	cmpq	$3, %rbx
	jl	.Ltoo_few_arg
	jg	.Ltoo_many_arg

	movq	16(%rsp), %rdi	/* get argv[1] */
	movq	24(%rsp), %rsi	/* get argv[2] */
	sys_link
	test	%rax, %rax
	jnz	.Llink_fail

	movl	$0, %edi
	sys_exit

.Ltoo_few_arg:
	movl	$EINVAL, %edi
	sys_exit

.Ltoo_many_arg:
	movl	$E2BIG, %edi
	sys_exit

.Llink_fail:
	negl	%eax
	movl	%eax, %edi
	sys_exit
