#!/usr/bin/env ruby

# Copyright (c) 2016 Kevin Paulisse
#
# This script is freely distributable under the terms of Apache 2.0 license.
# http://www.apache.org/licenses/LICENSE-2.0
#
# Find the source code, report issues, and contribute at:
# https://github.com/kpaulisse/scripts

require 'bundler/setup'
require 'optparse'
require 'process'
require 'timeout'
require 'sys/proctable'

@ps = ['/usr/bin/ps', '/bin/ps'].detect { |ps| File.executable?(ps) }
options = { :sig => 'KILL', :timeout => nil, :command => nil }

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [-s <signal>] -t <timeout> -c <command>"
  opts.on('-t TIMEOUT', '--timeout=SECONDS', 'Timeout in seconds') do |t|
    options[:timeout] = t.to_i
  end
  opts.on('-c COMMAND', '--command=COMMAND', 'Command') do |c|
    options[:command] = c
  end
  opts.on('-s SIGNAL', '--signal=SIGNAL', 'signal') do |s|
    options[:sig] = s
  end
end.parse!

raise "Timeout not specified; see #{File.basename(__FILE__)} --help" if options[:timeout].nil?
raise 'Invalid timeout: must be numeric and positive' unless options[:timeout] > 0
raise "Command not specified; see #{File.basename(__FILE__)} --help" if options[:command].nil?
@timeout = options[:timeout]
@command = options[:command]
@signal = options[:sig]

# Get all processes in the given session (except do not include ourselves)
# @param setsid [Fixnum] Session ID
# @return [Array<Fixnum>] Process IDs in session
def get_processes(setsid)
  proclist = Sys::ProcTable.ps
  result = []
  proclist.each do |proc|
    next if proc.pid == Process.pid
    if (Struct::ProcTableStruct.method_defined?(:session))
      result << proc if proc.session == setsid
    elsif (Struct::ProcTableStruct.method_defined?(:pgid))
      result << proc if proc.pgid == setsid
    end
  end
  result
end

# Kill all processes in the given session (except do not kill ourselves)
# @param setsid [Fixnum] Session ID
def reaper(setsid)
  proclist = get_processes(setsid)
  result = []
  proclist.each do |proc|
    begin
      Process.kill(@signal, proc.pid)
      result << proc
    rescue Errno::ESRCH
      # It's already gone!
    end
  end
  result
end

# Fork and get a session ID in which to run the long-running command.
# Then spawn off the command in this session.
intermediate_pid = fork do
  setsid = Process.setsid
  child_pid = fork { exec @command }
  exit_code = nil
  begin
    exit_code = Timeout::timeout(@timeout) do
      Process.wait(child_pid)
      $?.exitstatus
    end
  rescue Timeout::Error
    exit_code = 254
  end
  killed_list = reaper(setsid)
  killed_list.each do |proc|
    STDERR.puts "#{File.basename(__FILE__)} killed pid=#{proc.pid} ppid=#{proc.ppid} [#{proc.cmdline}]"
  end
  exit exit_code
end

Process.wait(intermediate_pid)
exit $?.exitstatus
