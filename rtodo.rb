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


for i in 0..ARGV.length do
   el = ARGV[i]
   if el =~ /list/
      $operation = 'list'
      i += 1
      $modifier = ARGV[i]
   end

   if el =~ /a[dd]/
      i+=1
      $operation = 'add'
      $modifier = ARGV[i,ARGV.length].join(' ')
      break
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

def list
   def push_line(line)
   end
   parse_dotfile()
   input = File.new(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   output = Array.new

   #input.map{|el| el.sub!(/^( +)(.*)/, ($1 == nil ? '' : (' ' * $1.length)) + ($2==nil ? '' : $2))}


   tasks_shown = 0
   tasks_overall = 0

   input.sort.each_with_index do |line,i| 
      next if line.length <= 1

      if (($modifier != nil) && (Regexp.new($modifier, Regexp::IGNORECASE ).match(line)) ||
          ($modifier == nil))
         if /\(([A-Z])\)/.match(line) 
            col = ($dotfile[$dotfile["PRI_#{$1}"][1..-1]])
            #puts 'col: ' + col

            if col.nil?
               col = ''
            else
               col.sub!('\\\\033[', '')
               col.sub!('m', '')
            end

            output.push(line.color(col))
            tasks_shown += 1

            col = ''
         else
            output.push(line)
            tasks_shown += 1
         end
      end
      tasks_overall += 1
   end

   output.each {|line| print line}

   puts '--'
   puts "TODO: #{tasks_shown} of #{tasks_overall} tasks shown"

end

def add (task)
   parse_dotfile()
   
   open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]), 'a') { |f|
      f.puts task
   }
   
end



case $operation
when 'help'
   puts "rtodo list - lists all tasks"
   exit
when 'add'
   add $modifier
   puts'added one task: ' + $modifier
when 'list'
   list()
end

