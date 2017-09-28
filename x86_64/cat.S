/* cat.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

#define BUFFER_SIZE 1024

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_opt_loc, 21

.section .text
	.global _start

_start:
	movq	%rsp, %rbp
	subq	$BUFFER_SIZE, %rsp

getopt:
	movq	16(%rbp, %rbx, 8), %rdi
	incl	%ebx
	testq	%rdi, %rdi
	jz	.cat_stdin
	cmpb	$'-', (%rdi)
	jne	.Lopen_file
	incq	%rdi
.Lread_opt:
	lodsb
	testb	%al, %al
	jz	getopt
.Lopt_null:
	cmpb	$0, %al
/* "-" option = stdin */
	je	.cat_stdin
.Lopt_u:
	cmpb	$'u', %al
/* ignore '-u' */
	je	.Lread_opt
.Linvalid_opt:
/* Add invalid option to .Linvalid */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_opt_loc(%esi)
/* Print argv[0] */
	movq	8(%rbp), %rdi
	call	strlen
	movl	%eax, %edx
	movq	8(%rbp), %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
	sys_write
	movl	$EXIT_FAILURE, %edi
	sys_exit

.cat_stdin:
	movl	$STDIN_FILENO, %r15d
	jmp	.Lread_file
cat:
	cmpb	$'-', (%rdi)
	jne	.Lopen_file
	cmpb	$0, 1(%rdi)
	je	.cat_stdin
.Lopen_file:
	movl	$O_RDONLY, %esi
	sys_open
	test	%eax, %eax
	js	.Lexit_error
	movl	%eax, %r15d
.Lread_file:
	movl	$BUFFER_SIZE, %edx
	movq	%rsp, %rsi
	movl	%r15d, %edi
	sys_read
	test	%eax, %eax
	js	.Lexit_error
	jz	.Lclose_file
.Lwrite_file:
	movl	%eax, %edx
	movq	%rsp, %rsi
	movl	$STDOUT_FILENO, %edi
	sys_write
	test	%eax, %eax
	js	.Lexit_error
	cmpl	%eax, %edx
	jl	.Lwrite_file
	jmp	.Lread_file
.Lclose_file:
	cmpl	$STDIN_FILENO, %r15d
	je	.Lget_file
	movl	%r15d, %edi
	sys_close
.Lget_file:
	movq	16(%rbp, %rbx, 8), %rdi
	incl	%ebx
	test	%rdi, %rdi
	jnz	cat
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
.Lexit_error:
	negl	%eax
	movl	%eax, %edi
	sys_exit
