#!/usr/bin/perl

$f = fork; if(!$f) { sleep 10; print "Child\n"; exit(0); } sleep 5; print "Parent\n"
