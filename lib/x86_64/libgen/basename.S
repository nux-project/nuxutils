/* basename.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of the Nucleus Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

#define DIR_SEPARATOR '/

.section .rodata

__dot:
	.string	"."

.section .text
/* This function implements POSIX basename(3):
   char *
   basename (char * path);

   Input:
     %rdi -> path;

   Output:
     %rax -> pointer to a null-terminated string.
 */
DECL_FUNC(basename)

basename:
/* Make sure we do not have a NULL parameter */
	test	%rdi, %rdi
	jz	.Lreturn_dot
	pushq	%rdi	/* Save %rdi and align stack before function call */
	call	strlen
/* Remove trailing '/'s */
	movl	%eax, %ecx
	popq	%rsi
	leaq	-1(%rsi, %rcx), %rdi
	movb	$DIR_SEPARATOR, %al
	std
	repe scasb
	movb	$0, 1(%rsi, %rcx)
/* Get the last path component */
	repne scasb
/* If we stopped on a '/', adjust rdi */
	jne	.Lreturn
	incq	%rdi
.Lreturn:
	leaq	1(%rdi), %rax
	ret
.Lreturn_dot:
	movl	$__dot, %eax
	ret
