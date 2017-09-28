/* pwd.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

#define PATH_MAX 1024

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .rodata

.LPWD:
	.ascii	"PWD="
	.equ	.LPWD_len, . - .LPWD

.section .text
	.global _start

_start:
	popq	%rcx
	popq	%rdi	/* get argv[0] and align stack */
	movq	%rsp, %rbp
	subq	$PATH_MAX, %rsp

getopt:
	movq	(%rbp, %rbx, 8), %rsi	/* get next argv[i] */
	incl	%ebx
	test	%rsi, %rsi
	jz	pwd
	cmpb	$'-', (%rsi)
	jne	.Lexit_error
	incq	%rsi
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
.Lopt_logical:
	cmpb	$'L', %al
	jne	.Lopt_physical
	movb	$0, %ah	/* Default... simply clear flag */
	jmp	.Lread_opt
.Lopt_physical:
	cmpb	$'P', %al
	jne	.Lunknown_opt
	movb	$1, %ah
	jmp	.Lread_opt
.Lunknown_opt:
/* Add invalid option to .Linvalid */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_loc(%esi)
/* Print argv[0] */
	movq	%rdi, %rbx
	call	strlen
	movl	%eax, %edx
	movq	%rbx, %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
/* %rdi already set */
	sys_write
.Lexit_error:
	movl	$EXIT_FAILURE, %edi
	sys_exit

pwd:
	testb	%ah, %ah
	jnz	.Lgetcwd
.Lgetenv:
/* First, search for PWD environment variable */
	movq	(%rbp, %rbx, 8), %rdi	/* get next *envp */
	incl	%ebx
	test	%rdi, %rdi
	jz	.Lgetcwd
	movl	$.LPWD, %esi
	movl	$.LPWD_len, %ecx
	repe cmpsb
	jne	.Lgetenv
	movq	%rdi, %rbx
	jmp	.Lprint_pwd
.Lgetcwd:
	movq	%rsp, %rdi
	movl	$PATH_MAX, %esi
	sys_getcwd
	test	%eax, %eax
	jz	.Lexit_error
	movq	%rsp, %rbx
.Lprint_pwd:
	call	strlen
	movb	$'\n', (%rbx, %rax)
	incl	%eax
	movl	$STDOUT_FILENO, %edi
	movq	%rbx, %rsi
	movl	%eax, %edx
	sys_write

exit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
