/* ln.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of Nux Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"
#include "asm/stat.h"

#define SIZEOF_STRUCT_STAT 144
#define OFFSET_ST_MODE 24
#define PATH_MAX 4096
#define DIR_SEPARATOR '/'

.lcomm .Lforce, 1
.lcomm .Lsymlink, 1
.lcomm .Lphysical, 1	/* Default behavior */
.lcomm .Ltarget_is_dir, 1

.section .data

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

_start:
	movq	%rsp, %rbp
	subq	$SIZEOF_STRUCT_STAT, %rsp	/* make room for struct stat */

getopt:
	movq	16(%rbp, %rbx, 8), %rsi
	test	%rsi, %rsi
	jz	.Linvalid_arg
	cmpb	$'-', (%rsi)
	jne	target_is_dir
	incq	%rsi
	incl	%ebx
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
.Lopt_f:
	cmpb	$'f', %al
	sete	(.Lforce)
	je	.Lread_opt
.Lopt_s:
	cmpb	$'s', %al
	sete	(.Lsymlink)
	je	.Lread_opt
/* FIXME: next 2 options not implemented */
.Lopt_L:
	cmpb	$'L', %al
	setne	(.Lphysical)
	je	.Lread_opt
.Lopt_P:	/* This is the default */
	cmpb	$'P', %al
	sete	(.Lphysical)
	je	.Lread_opt
.Lunknown_opt:
/* Add invalid option to _unknown_opt */
	movq	$.Linvalid, %rsi
	movb	%al, .Linvalid_loc(%rsi)
	movq	8(%rbp), %rdi
	call	strlen
/* Print argv[0] */
	movl	%eax, %edx
	movq	8(%rbp), %rsi
	movq	$STDERR_FILENO, %rdi
	sys_write
	movq	$.Linvalid, %rsi
	movq	$.Linvalid_len, %rdx
	/* %rdi already set */
	sys_write
.Linvalid_arg:
	movl	$EXIT_FAILURE, %edi
	sys_exit

.Lerror:
	movl	$EXIT_FAILURE, %edi
	sys_exit

target_is_dir:
	movq	(%rbp), %rcx
	movq	(%rbp, %rcx, 8), %rdi	/* Last argument */
	movq	%rsp, %rsi	/* pointer to struct stat in stack */
	sys_stat
	test	%rax, %rax
	jnz	do_link	/* file does not exist */
	movl	OFFSET_ST_MODE(%rsp), %eax	/* test IS_DIR */
	andl	$S_IFDIR, %eax
	cmpl	$S_IFDIR, %eax
	sete	.Ltarget_is_dir

do_link:
	movq	16(%rsp, %rbx, 8), %rsi
	movb	(.Ltarget_is_dir), %al
	test	%al, %al
	jz	.Lforce_link
/* concatenate dir path with file name */
	subq	$PATH_MAX, %rsp
	movq	%rsp, %rdi
	movq	(%rbp), %rcx
	movq	(%rbp, %rcx, 8), %rsi
	movq	$PATH_MAX, %rdx
	call	strlcpy
	movb	$DIR_SEPARATOR, (%rsp, %rax)
	movb	$0, 1(%rsp, %rax)
	movq	16(%rbp, %rbx, 8), %rdi
	call	basename
	movq	%rsp, %rdi
	movq	%rax, %rsi
	movq	$PATH_MAX, %rdx
	call	strlcat
	movq	%rsp, %rsi
.Lforce_link:
	movb	(.Lforce), %al
	test	%al, %al
	jz	.Llink_file
	movq	%rsi, %rdi
	sys_unlink
.Llink_file:
	movq	16(%rbp, %rbx, 8), %rdi
	movb	(.Lsymlink), %al
	test	%al, %al
	jnz	.Lsymlink_file
	sys_link
	test	%eax, %eax
	js	.Lerror
	jmp	.Lnext_file
.Lsymlink_file:
	sys_symlink
	test	%eax, %eax
	js	.Lerror
.Lnext_file:
	incl	%ebx
	movq	(%rbp), %rcx
	cmpl	%ebx, %ecx
	jne	do_link
.Lexit:
	movl	$EXIT_SUCCESS, %edi
	sys_exit
