/* yes.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .rodata

.Ly:
	.ascii	"y\n"

.section .text
	.global _start

_start:
	popq	%rcx
	popq	%rdi
	cmpq	$1, %rcx
	jne	.Largv_next

.Lprint_y:
	movl	$STDOUT_FILENO, %edi
	movl	$.Ly, %esi
	movl	$2, %edx

.Lprint_loop:
	sys_write
/* 'yes' never exits... */
	jmp	.Lprint_loop

.Largv_prep:
	call	strlen
	movq	(%rsp, %rbx, PTR_SIZE), %rdi
	incl	%ebx
	movb	$' ', (%rdi, %rax)
	leal	1(%eax, %edx), %edx
.Largv_next:
	movq	(%rsp, %rbx, PTR_SIZE), %rdi	/* %rdi = argv[i] */
	test	%rdi, %rdi
	jnz	.Largv_prep
.Largv_write_setup:
	movq	(%rsp), %rsi
	movb	$'\n', -1(%rsi, %rdx)
	movl	$STDOUT_FILENO, %edi
	jmp	.Lprint_loop
