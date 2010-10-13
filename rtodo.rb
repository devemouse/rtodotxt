#!/usr/bin/env ruby
#
#TODO: line numbers are generated wrong way.
#
#BUG: deleting a task does not remove the line but only clears it
#

require 'pp'
require 'RtodoCore'

unless RUBY_PLATFORM.include?('linux')
begin
  require 'Win32/Console/ANSI' #if RUBY_PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
end
end

class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

$params = Hash.new

$hiders = {
   :hide_contexts => //,
   :hide_projects => //,
   :hide_priorities => //
}



def parse_argv

   cfgfilesToCheck = [
      ENV['TODOTXT_CFG_FILE'],
      File.join(ENV['HOME'].to_s, ".todo" , "config"),
      File.join(ENV['HOME'].to_s, "todo.cfg")
   ]

   for i in 0..ARGV.length do
      el = ARGV[i]
      if el =~ /^(list|ls)$/ then
         $params[:operation] = 'list'
         i += 1
         $params[:parameter] = Regexp.new(ARGV[i].to_s, Regexp::IGNORECASE) 
      end

      if el =~ /^a[d]*$/ then
         i+=1
         $params[:operation] = 'add'
         $params[:parameter] = ARGV[i,ARGV.length].join(' ')
         break
      end

      if el =~ /^addm$/ then
         i+=1
         $params[:operation] = 'addm'
         $params[:parameter] = ARGV[i,ARGV.length].join(' ')
         break
      end

      if el =~ /^(del|rm)$/ then
         $params[:operation] = 'del'
         i+=1
         $params[:parameter] = Array.new(2)
         $params[:parameter][0] = ARGV[i]
         $params[:parameter][1] = ARGV[i+1,ARGV.length]
         break
      end

      if el =~ /^(listproj|lsprj)$/ then
         $params[:operation] = 'listproj'
         $params[:parameter] = /.*(\+\w+).*/i
      end

      if el =~ /^(listpri|lsp)$/ then
         $params[:operation] = 'listpri'
         $params[:parameter] = /.*\([A-Z]\).*/
      end

      if el =~ /^report$/ then
         $params[:operation] = 'report'
      end

      if el =~ /^help$/ then
         $params[:operation] = 'longhelp'
      end

      if el =~ /^(listall|lsa)$/ then
         $params[:operation] = 'listall'
         i += 1
         $params[:parameter] = Regexp.new(ARGV[i].to_s, Regexp::IGNORECASE) 
      end

      if el =~ /^(listcon|lsc)$/ then
         $params[:operation] = 'listcon'
         $params[:parameter] = /.*(@\w+).*/i
      end

      if el =~ /^do$/ then
         $params[:operation] = 'do'
         i+=1
         $params[:parameter] = ARGV[i,ARGV.length]
      end

      if ((el =~ /^-h$/) || (el =~ /^--help$/)) then
         $params[:operation] = 'help'
      end

      if el =~ /-(@+)/ then
         if $1.length.odd? then
            $hiders[:hide_contexts] = /@\w+/
         end
      end

      if el =~ /-d/ then
         puts 'config file changing'
         i+=1
         cfgfilesToCheck.unshift(ARGV[i])
      end

      if el =~ /-(\++)/ then
         if $1.length.odd?
            $hiders[:hide_projects] = /\+\w+/
         end
      end

      if el =~ /-(P+)/ then
         if $1.length.odd?
            $hiders[:hide_priorities] = /\([A-Z]\) */
         end
      end
   end

   if $params[:operation].nil?
      $params[:operation] = 'shorthelp'
   end

   cfgfilesToCheck.each do |el|
      $params[:dotfile] = parse_dotfile(el.to_s)
   end

   if $params[:dotfile].nil?
      puts "Fatal Error: Cannot read configuration file #{cfgfilesToCheck.find{|el| !el.nil?}}"
         exit
   end
end

def parse_dotfile(file_name)
   retval = Hash.new
   if File.exists?(file_name)
      File.new(file_name).each do |line| 
         if /^ *export *(.*)=[ '\"]*([^\s'\"]*)[\s'\"]*/.match(line) then
            retval[$1] = $2
         end
      end 
   end
   retval
end


def get_todofile_name(dir, todo_file)
   if todo_file.include?('/')
      todo_file = todo_file.split('/')
   else
      todo_file = todo_file.split('\\')
   end

   todo_file = todo_file.last

   File.join(dir, todo_file)
end

def list_prj
   input = File.new(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))
   output = Array.new

   input.sort.each_with_index do |line,i| 
      next if line.length <= 1

      if $params[:parameter].match(line)
         output.push($1)
      end
   end
   output.uniq.each {|line| puts line}
end

def _do
   input = File.new(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"])).to_a
   output = Array.new
   done = Array.new

   input.each_with_index do |el, i|
      if $params[:parameter].include?((i+1).to_s)
         #puts (i+1).to_s + "  " + el.to_s
         done.push("x " + Time.now.strftime("%Y-%m-%d") + ' ' +  el)
      else
         output.push(el)
      end
   end
   
   print "output: "
   pp output

   print "  done: "
   pp done

   File.open(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]), 'w') { |f|
      output.each do |el|
      f.puts el
      end
   }

   File.open(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["DONE_FILE"]), 'a') { |f|
      done.each do |el|
      f.puts el
      end
   }
end

def _del
   todo = File.readlines(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))

   $params[:parameter][0] = $params[:parameter][0].to_i

   if $params[:parameter][0] == 0
      puts "usage: #{File.basename(__FILE__,File.extname(__FILE__))} del ITEM# [TERM]"
      return
   end

   if $params[:parameter][1].nil? || $params[:parameter][1].empty?
      puts "Delete '#{todo[$params[:parameter][0]-1].chomp}'?  (y/n)"
      answer = STDIN.gets.chomp

      case answer
      when 'y'
         puts "%d %s" % [$params[:parameter][0], todo[$params[:parameter][0]-1]]
         todo[$params[:parameter][0]-1] = ''
         puts "TODO: %s deleted." % $params[:parameter][0]
      else
         puts "TODO: No tasks were deleted."
      end
   else
      puts "%d %s" % [$params[:parameter][0], todo[$params[:parameter][0]-1]]

      $params[:parameter][1] = $params[:parameter][1].join(' ')
      if Regexp.new(".*" + $params[:parameter][1] + ".*").match(todo[$params[:parameter][0]-1])
         puts "TODO: Removed '#{$params[:parameter][1]}' from task."
         todo[$params[:parameter][0]-1].sub!($params[:parameter][1], '')
         puts "%d %s" % [$params[:parameter][0], todo[$params[:parameter][0]-1]]
      else
         puts "TODO: '#{$params[:parameter][1]}' not found; no removal done."
      end
   end

   File.open(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]), 'w') { |f|
      todo.each do |el|
      f.puts el
      end
   }
end

def list(file, tasks_shown = 0, tasks_overall = 0, opts = {:colors => true})
   offset = tasks_overall

   input = File.new(file).to_a
   output = Array.new

   #go through case insensitive sorted list of lines
   input.sort{|x,y| x.casecmp(y)}.each_with_index do |line,i| 

      #skip empty lines
      next if line.length <= 1

      #apply filter
      if $params[:parameter].match(line)
         #operate on copy not on original line
         line_mod = line

         #apply clearings and chomp newline at the end
         line_mod.chomp!

         color_output = (/\(([A-Z])\)/.match(line_mod) && opts[:colors])
         pri = $1

         $hiders.each do |key, hider|
            line.sub!(hider,'')
         end

         if color_output
            col = ($params[:dotfile][$params[:dotfile]["PRI_#{pri}"][1..-1]])

            if col.nil?
               col = ''
            else
               col.sub!('\\\\033[', '')
               col.sub!('m', '')
            end

            output.push("%02d %s".color(col) % [input.index(line)+1+offset, line_mod])
            tasks_shown += 1

            col = ''
         else
            output.push("%02d %s" % [input.index(line)+1+offset, line])
            tasks_shown += 1
         end
      end
      tasks_overall += 1
   end

   output.each {|line| puts line}

   [tasks_shown, tasks_overall]
end

def add (task)
   
   open(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]), 'a') { |f|
      f.puts task
   }
end

def report
   todo = File.readlines(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"])).length
   done = File.readlines(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["DONE_FILE"])).length

   open(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["REPORT_FILE"]), 'a') { |f|
      f.puts(Time.now.strftime("%Y-%m-%d-%H:%M:%S") + ' ' + todo.to_s + ' ' + done.to_s)
   }

   report = File.readlines(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["REPORT_FILE"]))

   puts "TODO: Report file updated."
   report.each {|el| puts el}
end

#############################################################################################
parse_argv()

rtodo = Rtodo.new $params

case $params[:operation]
when 'shorthelp'
   puts rtodo.short_help
   exit
when 'help'
   puts rtodo.help
   exit
when 'longhelp'
   puts rtodo.long_help
   exit
when 'addm'
   $params[:parameter].split("\n").each do |el|
   add el
   lines = File.readlines(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))
   puts lines.length.to_s + " " + el
   puts 'TODO: ' + lines.length.to_s + ' added.'
   end
when 'add'
   add $params[:parameter].to_s
   puts'added one task: ' + $params[:parameter].to_s
when 'list'
   a = list(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when  'listproj'
   list_prj()
when 'listpri'
   a = list(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when 'listcon'
   list_prj()
when 'listall'
   a = list(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["TODO_FILE"]))
   a = list(get_todofile_name($params[:dotfile]["TODO_DIR"], $params[:dotfile]["DONE_FILE"]), a[0], a[1], {:colors => false})

   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when 'do'
   _do
when 'del'
   _del
when 'report'
   report
end





