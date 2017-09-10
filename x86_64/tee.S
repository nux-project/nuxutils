/* tee.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "inc/signal.h"
#include "inc/sysdep.h"
#include "inc/syscall.h"

#define BUFFER_SIZE 1024

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.Lopen_flags:
	.long	O_CREAT|O_WRONLY|O_TRUNC
	.equ	.Lopen_flags_append, O_CREAT|O_WRONLY|O_APPEND

.section .rodata

.Lsig_ign:
	.quad	SIG_IGN
	.quad	0
	.quad	0
	.quad	0

.section .text
	.global _start

_start:
	movq	%rsp, %rbp
	subq	$BUFFER_SIZE, %rsp

getopt:
	movq	16(%rbp, %rbx, 8), %rsi
	test	%rsi, %rsi
	jz	open_files
	cmpb	$'-, (%rsi)
	jne	open_files
	incl	%ebx
	incq	%rsi
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
.Lopt_append:
	cmpb	$'a, %al
	jne	.Lopt_ignore_int
	movl	$.Lopen_flags_append, (.Lopen_flags)
	jmp	.Lread_opt
.Lopt_ignore_int:
	cmpb	$'i, %al
	jne	.Lunknown_opt
	movl	$SIGINT, %edi
	movl	$.Lsig_ign, %esi
	movl	$0, %edx
	movq	$8, %r10	/* 8 = sizeof(sigset_t) */
	sys_sigaction
	test	%eax, %eax
	js	sys_error
	jmp	.Lread_opt
.Lunknown_opt:
/* Add invalid option to .Linvalid_opt_msg */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_loc(%esi)
/* Print argv[0] */
	movq	8(%rbp), %rdi
	call	strlen
	movl	%eax, %edx
	movq	8(%rbp), %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
/* %rdi already set */
	sys_write
.Lexit_error:
	movl	$EXIT_FAILURE, %edi
	sys_exit

sys_error:
	negl	%eax
	movl	%eax, %edi
	sys_exit

open_files:
	pushq	$STDOUT_FILENO
	jmp	.Lopen_loop
.Lopen_file:
	movl	(.Lopen_flags), %esi
	movl	$0666, %edx
	sys_open
	test	%eax, %eax
	js	sys_error
	pushq	%rax
	incl	%ebx
.Lopen_loop:
	movq	16(%rbp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jnz	.Lopen_file
	jmp	.Lread_file

tee:
	movl	%eax, %edx
	xorl	%ebx, %ebx
.Lwrite_file:
	movq	(%rsp, %rbx, 8), %rdi
/* %rsi and %edx are already set, from call to sys_read */
	sys_write
	incl	%ebx
	test	%eax, %eax
	js	sys_error
	cmpq	$STDOUT_FILENO, %rdi
	jne	.Lwrite_file
.Lread_file:
	movl	$STDIN_FILENO, %edi
	leaq	-BUFFER_SIZE(%rbp), %rsi
	movl	$BUFFER_SIZE, %edx
	sys_read
	test	%eax, %eax
	js	sys_error
	jnz	tee

close_files:
	jmp	.Lclose_loop
.Lclose_file:
	sys_close
	incl	%ebx
.Lclose_loop:
	popq	%rdi
	cmpq	$STDOUT_FILENO, %rdi
	jne	.Lclose_file
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
