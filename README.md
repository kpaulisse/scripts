@kpaulisse's Miscellaneous Scripts
==================================

## Overview

Collection of things I've written that don't warrant a project of their own, but are shared in hopes that they might be useful to someone.

## The Scripts

#### Timeout Children Shell Utility

Link: https://github.com/kpaulisse/scripts/tree/master/timeout_children

Language: Ruby

Intended for: Linux

Description: Sets a timeout on a process, and when that process exits (or times out), kills any child processes that might have been spawned as well. Use case: a program fires off a child process, the parent exits, the child process gets inherited by `init` and spins forever with no good way of tracking down the process from which it originally forked.

## Legal

Everything here is released under the terms of the [Apache 2.0 License](./LICENSE).

If you need a different license for some reason, please feel free to contact me and I'm sure we can work something out.
