/* signal.h

   Copyright (C) 2017 Stefan Bidigaray

   Written by: Stefan Bidigaray
   Date: February 2017

   This file is part of Nucleus Utilities.

   This Source Code Form is subject to the terms of the Mozilla Public
   License, v. 2.0. If a copy of the MPL was not distributed with this
   file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

#ifndef __SIGNAL_H__
#define __SIGNAL_H__

/* Fake Signal Handlers */
#define SIG_DFL	0
#define SIG_ERR	-1
#define SIG_HOLD 2
#define SIG_IGN	1

/* Signals */
#define SIGHUP	1	/* Hangup. */
#define SIGINT	2	/* Terminal interrupt. */
#define SIGQUIT	3	/* Terminal quit. */
#define SIGILL	4	/* Illegal instruction. */
#define SIGTRAP	5	/* Trace/Breakpoint trap. */
#define SIGABRT	6	/* Process abort. */
#define SIGBUS	7	/* BUS error. */
#define SIGFPE	8	/* Floating-point exception. */
#define SIGKILL	9	/* Kill, unblockable. */
#define SIGUSR1	10	/* User-defined signal 1. */
#define SIGSEGV	11	/* Invalid memory reference. */
#define SIGUSR2	12	/* User-defined signal 2. */
#define SIGPIPE	13	/* Broken pipe. */
#define SIGALRM	14	/* Alarm clock. */
#define SIGTERM	15	/* Termination. */
#define SIGSTKFLT 16	/* Stack fault. */
#define SIGCHLD	17	/* Child status has changed. */
#define SIGCONT	18	/* Continue execution. */
#define SIGSTOP	19	/* Stop execution, unblockable. */
#define SIGTSTP	20	/* Keyboard stop. */
#define SIGTTIN	21	/* Background read from tty. */
#define SIGTTOU	22	/* Background write to tty. */
#define SIGURG	23	/* Urgent condition on socket. */
#define SIGXCPU	24	/* CPU limit exceeded. */
#define SIGXFSZ	25	/* File size limit exceeded. */
#define SIGVTALRM 26	/* Virtual alarm clock. */
#define SIGPROF	27	/* Profiling alarm clock. */
#define SIGWINCH 28	/* Window size change. */
#define SIGPOLL	SIGIO	/* Pollable event occurred. */
#define SIGIO	29	/* I/O now possible. */
#define SIGPWR	30	/* Power failure restart. */
#define SIGSYS	31	/* Bad system call. */
#define SIGUNUSED 31

#endif /* __SIGNAL_H__ */
