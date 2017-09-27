/* dirname.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: September 2017

   This file is part of the Nux Utility Library.

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
/* This function implements POSIX dirname(3):
   char *dirname (char * path);

   Input:
     %rdi -> path;

   Output:
     %rax -> pointer to a null-terminated string.
 */
DECL_FUNC(dirname)

dirname:
/* Make sure we do not have a NULL */
	test	%rdi, %rdi
	jz	.Lreturn_dot

	pushq	%rdi	/* Save %rdi and align stack before function call. */
/* Get string length and remove trailing '/'s */
	call	strlen
	movq	(%rsp), %rdi
	addq	%rax, %rdi
	decq	%rdi	/* Point to last character */
	movl	%eax, %ecx
	movb	$DIR_SEPARATOR, %al
	std
	repe scasb
	incq	%rdi	/* Readjust %rdi due to scasb decrement */
	incl	%ecx	/* Readjust %ecx due to loop decrement */
.Lremove_trailing_dir:
/* Now find last '/' and decide what to do. */
	repne scasb
	jne	.Lreturn_dot
	test	%ecx, %ecx
	jnz	.Lterminate_path
	incl	%ecx
.Lterminate_path:
	popq	%rax
	movb	$0, (%rax, %rcx)
	ret
.Lreturn_dot:
/* Return "." */
	popq	%rax	/* Undo push, above */
	movl	$__dot, %eax
	ret
