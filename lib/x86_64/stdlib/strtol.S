/* strtol.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: October 2017

   This file is part of the Nux Utility Library.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
*/

#include "sysdep.h"
#include "errno.h"

.section .text

/* This function is equivalent to POSIX strlen(3).
   long int
   strtol (const char *nptr, char **endptr, int base);

   Input:
     %rdi -> Start of string.
     %rsi -> Pointer to end of string.
     %edx -> base (must be between 2 and 36, 0 is special value).

   Output:
     %rax -> long integer
 */
DECL_FUNC(strtol)

strtol:
	xchg	%rdi, %rsi	/* %rsi is now the start of the string */
	xorq	%rcx, %rcx	/* calculated value goes in %rcx */
	xorq	%rax, %rax
.Lskip_whitespace:
	lodsb
/* Whitespace is ' ' or 0x09 through 0x0D */
	cmpb	$0x20, %al
	je	.Lskip_whitespace
	subb	$0x09, %al
	cmpb	$4, %al
	jbe	.Lskip_whitespace
	movb	-1(%rsi), %al	/* Reload %al */
.Lread_sign:
	cmpb	$'+', %al
	je	.Lskip_sign
	cmpb	$'-', %al
	jne	.Lfind_base
	sete	-8(%rsp)
.Lskip_sign:
	lodsb
	test	%al, %al
	jz	.Leinval
.Lfind_base:
	test	%edx, %edx
	jz	.Lguess_base
	cmpl	$36, %edx
	jg	.Leinval
	cmpl	$2, %edx
	jl	.Leinval
	cmpl	$10, %edx
	jg	.Lread_number
	jmp	.Lread_number_dec
.Leinval:
	movl	$0, %eax
	movl	$EINVAL, (errno)
	ret
.Lguess_base:
	cmpb	$'0', %al
	jne	.Ldec
	lodsb
	orb	$0x20, %al
	cmpb	$'x', %al
	jne	.Loct
	movl	$16, %edx
/* This reads any number above base 10 */
.Lread_number:
	subb	$'0', %al
	cmpb	$10, %al
	jb	.Lread_number_add
	orb	$0x20, %al
	subb	$0x31-10, %al
	cmpb	%dl, %al
	jae	.Lend
.Lread_number_add:
	imulq	%rdx, %rcx
	js	.Lerange
	addq	%rax, %rcx
	js	.Lerange
	lodsb
	test	%al, %al
	jnz	.Lread_number
	jmp	.Lend
.Loct:
	movl	$8, %edx
	jmp	.Lread_number_dec
.Ldec:
	movl	$10, %edx
/* Read any number with base less than 10 */
.Lread_number_dec:
	subb	$'0', %al
	cmpb	%dl, %al
	jae	.Lend
	imulq	%rdx, %rcx
	js	.Lerange
	addq	%rax, %rcx
	js	.Lerange
	lodsb
	test	%al, %al
	jnz	.Lread_number_dec
.Lend:
/* Set *endptr if given */
	test	%rdi, %rdi
	jz	.Lreturn
	movq	(%rdi), %rdi
	leaq	-1(%rsi), %rdi
.Lreturn:
	movq	%rcx, %rax
	ret
.Lerange:
	movl	$0, %eax
	movl	$ERANGE, (errno)
	ret
