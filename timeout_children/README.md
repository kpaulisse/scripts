timeout_children.rb
===================

Script to launch a process in its own session, and wait for that process to exit or a timeout to occur.

Upon process exit, the script checks for any remaining processes in the session and kills them. The exit code from the original process is returned.

Upon timeout, the script kills the process, and any remaining processes in the session. Exit code 254 is returned.

### Usage

```
Usage: timeout_children.rb [-s <signal>] -t <timeout> -c <command>
    -t, --timeout=SECONDS            Timeout in seconds
    -c, --command=COMMAND            Command
    -s, --signal=SIGNAL              signal
```

`-t` (timeout) and `-c` (command) are required.

Optionally specify the signal to use when killing processes (`KILL` is the default).

### Examples

`fork_and_die.pl`

Synopsis: Parent process spawns a child process that prints "Child" and exits after 10 seconds. Parent process prints "Parent" and exits after **5** seconds.

```
$ ./timeout_children.rb -t 2 -c ./test/fork_and_die.pl
timeout_children.rb killed pid=4738 ppid=4737 [/usr/bin/perl ./test/fork_and_die.pl] # This was the child
timeout_children.rb killed pid=4737 ppid=4736 [/usr/bin/perl ./test/fork_and_die.pl] # This was the parent
```

```
$ ./timeout_children.rb -t 7 -c ./test/fork_and_die.pl
Parent
timeout_children.rb killed pid=4762 ppid=4761 [/usr/bin/perl ./test/fork_and_die.pl] # This was the child
```

```
$ ./timeout_children.rb -t 12 -c ./test/fork_and_die.pl
Parent
timeout_children.rb killed pid=4762 ppid=4761 [/usr/bin/perl ./test/fork_and_die.pl] # This was the child
```

NOTE: In the final example, the child process was killed immediately after the parent died on its own because control was returned to the timeout script.

`fork_and_wait.pl`

Synopsis: Parent process spawns a child process that prints "Child" and exits after 10 seconds. Parent process prints "Parent" and exits after **15** seconds.

```
$ ./timeout_children.rb -t 2 -c ./test/fork_and_wait.pl
timeout_children.rb killed pid=4841 ppid=4840 [/usr/bin/perl ./test/fork_and_wait.pl] # This was the child
timeout_children.rb killed pid=4840 ppid=4839 [/usr/bin/perl ./test/fork_and_wait.pl] # This was the parent
```

```
$ ./timeout_children.rb -t 12 -c ./test/fork_and_wait.pl
Child
timeout_children.rb killed pid=12402 ppid=12399 [/usr/bin/perl ./test/fork_and_wait.pl] # Parent, killed
timeout_children.rb killed pid=12406 ppid=12402 [fork_and_wait.p] # Child, now a zombie
```

```
$ ./timeout_children.rb -t 17 -c ./test/fork_and_wait.pl
Child
# Wait 5 seconds
Parent
```
