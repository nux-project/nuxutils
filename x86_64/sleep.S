/* sleep.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.equ MINUTE, 60
.equ HOUR, MINUTE * 60
.equ DAY, HOUR * 24

#define TS_SIZE 16
#define TV_SEC 0
#define TV_NSEC 8

.section .data

.Linvalid:
	.ascii	": invalid suffix -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

_start:
	movq	%rsp, %rbp
	subq	$TS_SIZE, %rsp

/* Using %ecx instead of %ebx for index because this program
   does not call any functions, so we do not have to worry about
   saving this value.
 */
.Lread_argv:
	movq	16(%rbp, %rcx, 8), %rsi	/* get argv[i] */
	test	%rsi, %rsi
	jz	sleep
	incl	%ecx
.Lread_digit:
	lodsb
	test	%al, %al
	jz	.Ls_implicit
	cmpb	$'9, %al
	jg	.Ls
	subb	$'0, %al
	js	.Linvalid_suffix
	imulq	$10, %rdx
	jo	.Lexit_error	/* Overflow means number is too large */
	addq	%rax, %rdx
	jno	.Lread_digit
.Lexit_error:
	movl	$EXIT_FAILURE, %edi
	sys_exit
.Linvalid_suffix:
/* Add invalid option to _unknown_opt */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_loc(%esi)
	movq	8(%rbp), %rdi
/* Print argv[0] */
	call	strlen
	movl	%eax, %edx
	movq	8(%rbp), %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
	/* %rdi already set */
	sys_write
	movl	$EXIT_FAILURE, %edi
	sys_exit
.Ls:
	cmpb	$'s, %al
	jne	.Lm
.Lend_arg:
	lodsb
	test	%al, %al
	jnz	.Linvalid_suffix
.Ls_implicit:	/* 's' is the default suffix */
	addq	%rdx, (%rsp)
	xorq	%rdx, %rdx
	jmp	.Lread_argv
.Lm:
	cmpb	$'m, %al
	jne	.Lh
	imulq	$MINUTE, %rdx
	jmp	.Lend_arg
.Lh:
	cmpb	$'h, %al
	jne	.Ld
	imulq	$HOUR, %rdx
	jmp	.Lend_arg
.Ld:
	cmpb	$'d, %al
	jne	.Linvalid_suffix
	imulq	$DAY, %rdx
	jmp	.Lend_arg

sleep:
	movq	%rsp, %rsi
	movq	%rsp, %rdi
	sys_nanosleep
	test	%eax, %eax
	js	.Lexit_error
	jnz	sleep
	movl	$EXIT_SUCCESS, %edi
	sys_exit
