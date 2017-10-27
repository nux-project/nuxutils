/* strnlen.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: October 2017

   This file is part of the Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"

.section .text

/* size_t
   strnlen (const char *s, size_t maxlen);

   This function is equivalent to POSIX strnlen(3).
 */
DECL_FUNC(strnlen)

strnlen:
	xorb	%al, %al
	movq	%rsi, %rcx
	cld
	repnz scasb
	movq	%rsi, %rax
	jnz	.Lreturn
	subq	%rcx, %rax
	decq	%rax
.Lreturn:
	ret
