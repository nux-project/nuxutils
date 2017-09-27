/* sync.S

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

.Lfile_data:
	.byte	0

.Lfile_system:
	.byte	0

.Linvalid:
	.ascii	": invalid option -- '\0'\n"
	.equ	.Linvalid_len, . - .Linvalid - 1
	.equ	.Linvalid_loc, 21

.section .text
	.global _start

/* %r15b - Holds OPT info */
_start:
	pop	%rcx
	pop	%rdi	/* get argv[0] and align stack */

getopt:
	movq	(%rsp, %rbx, 8), %rsi	/* get argv[i] */
	test	%rsi, %rsi
	jz	sync
	cmpb	$'-, (%rsi)
	jne	fsync
	incq	%rsi
	incl	%ebx
.Lread_opt:
	lodsb
	test	%al, %al
	jz	getopt
	cmpb	$'d, %al
	seteb	(.Lfile_data)
	je	.Lread_opt
#if defined(SYS_syncfs)
	cmpb	$'f, %al
	seteb	(.Lfile_system)
	je	.Lread_opt
#endif
.Lunknown_opt:
	movq	%rdi, %rbx	/* save argv[0] */
/* Add invalid option to _unknown_opt */
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
	sys_write
.Linvalid_arg:
	movl	$EXIT_FAILURE, %edi
	sys_exit

sync:
	movb	(.Lfile_data), %al
	test	%al, %al
	jnz	.Linvalid_arg
	sys_sync
	movl	$EXIT_SUCCESS, %edi
	jmp	exit

fsync:
	movq	%rsi, %rdi
	movl	$O_RDONLY, %esi
.Lfsync_loop:
	sys_open
	test	%eax, %eax
	js	.Lerror_exit
	movl	%eax, %edi
#if defined(SYS_syncfs)
.Lsyncfs:
	movb	(.Lfile_system), %al
	test	%al, %al
	jnz	.Lfdatasync
	sys_syncfs
	test	%eax, %eax
	js	.Lerror_exit
	jmp	.Lclose
#endif
.Lfdatasync:
	movb	(.Lfile_data), %al
	test	%al, %al
	jnz	.Lfsync
	sys_fdatasync
	test	%eax, %eax
	js	.Lerror_exit
	jmp	.Lclose
.Lfsync:
	sys_fsync
.Lclose:
	sys_close
.Lnext_file:
	incl	%ebx
	movq	(%rsp, %rbx, 8), %rdi
	test	%rdi, %rdi
	jnz	.Lfsync_loop
exit:
	sys_exit

.Lerror_exit:
	sys_close
	negl	%eax
	movl	%eax, %edi
	sys_exit
