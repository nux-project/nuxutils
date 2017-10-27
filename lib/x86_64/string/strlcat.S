/* strlcat.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: October 2017

   This file is part of Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

/* size_t
   strlcat (char *dst, const char *src, size_t size);

   This is a safer version of strncat (). It will appends, at most,
   size - strlen (dst) - 1 bytes, NUL-terminating the result.
 */
DECL_FUNC(strlcat)

strlcat:
/* Skip stack pointer magic. This isn't safe, but this function is
   small and easy to keep track of this. */
	push	%rdi
	push	%rsi
	push	%rdx
	movq	%rdx, %rsi
	call	strnlen
	pop	%rdx
	pop	%rsi
	pop	%rdi
	push	%rax	/* save result of strnlen (src, size) */
	subq	%rax, %rdx
	leaq	(%rdi, %rax), %rdi
	call	strlcpy
	pop	%rdx
	addq	%rdx, %rax	/* add strlen (dst) to return value */

	ret
