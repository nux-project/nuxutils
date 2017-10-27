/* strlcpy.S

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
   strlcpy (char *dst, const char *src, size_t size);

   This is a safer version of strncpy (). It will copy up to size - 1 bytes,
   NUL-terminating the result.
 */
DECL_FUNC(strlcpy)

strlcpy:
/* Skip stack pointer magic. This isn't safe, but this function is
   small and easy to keep track of this. */
	push	%rdi
	push	%rsi
	push	%rdx
	movq	%rsi, %rdi
	call	strlen
	pop	%rdx
	pop	%rsi
	pop	%rdi
	test	%rdx, %rdx
	jz	.Lreturn
	movq	%rax, %rcx
	cmpq	%rcx, %rdx
	ja	.Lstrcpy
	leaq	-1(%rdx), %rcx
.Lstrcpy:
	cld
	rep movsb
	movb	$0, (%rdi)
.Lreturn:
	ret
