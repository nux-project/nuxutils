/* dirname.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

#define NEWLINE '\n

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

_start:
	leaq	16(%rsp), %rbp
	jmp	.Lget_arg

.Lprint_dot:
/* This is really abusing the stack... */
	movb	$'., (%rsp)
	movb	$'\n, 1(%rsp)
	movq	%rsp, %rsi
	movl	$2, %edx
	jmp	.Lwrite_out
dirname_loop:
	call	dirname
	movq	%rax, %r12	/* Save return */
	movq	%rax, %rdi
/* dirname() may return a constant ".". Check that this is not the
   case before adding the newline character at the end.
 */
	cmpb	$'., (%rdi)
	jne	.Ladd_newline
	cmpb	$0, 1(%rdi)
	je	.Lprint_dot	
.Ladd_newline:
	call	strlen
	movl	%eax, %edx
	movq	%r12, %rsi
	movb	$NEWLINE, (%rsi, %rdx)
	incl	%edx
.Lwrite_out:
	movl	$STDOUT_FILENO, %edi
	sys_write
	incl	%ebx
.Lget_arg:
	movq	(%rbp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jnz	dirname_loop
.Lexit:
	movl	$EXIT_SUCCESS, %eax
	sys_exit
