#!/usr/bin/env ruby

require 'pp'

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


$dotfile = Hash.new

$operation = 'help'
$modifier = nil
$hide_contexts = ''
$hide_projects = ''
$hide_priorities = ''


def parse_argv
   for i in 0..ARGV.length do
      el = ARGV[i]
      if el =~ /^list$/ then
         $operation = 'list'
         i += 1
         $modifier = Regexp.new(ARGV[i].to_s, Regexp::IGNORECASE) 
      end

      if el =~ /^a[d]*$/ then
         i+=1
         $operation = 'add'
         $modifier = ARGV[i,ARGV.length].join(' ')
         break
      end

      if el =~ /^(listproj|lsprj)$/ then
         $operation = 'listproj'
         $modifier = /.*(\+\w+).*/i
      end

      if el =~ /^(listpri|lsp)$/ then
         $operation = 'listpri'
         $modifier = /.*\([A-Z]+\).*/
      end

      if el =~ /^(listcon|lsc)$/ then
         $operation = 'listcon'
         $modifier = /.*(@\w+).*/i
      end

      if el =~ /-(@+)/ then
         if $1.length.odd?
            $hide_contexts = /@\w/
         end
      end

   end
end

def parse_dotfile
   File.new(File.join(ENV['HOME'].to_s, "todo.cfg")).each do |line| 
      if /^ *export *(.*)=[ '\"]*([^\s'\"]*)[\s'\"]*/.match(line) then
         $dotfile[$1] = $2
      end
   end
end


def get_todofile_name(dir, todo_file)
   #todo_file = name

   if todo_file.include?('/')
      todo_file = todo_file.split('/')
   else
      todo_file = todo_file.split('\\')
   end

   todo_file = todo_file.last

   File.join(dir, todo_file)
end

def list_prj
   parse_dotfile()
   input = File.new(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   output = Array.new

   input.sort.each_with_index do |line,i| 
      next if line.length <= 1

      if $modifier.match(line)
         output.push($1)
      end
   end
   output.uniq.each {|line| puts line}
end

def list
   parse_dotfile()
   input = File.new(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"])).to_a
   output = Array.new

   #input.map{|el| el.sub!(/^( +)(.*)/, ($1 == nil ? '' : (' ' * $1.length)) + ($2==nil ? '' : $2))}

   tasks_shown = 0
   tasks_overall = 0

   #go through case insensitive sorted list of lines
   input.sort{|x,y| x.casecmp(y)}.each_with_index do |line,i| 

      #skip empty lines
      next if line.length <= 1

      #apply filter
      if $modifier.match(line)
         #operate on copy not on original line
         line_mod = line

         #apply clearings and chomp newline at the end
         line_mod.sub!($hide_contexts,'').chomp!

         if /\(([A-Z])\)/.match(line_mod) 
            col = ($dotfile[$dotfile["PRI_#{$1}"][1..-1]])
            #puts 'col: ' + col

            if col.nil?
               col = ''
            else
               col.sub!('\\\\033[', '')
               col.sub!('m', '')
            end

            output.push("%02d %s".color(col) % [input.index(line)+1, line_mod])
            tasks_shown += 1

            col = ''
         else
            output.push("%02d %s" % [input.index(line)+1, line])
            tasks_shown += 1
         end
      end
      tasks_overall += 1
   end

   output.each {|line| puts line}

   [tasks_shown, tasks_overall]

end

def add (task)
   parse_dotfile()
   
   open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]), 'a') { |f|
      f.puts task
   }
   
end



parse_argv()
case $operation
when 'help'
   puts "rtodo list - lists all tasks"
   exit
when 'add'
   add $modifier.to_s
   puts'added one task: ' + $modifier.to_s
when 'list'
   a = list()
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when  'listproj'
   list_prj()
when 'listpri'
   a = list()
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when 'listcon'
   list_prj()
else
end

