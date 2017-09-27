/* echo.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .data

.Lnewline:
	.byte	'\n

.section .text
	.global _start

_start:
	movq	16(%rsp), %rdi	/* argv[1] */
	decq	(%rsp)

.Lgetopt:
	test	%rdi, %rdi
	jz	.Lwrite_newline	/* echo called with no arguments */
	cmpb	$'-, (%rdi)
	jne	.Lecho_argv
	cmpb	$'n, 1(%rdi)
	jne	.Lecho_argv
	cmpb	$0, 2(%rdi)
	jne	.Lecho_argv
	incq	%rbx
	movb	$0, (.Lnewline)

get_argv:
	movq	16(%rsp, %rbx, 8), %rdi
	testq	%rdi, %rdi
	jz	.Lwrite_newline
.Lecho_argv:
	call	strlen
	movl	$STDOUT_FILENO, %edi
	movq	16(%rsp, %rbx, 8), %rsi
/* add ' ' if not at the end */
	incl	%ebx
	movl	%eax, %edx
	cmpq	(%rsp), %rbx
	je	.Lwrite
	movb	$' , (%rsi, %rax)
	incl	%edx
.Lwrite:
	sys_write
	jmp	get_argv

.Lwrite_newline:
	movl	$STDOUT_FILENO, %edi
	movl	$.Lnewline, %esi
	movl	$1, %edx
	sys_write

.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
