/* logname.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: February 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .rodata

.Llogname:
	.ascii	"LOGNAME"
	.equ	.Llogname_len, . - .Llogname

.Lno_logname:
	.ascii	": no login name\n"
	.equ	.Lno_logname_len, . - .Lno_logname

.section .text
	.global _start

_start:
	popq	%rbx
	popq	%rbp
	/* FIXME: output error if %rbx > 1 */

getenv:
	movq	(%rsp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jz	exit_no_logname
	incl	%ebx
	movl	$.Llogname_len, %ecx
	movq	$.Llogname, %rsi
	repe cmpsb
	test	%ecx, %ecx
	jnz	getenv
	cmpb	$'=, (%rdi)
	jne	getenv
	incq	%rdi
	movq	%rdi, %r15	/* Save %rdi, again */
	call	strlen
	movl	$STDOUT_FILENO, %edi
	movq	%r15, %rsi	/* Prep for sys_write */
	movb	$'\n, (%rsi, %rax)
	incl	%eax
	movl	%eax, %edx
	sys_write
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
	
exit_no_logname:
	movq	%rbp, %rdi
	call	strlen
	movl	%eax, %edx
	movq	%rbp, %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Lno_logname_len, %edx
	movl	$.Lno_logname, %esi
	sys_write
	movl	$EXIT_FAILURE, %edi
	sys_exit
