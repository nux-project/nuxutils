/* printenv.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "inc/sysdep.h"
#include "inc/syscall.h"

.section .data

.Lexit_status:
	.long	EXIT_SUCCESS

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ .Linvalid_len, . - .Linvalid
	.equ .Linvalid_loc, 21

.section .text
	.global _start

_start:
	popq	%rcx
	/* %rsp = argv */
	leaq	8(%rsp, %rcx, 8), %rbp	/* %rbp = envp */
	popq	%rsi	/* %rsi = *argv++ */
	movb	$'\n, %r15b	/* load new line character */

getopt:
	movq	(%rsp), %rdi
	test	%rdi, %rdi
	jz	printenv	/* No variables, print everything */
/* If *argv != "-0", then print environment variables specified */
	cmpb	$'-, (%rdi)
	jne	getenv
	movb	1(%rdi), %al
	testb	%al, %al	/* Check for unknown options */
	jz	getenv
	cmpb	$'0, %al
	jne	.Lunknown_opt
	movb	$'\0, %r15b
	addq	$PTR_SIZE, %rsp
	jmp	getopt	/* Check next value */
.Lunknown_opt:
	movl	$.Linvalid, %edi
	movb	%al, .Linvalid_loc(%edi)
/* Print argv[0] */
	movq	%rsi, %rdi
	movq	%rdi, %rbx
	call	strlen
	movl	%eax, %edx
	movq	%rbx, %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
/* Print message */
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$2, %edi
	sys_exit

getenv:
	xorl	%ebx, %ebx
	call	strlen
.Lgetenv:
	movq	(%rbp, %rbx, 8), %rdi
	testq	%rdi, %rdi
	sete	(.Lexit_status)	/* if envp[i] == NULL, then exit_status = 1 */
	jz	.Lgetenv_next_var
	movl	%eax, %ecx
	movq	(%rsp), %rsi	/* reload *argv */
	incl	%ebx	/* i++ */
	repe cmpsb
	test	%ecx, %ecx
	jnz	.Lgetenv
	cmpb	$'=, (%rdi)
	jne	.Lgetenv
	incq	%rdi
	movq	%rdi, %r12	/* save %rdi */
	call	strlen
	movl	$STDOUT_FILENO, %edi
	movq	%r12, %rsi	/* reload */
	movb	%r15b, (%rsi, %rax)
	leal	1(%eax), %edx
	sys_write
.Lgetenv_next_var:
	addq	$PTR_SIZE, %rsp	/* argv++ */
	movq	(%rsp), %rdi
	test	%rdi, %rdi
	jnz	getenv
.Lexit:
	movl	(.Lexit_status), %edi
	sys_exit

printenv:
	xorl	%ebx, %ebx
	jmp	.Lprintenv_loop
.Lprintenv:
	call	strlen
	movl	$STDOUT_FILENO, %edi
	movq	(%rbp, %rbx, 8), %rsi
	movb	%r15b, (%rsi, %rax)
	leaq	1(%eax), %rdx
	sys_write
	incl	%ebx
.Lprintenv_loop:
	movq	(%rbp, %rbx, 8), %rdi
	testq	%rdi, %rdi
	jnz	.Lprintenv
	movl	$EXIT_SUCCESS, %edi
	sys_exit
