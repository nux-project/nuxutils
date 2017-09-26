/* basename.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .text
	.global _start

_start:
	popq	%rcx	/* %rcx = argc */
	popq	%rdi	/* get argv[0] and align stack */

	movq	(%rsp), %rdi
	test	%rdi, %rdi
	jz	.Lexit_error
	call	basename
	movq	%rax, %rbp	/* Save return */
	movq	%rax, %rdi
	call	strlen
	movl	%eax, %edx
	movq	8(%rsp), %rdi	/* Get suffix, if any */
	test	%rdi, %rdi
	jz	.Lprint
.Lsuffix:
	movl	%edx, %ebx	/* Save strlen(argv[1]) */
	call	strlen
	movl	%ebx, %edx	/* Restore in case of branch. */
	subl	%eax, %ebx	/* strlen(argv[1]) - strlen(argv[2]) */
	js	.Lprint
	movq	8(%rsp), %rdi
	leaq	(%rbp, %rbx), %rsi
	movl	%eax, %ecx
	cld
	repe cmpsb
	jnz	.Lprint
	testl	$0, %ecx
	jnz	.Lprint
	movb	$0, (%rsi)
	movl	%ebx, %edx
.Lprint:
	movq	%rbp, %rsi
	movb	$'\n, (%rsi, %rdx)
	incl	%edx
	movl	$STDOUT_FILENO, %edi
	sys_write
	movl	$EXIT_SUCCESS, %edi
	sys_exit
.Lexit_error:
	movl	$EXIT_FAILURE, %edi
	sys_exit
