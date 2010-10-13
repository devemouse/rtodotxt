#!/usr/bin/env ruby
#
#TODO: line numbers are generated wrong way.
#
#BUG: deleting a task does not remove the line but only clears it
#

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

$operation = ''
$cfg_file = nil
$modifier = nil
$hiders = {
   :hide_contexts => //,
   :hide_projects => //,
   :hide_priorities => //
}


$oneline_usage="#{File.basename(__FILE__,File.extname(__FILE__))} [-fhpantvV] [-d todo_config] action [task_number] [task_description]"
$short_help = "  Usage: #{$oneline_usage}

  Actions: (X means not implemented yet)
    add|a \"THING I NEED TO DO +project @context\"
    addm \"THINGS I NEED TO DO
  X addto DEST \"TEXT TO ADD\"
          MORE THINGS I NEED TO DO\"
  X append|app ITEM# \"TEXT TO APPEND\"
  X archive
  X command [ACTIONS]
    del|rm ITEM# [TERM]
  X dp|depri ITEM#[, ITEM#, ITEM#, ...]
    do ITEM#[, ITEM#, ITEM#, ...]
    help
    list|ls [TERM...]
    listall|lsa [TERM...]
    listcon|lsc
  X listfile|lf SRC [TERM...]
    listpri|lsp [PRIORITY]
    listproj|lsprj
  X move|mv ITEM# DEST [SRC]
  X prepend|prep ITEM# \"TEXT TO PREPEND\"
  X pri|p ITEM# PRIORITY
  X replace ITEM# \"UPDATED TODO\"
    report

  See \"help\" for more details."

$long_help = "  Usage: #{$oneline_usage}

  Actions:
    add \"THING I NEED TO DO +project @context\"
    a \"THING I NEED TO DO +project @context\"
      Adds THING I NEED TO DO to your todo.txt file on its own line.
      Project and context notation optional.
      Quotes optional.

    addm \"FIRST THING I NEED TO DO +project1 @context
    SECOND THING I NEED TO DO +project2 @context\"
      Adds FIRST THING I NEED TO DO to your todo.txt on its own line and
      Adds SECOND THING I NEED TO DO to you todo.txt on its own line.
      Project and context notation optional.
      Quotes optional.

  X addto DEST \"TEXT TO ADD\"
      Adds a line of text to any file located in the todo.txt directory.
      For example, addto inbox.txt \"decide about vacation\"

  X append ITEM# \"TEXT TO APPEND\"
    app ITEM# \"TEXT TO APPEND\"
      Adds TEXT TO APPEND to the end of the task on line ITEM#.
      Quotes optional.

  X archive
      Moves all done tasks from todo.txt to done.txt and removes blank lines.

  X command [ACTIONS]
      Runs the remaining arguments using only todo.sh builtins.
      Will not call any .todo.actions.d scripts.

    del ITEM# [TERM]
    rm ITEM# [TERM]
      Deletes the task on line ITEM# in todo.txt.
      If TERM specified, deletes only TERM from the task.

  X depri ITEM#[, ITEM#, ITEM#, ...]
    dp ITEM#[, ITEM#, ITEM#, ...]
      Deprioritizes (removes the priority) from the task(s)
      on line ITEM# in todo.txt.

    do ITEM#[, ITEM#, ITEM#, ...]
      Marks task(s) on line ITEM# as done in todo.txt.

    help
      Display this help message.

    list [TERM...]
    ls [TERM...]
      Displays all tasks that contain TERM(s) sorted by priority with line
      numbers.  If no TERM specified, lists entire todo.txt.

    listall [TERM...]
    lsa [TERM...]
      Displays all the lines in todo.txt AND done.txt that contain TERM(s)
      sorted by priority with line  numbers.  If no TERM specified, lists
      entire todo.txt AND done.txt concatenated and sorted.

    listcon
    lsc
      Lists all the task contexts that start with the @ sign in todo.txt.

  X listfile SRC [TERM...]
    lf SRC [TERM...]
      Displays all the lines in SRC file located in the todo.txt directory,
      sorted by priority with line  numbers.  If TERM specified, lists
      all lines that contain TERM in SRC file.

    listpri [PRIORITY]
    lsp [PRIORITY]
      Displays all tasks prioritized PRIORITY.
      If no PRIORITY specified, lists all prioritized tasks.

    listproj
    lsprj
      Lists all the projects that start with the + sign in todo.txt.

  X move ITEM# DEST [SRC]
    mv ITEM# DEST [SRC]
      Moves a line from source text file (SRC) to destination text file (DEST).
      Both source and destination file must be located in the directory defined
      in the configuration directory.  When SRC is not defined
      it's by default todo.txt.

  X prepend ITEM# \"TEXT TO PREPEND\"
    prep ITEM# \"TEXT TO PREPEND\"
      Adds TEXT TO PREPEND to the beginning of the task on line ITEM#.
      Quotes optional.

  X pri ITEM# PRIORITY
    p ITEM# PRIORITY
      Adds PRIORITY to task on line ITEM#.  If the task is already
      prioritized, replaces current priority with new PRIORITY.
      PRIORITY must be an uppercase letter between A and Z.

  X replace ITEM# \"UPDATED TODO\"
      Replaces task on line ITEM# with UPDATED TODO.

    report
      Adds the number of open tasks and done tasks to report.txt.



  Options:
    -@
        Hide context names in list output. Use twice to show context
        names (default).
    -+
        Hide project names in list output. Use twice to show project
        names (default).
    -d CONFIG_FILE
        Use a configuration file other than the default ~/.todo/config
  X -f
        Forces actions without confirmation or interactive input
  X -h
        Display a short help message
  X -p
        Plain mode turns off colors
    -P
        Hide priority labels in list output. Use twice to show
        priority labels (default).
  X -a
        Don't auto-archive tasks automatically on completion
  X -n
        Don't preserve line numbers; automatically remove blank lines
        on task deletion
  X -t
        Prepend the current date to a task automatically
        when it's added.
  X -v
        Verbose mode turns on confirmation messages
  X -vv
        Extra verbose mode prints some debugging information
  X -V
        Displays version, license and credits
  X -x
        Disables TODOTXT_FINAL_FILTER


  Environment variables:
  X TODOTXT_AUTO_ARCHIVE=0          is same as option -a
    TODOTXT_CFG_FILE=CONFIG_FILE    is same as option -d CONFIG_FILE
  X TODOTXT_FORCE=1                 is same as option -f
  X TODOTXT_PRESERVE_LINE_NUMBERS=0 is same as option -n
  X TODOTXT_PLAIN=1                 is same as option -p
  X TODOTXT_DATE_ON_ADD=1           is same as option -t
  X TODOTXT_VERBOSE=1               is same as option -v
  X TODOTXT_DEFAULT_ACTION=\"\"       run this when called with no arguments
  X TODOTXT_SORT_COMMAND=\"sort ...\" customize list output
  X TODOTXT_FINAL_FILTER=\"sed ...\"  customize list after color, P@+ hiding"

def parse_argv

   cfgfilesToCheck = [
      ENV['TODOTXT_CFG_FILE'],
      File.join(ENV['HOME'].to_s, ".todo" , "config"),
      File.join(ENV['HOME'].to_s, "todo.cfg")
   ]

   for i in 0..ARGV.length do
      el = ARGV[i]
      if el =~ /^(list|ls)$/ then
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

      if el =~ /^addm$/ then
         i+=1
         $operation = 'addm'
         $modifier = ARGV[i,ARGV.length].join(' ')
         break
      end

      if el =~ /^(del|rm)$/ then
         $operation = 'del'
         i+=1
         $modifier = Array.new(2)
         $modifier[0] = ARGV[i]
         $modifier[1] = ARGV[i+1,ARGV.length]
         break
      end

      if el =~ /^(listproj|lsprj)$/ then
         $operation = 'listproj'
         $modifier = /.*(\+\w+).*/i
      end

      if el =~ /^(listpri|lsp)$/ then
         $operation = 'listpri'
         $modifier = /.*\([A-Z]\).*/
      end

      if el =~ /^report$/ then
         $operation = 'report'
      end

      if el =~ /^help$/ then
         $operation = 'longhelp'
      end

      if el =~ /^(listall|lsa)$/ then
         $operation = 'listall'
         i += 1
         $modifier = Regexp.new(ARGV[i].to_s, Regexp::IGNORECASE) 
      end

      if el =~ /^(listcon|lsc)$/ then
         $operation = 'listcon'
         $modifier = /.*(@\w+).*/i
      end

      if el =~ /^do$/ then
         $operation = 'do'
         i+=1
         $modifier = ARGV[i,ARGV.length]
      end

      if ((el =~ /^-h$/) || (el =~ /^--help$/)) then
         $operation = 'help'
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
      
      if el =~ /^--help$/ then
      end

   end

   if $operation == ''
      $operation = 'shorthelp'
   end

   cfgfilesToCheck.each do |el|
      if File.exists?(el.to_s)
         $cfg_file = el.to_s
      end
   end

   if $cfg_file.nil?
      puts "Fatal Error: Cannot read configuration file #{cfgfilesToCheck.find{|el| !el.nil?}}"
         exit
   end

   #if $cfg_file.nil? || !File.exists?($cfg_file)
      #checkDefaultDotfile()
   #end
end

def checkDefaultDotfile
   if File.exists?(File.join(ENV['HOME'].to_s, "todo.cfg"))
      $cfg_file = File.join(ENV['HOME'].to_s, "todo.cfg")
   else
      puts "Fatal Error: Cannot read configuration file #{$cfg_file}"
      exit
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

def _do
   input = File.new(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"])).to_a
   output = Array.new
   done = Array.new

   input.each_with_index do |el, i|
      if $modifier.include?((i+1).to_s)
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

   File.open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]), 'w') { |f|
      output.each do |el|
      f.puts el
      end
   }

   File.open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["DONE_FILE"]), 'a') { |f|
      done.each do |el|
      f.puts el
      end
   }
end

def _del
   todo = File.readlines(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))

   $modifier[0] = $modifier[0].to_i

   if $modifier[0] == 0
      puts "usage: #{File.basename(__FILE__,File.extname(__FILE__))} del ITEM# [TERM]"
      return
   end

   if $modifier[1].nil? || $modifier[1].empty?
      puts "Delete '#{todo[$modifier[0]-1].chomp}'?  (y/n)"
      answer = STDIN.gets.chomp

      case answer
      when 'y'
         puts "%d %s" % [$modifier[0], todo[$modifier[0]-1]]
         todo[$modifier[0]-1] = ''
         puts "TODO: %s deleted." % $modifier[0]
      else
         puts "TODO: No tasks were deleted."
      end
   else
      puts "%d %s" % [$modifier[0], todo[$modifier[0]-1]]

      $modifier[1] = $modifier[1].join(' ')
      if Regexp.new(".*" + $modifier[1] + ".*").match(todo[$modifier[0]-1])
         puts "TODO: Removed '#{$modifier[1]}' from task."
         todo[$modifier[0]-1].sub!($modifier[1], '')
         puts "%d %s" % [$modifier[0], todo[$modifier[0]-1]]
      else
         puts "TODO: '#{$modifier[1]}' not found; no removal done."
      end
   end

   File.open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]), 'w') { |f|
      todo.each do |el|
      f.puts el
      end
   }
end

def list(file, tasks_shown = 0, tasks_overall = 0, opts = {:colors => true})
   offset = tasks_overall

   input = File.new(file).to_a
   output = Array.new

   #input.map{|el| el.sub!(/^( +)(.*)/, ($1 == nil ? '' : (' ' * $1.length)) + ($2==nil ? '' : $2))}

   #go through case insensitive sorted list of lines
   input.sort{|x,y| x.casecmp(y)}.each_with_index do |line,i| 

      #skip empty lines
      next if line.length <= 1

      #apply filter
      if $modifier.match(line)
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
            col = ($dotfile[$dotfile["PRI_#{pri}"][1..-1]])
            #puts 'col: ' + col

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
   
   open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]), 'a') { |f|
      f.puts task
   }
end

def report
   todo = File.readlines(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"])).length
   done = File.readlines(get_todofile_name($dotfile["TODO_DIR"], $dotfile["DONE_FILE"])).length

   open(get_todofile_name($dotfile["TODO_DIR"], $dotfile["REPORT_FILE"]), 'a') { |f|
      f.puts(Time.now.strftime("%Y-%m-%d-%H:%M:%S") + ' ' + todo.to_s + ' ' + done.to_s)
   }

   report = File.readlines(get_todofile_name($dotfile["TODO_DIR"], $dotfile["REPORT_FILE"]))

   puts "TODO: Report file updated."
   report.each {|el| puts el}
end


parse_argv()
parse_dotfile()

case $operation
when 'help'
   puts $short_help
   exit
when 'addm'
   $modifier.split("\n").each do |el|
   add el
   lines = File.readlines(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   puts lines.length.to_s + " " + el
   puts 'TODO: ' + lines.length.to_s + ' added.'
   end
when 'add'
   add $modifier.to_s
   puts'added one task: ' + $modifier.to_s
when 'list'
   a = list(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when  'listproj'
   list_prj()
when 'listpri'
   a = list(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when 'listcon'
   list_prj()
when 'listall'
   a = list(get_todofile_name($dotfile["TODO_DIR"], $dotfile["TODO_FILE"]))
   a = list(get_todofile_name($dotfile["TODO_DIR"], $dotfile["DONE_FILE"]), a[0], a[1], {:colors => false})

   puts '--'
   puts "TODO: #{a[0]} of #{a[1]} tasks shown"
when 'do'
   _do
when 'del'
   _del
when 'report'
   report
when 'shorthelp'
   puts "Usage: #{$oneline_usage}
   Try '#{File.basename(__FILE__,File.extname(__FILE__))} -h' for more information."
when 'longhelp'
   puts $long_help
   exit
end

