#!/usr/bin/env ruby

require 'pp'

begin
  require 'Win32/Console/ANSI' #if RUBY_PLATFORM =~ /win32/
rescue LoadError
  raise 'You must gem install win32console to use color on Windows'
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
      $operation = 'add'
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
      if (($modifier != nil) && (Regexp.new($modifier, Regexp::IGNORECASE ).match(line)) ||
          ($modifier == nil))
         if /\(([A-Z])\)/.match(line) 
            col = ($dotfile[$dotfile["PRI_#{$1}"][1..-1]])
            #puts 'col: ' + col

            col.sub!('\\\\033[', '')
            col.sub!('m', '')

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

def add
   parse_dotfile()
   input = get_todofile($dotfile["TODO_DIR"], $dotfile["TODO_FILE"])
   input 
end



case $operation
when 'help'
   puts "rtodo list - lists all tasks"
   exit
when 'add'
   puts'add'
when 'list'
   list()
end

