#!/usr/bin/perl

$f = fork; if(!$f) { sleep 10; print "Child\n"; exit(0); } else { sleep 15; print "Parent\n"; }
