/* true.S

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: August 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, you can obtain one at http://mozilla.org/MPL/2.0/.
 */

#include "sysdep.h"

#if !defined(EXIT_STATUS)
#define EXIT_STATUS 0
#endif

.section .text
	.global _start

_start:
	movl	$EXIT_STATUS, %edi
	sys_exit
