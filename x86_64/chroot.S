/* chroot.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .rodata

.Ldfl_cmd:
	.quad	.Lbin_sh
	.quad	.Li_opt
	.quad	0

.Lbin_sh:
	.string	"/bin/sh"
.Li_opt:
	.string	"-i"

.Lshell:
	.ascii	"SHELL"
	.equ	.Lshell_len, . - .Lshell

.Lroot:
	.string	"/"

.section .text
	.global _start

_start:
	popq	%rcx
	popq	%rdi
	cmpl	$2, %ecx
	jge	chroot
	movl	$EXIT_FAILURE, %edi
	sys_exit

chroot:
	leaq	(%rsp, %rcx, 8), %rbp	/* pointer to envp */
	movq	(%rsp), %rdi	/* newroot */
	sys_chroot
	test	%eax, %eax
	js	.Lexit_error
	movl	$.Lroot, %edi
	sys_chdir
	test	%eax, %eax
	js	.Lexit_error
	leaq	8(%rsp), %rsi
	cmpq	$0, (%rsi)
	jnz	exec
	movl	$.Ldfl_cmd, %esi
exec:
	movq	(%rsi), %rdi
	movq	%rbp, %rdx
	sys_execve
/* Should never be reached */
.Lexit_error:
	negl	%eax
	movl	%eax, %edi
	sys_exit
