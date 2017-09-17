/* mkdir.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "inc/sysdep.h"
#include "inc/syscall.h"

.section .data

.Lparent:
	.byte	0

.Lmode:
	.long	0777

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

_start:
	popq	%rcx
	popq	%rdi	/* get argv[0] */

getopt:
	movq	(%rsp, %rbx, 8), %rsi	/* get next argv[i] */
	test	%rsi, %rsi
	jz	.Linvalid_arg
	cmpb	$'-, (%rsi)
	jne	mkdir
	incl	%ebx
	incq	%rsi
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
.Lopt_m:
	cmpb	$'m, %al
	jne	.Lopt_p
	movq	(%rsp, %rbx, 8), %rdi
	test	%rdi ,%rdi
	jz	.Linvalid_arg
	/* FIXME: Implement mode */
	incl	%ebx
	jmp	getopt
.Lopt_p:
	cmpb	$'p, %al
	seteb	(.Lparent)
	je	.Lread_opt
.Lunknown_opt:
	movq	%rdi, %rbx	/* save argv[0] */
/* Add invalid option to _unknown_opt */
	movq	$.Linvalid, %rsi
	movb	%al, .Linvalid_loc(%rsi)
/* Print argv[0] */
	call	strlen
	movl	%eax, %edx
	movq	%rbx, %rsi
	movq	$STDERR_FILENO, %rdi
	sys_write
	movq	$.Linvalid, %rsi
	movq	$.Linvalid_len, %rdx
	/* %rdi already set */
	sys_write
.Linvalid_arg:
	movl	$EXIT_FAILURE, %edi
	sys_exit

mkdir:
	movq	%rsi, %rdi	/* save the start of the string */
	movb	(.Lparent), %al
	test	%al, %al
	jz	.Lmkdir
	jmp	.Lmkdir_get_parent
.Lmkdir_make_parent:
	cmpb	$'/, %al
	jne	.Lmkdir_get_parent
	movb	$0, -1(%rsi)
	movq	%rsi, %rdx
	movl	(.Lmode), %esi
	sys_mkdir
	movq	%rdx, %rsi
	movb	$'/, -1(%rsi)
.Lmkdir_get_parent:
	lodsb
	test	%al, %al
	jnz	.Lmkdir_make_parent
.Lmkdir:
	movl	(.Lmode), %esi
	sys_mkdir
	test	%rax, %rax
	jnz	.Lexit_error
	incl	%ebx
	movq	(%rsp, %rbx, 8), %rsi
	test	%rsi, %rsi
	jnz	mkdir
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
.Lexit_error:
	negl	%eax
	movl	%eax, %edi
	sys_exit
