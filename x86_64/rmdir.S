/* rmdir.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .data

.Lparent:
	.byte	0

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

_start:
	popq	%rcx
	popq	%rdi	/* %rdi = argv[0] and align stack */

getopt:
	movq	(%rsp, %rbx, 8), %rsi	/* get argv[i] */
	test	%rsi, %rsi
	jz	.Linvalid_arg
	cmpb	$'-, (%rsi)
	jne	rmdir
	incq	%rsi
	incl	%ebx
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
.Lopt_parents:
	cmpb	$'p, %al
	sete	(.Lparent)
	je	.Lread_opt
.Lunknown_opt:
	movq	%rdi, %rbx	/* save invalid argument */
/* Add invalid option to .Linvalid */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_loc(%esi)
/* Print argv[0] */
	call	strlen
	movl	%eax, %edx
	movq	%rbx, %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
/* %rdi already set */
	sys_write
.Linvalid_arg:
	movl	$EXIT_FAILURE, %edi
	sys_exit

rmdir:
	movq	%rsi, %rdi
.Lrmdir:
	sys_rmdir
	test	%eax, %eax
	js	.Lexit_error
.Lrmdir_parent:
	movb	(.Lparent), %al
	test	%al, %al
	jz	.Lnext_dir
	/* FIXME */
.Lnext_dir:
	incl	%ebx
	movq	(%rsp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jnz	.Lrmdir
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
.Lexit_error:
	negl	%eax
	movl	%eax, %edi
	sys_exit
