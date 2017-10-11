/* strlen.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: January 2017

   This file is part of the Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .text

/* This function is equivalent to POSIX strlen(3).
   size_t
   strlen (const char *s);

   Input:
     %rdi -> Pointer to start of string.

   Output:
     %rax -> Length of string.

   Variables:
     %al  -> nul-byte.
     %rdi -> String destination index.
     %ecx -> Maximum string length.
 */
DECL_FUNC(strlen)

strlen:
	movq	%rdi, %r8
	xorb	%al, %al
	movl	$0xffffffff, %ecx	/* Maximum string length is 4GB. */
	cld	/* Clear DF */

	repnz scasb	/* Loop until (%rdi) == %al. */

	subq	%r8, %rdi
	movl	%edi, %eax

	decl	%eax	/* No reason to decq, %eax cannot be larger than 4GB */
	ret
