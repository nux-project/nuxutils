/* env.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

/* %rbp points to argv without argv[0]
   %r15 points to envp
   %rsp is going to be used to build the modified envp
 */	
_start:
	popq	%rcx
	popq	%rdi
	movq	%rsp, %rbp
	leaq	(%rsp, %rcx, 8), %r15

getopt:
	movq	(%rbp, %rbx, 8), %rsi
	test	%rsi, %rsi
	jz	printenv	/* No variables */
	lodsb
	cmpb	$'-, %al
	jne	env	/* We have a command */
	incl	%ebx
	lodsb
	cmpb	$'i, %al
	je	.Lignore_env
	cmpb	$0, %al
	je	.Lignore_env
.Lunknown_opt:
/* Add invalid option to .Linvalid */
	movl	$.Linvalid, %esi
	movb	%al, .Linvalid_loc(%esi)
/* Print argv[0] */
	movq	%rdi, %rbp
	call	strlen
	movl	%eax, %edx
	movq	%rbp, %rsi
	movl	$STDERR_FILENO, %edi
	sys_write
	movl	$.Linvalid, %esi
	movl	$.Linvalid_len, %edx
/* %edi already set */
	sys_write
	movl	$EXIT_FAILURE, %edi
	sys_exit

printenv:
	xorl	%ebx, %ebx
	jmp	.Lprintenv_loop
.Lprintenv:
	call	strlen
	movl	$STDOUT_FILENO, %edi
	movq	(%r15, %rbx, 8), %rsi
	movb	$'\n, (%rsi, %rax)
	leaq	1(%eax), %rdx
	sys_write
	incl	%ebx
.Lprintenv_loop:
	movq	(%r15, %rbx, 8), %rdi
	testq	%rdi, %rdi
	jnz	.Lprintenv
	xorl	%edi, %edi
	sys_exit

.Lignore_env:
	movq	$0, (%r15)	/* Clear envp */
env:
	movq	(%rbp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jz	printenv
	call	strlen
	movl	%eax, %r12d
	cld
/* Check for modified environment by checking for '=' */
	movq	(%rbp, %rbx, 8), %rdi
	movl	%r12d, %ecx
	movb	$'=, %al
	repne scasb
	jne	exec
	xorl	%edx, %edx
	jmp	.Lputenv_next
putenv:
	incl	%edx
	movq	(%rbp, %rbx, 8), %rdi
	movl	%r12d, %ecx
	repe cmpsb
	test	%ecx, %ecx
	jnz	.Lputenv_next
	cmpb	$'=, (%rdi)
	jne	.Lputenv_next
	movq	(%rbp, %rbx, 8), %rsi
	movq	%rsi, (%r15, %rdx, 8)
.Lputenv_next:
	movq	(%r15, %rdx, 8), %rsi
	test	%rsi, %rsi
	jnz	putenv
.Lputenv_add:
	movq	%rbp, %rsp	/* Reset %rsp */
	movl	%edx, %ecx
	jrcxz	.Lend_copy
.Lcopy_var:
	pushq	(%r15, %rcx, 8)
	loop	.Lcopy_var
.Lend_copy:
	pushq	(%r15)
	pushq	(%rbp, %rbx, 8)
	movq	%rsp, %r15
	incl	%ebx
	jmp	env
exec:
	movq	(%rbp, %rbx, 8), %rdi
	leaq	(%rbp, %rbx, 8), %rsi
	movq	%r15, %rdx
	sys_execve
/* execve() should never return! */
.Lerror:
	negl	%eax
	movl	%eax, %edi
	sys_exit
