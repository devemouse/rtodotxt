
#require 'RTask'
require 'pp'

class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

class Rtodo
   attr_reader :short_help, :help, :long_help, :oneline_help, :all_tasks, :opts
   PriorityRegexp   =   /\([A-Z]\) /
   PriorityRegexp_G = /\G\([A-Z]\) /
   ProjectRegexp    =   /(\+[^ ]+) /i
   ProjectRegexp_G  = /\G(\+[^ ]+) /i
   ContextRegexp    =   /(@[^ ]+) /i
   ContextRegexp_G  = /\G(@[^ ]+) /i

   def method_missing(method, *arg)
      false
   end

   def add(task, opt = {:add_time => false})
      _task = (((opt[:add_time] || (@opts[:dotfile]['TODOTXT_DATE_ON_ADD'] == '1')) ? Time.now.strftime('%Y-%m-%d') + ' ' : '' )+ task)

      tsk = {:text => _task, :line => (@all_tasks.length + 1) }

      @all_tasks.push(tsk)
      @all_tasks = @all_tasks.sort_by { |obj| obj[:text]}

      return (tsk[:line].to_s + ' ' + tsk[:text].to_s)
   end

   def list(*args)
      out = Array.new
      filtered_tasks = Array.new
      opt = Hash.new
      @all_tasks.each_with_index do |el,i|
         to_return = true

         unless args.nil?
            args.each do |param|
               if param.class == String
                  unless el[:text].match(Regexp.new(param.to_s, Regexp::IGNORECASE))
                     to_return = false
                     break
                  end
               else
                  opt = param
               end
            end
         end

         if to_return
            filtered_tasks.push el
         end
      end


      if filtered_tasks.length < 10
         len = 1
      else
         if filtered_tasks.length < 100
            len = 2
         else
            if filtered_tasks.length < 1000
               len = 3
            else
               len = 4
            end
         end
      end


      format = "%0#{len}d %s"

      filtered_tasks.each {|el|
         #print 'before '
         #pp el
         el[:text].sub!(PriorityRegexp,'') if opt[:hide_priority]
         el[:text].sub!(ProjectRegexp ,'') if opt[:hide_project]
         el[:text].sub!(ContextRegexp ,'') if opt[:hide_context]
         #print 'after '
         #pp el
         out.push(format % [(el[:line]), el[:text]]) unless (el[:text].empty?)
      }
      out
   end

   def do(*args)
      if args.empty?
         return false
      end

      list = @all_tasks
      out = Array.new
      to_out = Array.new

      #pp @all_tasks
      opt = Hash.new

      args.each do |param|
         if param.kind_of?(Fixnum)
            to_out.push param
         else
            if param.kind_of?(Hash)
               opt = param
            end
         end
      end

      date = Time.now.strftime('%Y-%m-%d').to_s

      unless to_out.empty?
         out = @all_tasks.select { |el| to_out.include?(el[:line])}

         out.map!{ |el| el[:line].to_s + ' x ' + date + ' ' + el[:text] }

         to_out.each { |el| self.del(el)} unless opt[:no_archive]
         return out
      else
         return false
      end
   end

   def lsp(priority = '')
      Array.new
   end

   def lsa(filter = '')
      Array.new
   end

   def del(item, opt = {:preserve_line_num => true, :term => ''})
      return false if item > @all_tasks.length

      out = ''
      renumber = false

      @all_tasks.map!{ |el| 
         if el[:line] == item 
            if opt[:term].nil? || opt[:term].empty?
               out = el[:line].to_s + ' ' + el[:text].to_s unless el[:text].empty?
               if true == opt[:preserve_line_num]
                  el[:text] = ''
               else
                  el = nil
                  renumber = true
               end
            else
               el[:text].sub!(Regexp.new(opt[:term].to_s), '')
               el[:text].squeeze!(' ')
               el[:text].strip!
               out = el[:line].to_s + ' ' + el[:text].to_s unless el[:text].empty?
            end
         end
         el
      }

      @all_tasks.compact!

      if renumber
         @all_tasks = @all_tasks.sort_by { |obj| obj[:line]}
         i = 1
         @all_tasks = @all_tasks.map!{|el| 
            if el[:text].empty?
               el = nil
            else
               el[:line] = i
               i+=1
            end
            el
         }
         @all_tasks.compact!
         @all_tasks = @all_tasks.sort_by { |obj| obj[:text]}
      end

      out.empty? ? false : out
   end

   def lsc()
      out = Array.new

      @all_tasks.each do |el|
         if el[:text].match(ContextRegexp)
            out.push($1)
            while $'.match(ContextRegexp_G)
               out.push($1)
            end
         end
      end
      out.uniq
   end

   def lsprj()
      out = Array.new

      @all_tasks.each do |el|
         if el[:text].match(ProjectRegexp)
            out.push($1)
            while $'.match(ProjectRegexp_G)
               out.push($1)
            end
         end
      end
      out.uniq
   end

   def addto(file, opt)
      if (File.exists?(file))
      else
         raise IOError
      end
   end

   def lf(file = "", filter = "")
      Array.new
   end

   def set(opt = '')
      case opt
      when '-@'
         false
      else
         false
      end
   end

   def output
   end

   def parse_dotfile(file_name)
      retval = nil
         retval = Hash.new
         open(file_name, 'r') { |f|
            f.each do |line|
               if /^ *export *(.*)=[ '\"]*([^\s'\"]*)[\s'\"]*/.match(line) then
                  retval[$1] = $2
               end
            end
         }
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

   def initialize (params = {:dotfile => '',
                   :operation => '',
                   :parameter => ''})
      @opts = params

      cfgfilesToCheck = [
         params[:dotfile],
         ENV['TODOTXT_CFG_FILE'],
         File.join(ENV['HOME'].to_s, ".todo" , "config"),
         File.join(ENV['HOME'].to_s, "todo.cfg")
      ]

      @opts[:dotfile] = nil

      cfgfilesToCheck.each do |el|
         if File.exists?(el.to_s)
            @opts[:dotfile] = parse_dotfile(el.to_s)
            break
         end
      end

      if @opts[:dotfile].nil?
         raise IOError
      end

      @all_tasks = Array.new

      unless @opts[:dotfile]["TODO_DIR"].nil? ||  @opts[:dotfile]["TODO_FILE"].nil?
         todoName = get_todofile_name(@opts[:dotfile]["TODO_DIR"], @opts[:dotfile]["TODO_FILE"])
         if File.exists?(todoName)
            open(todoName, 'r') { |f|
               i = 0
               @all_tasks = f.map do |line|
                  i+=1
                  {:text => line.chomp, :line => i}
               end
            }
         end
      end

      @all_tasks = @all_tasks.sort_by { |obj| obj[:text]}


      @oneline_help="rtodo [-fhpantvV] [-d todo_config] action [task_number] [task_description]"

      @short_help = "Usage: #{@oneline_help}\nTry 'rtodo -h' for more information."

      @help = "  Usage: #{@oneline_help}

  Actions: (X means not implemented yet)
     add|a \"THING I NEED TO DO +project @context\"
  #{self.addm                ? ' ' : 'X'} addm \"THINGS I NEED TO DO
    addto DEST \"TEXT TO ADD\"
        MORE THINGS I NEED TO DO\"
  #{self.append              ? ' ' : 'X'} append|app ITEM# \"TEXT TO APPEND\"
  #{self.archive             ? ' ' : 'X'} archive
  #{self.command             ? ' ' : 'X'} command [ACTIONS]
    del|rm ITEM# [TERM]
  #{self.depri               ? ' ' : 'X'} dp|depri ITEM#[, ITEM#, ITEM#, ...]
    do ITEM#[, ITEM#, ITEM#, ...]
  #{self.help                ? ' ' : 'X'} help
  #{self.list                ? ' ' : 'X'} list|ls [TERM...]
  #{self.listall             ? ' ' : 'X'} listall|lsa [TERM...]
  #{self.listcon             ? ' ' : 'X'} listcon|lsc
  #{self.listfile            ? ' ' : 'X'} listfile|lf SRC [TERM...]
  #{self.listpri             ? ' ' : 'X'} listpri|lsp [PRIORITY]
  #{self.listproj            ? ' ' : 'X'} listproj|lsprj
  #{self.move                ? ' ' : 'X'} move|mv ITEM# DEST [SRC]
  #{self.prepend             ? ' ' : 'X'} prepend|prep ITEM# \"TEXT TO PREPEND\"
  #{self.pri                 ? ' ' : 'X'} pri|p ITEM# PRIORITY
  #{self.replace             ? ' ' : 'X'} replace ITEM# \"UPDATED TODO\"
  #{self.report              ? ' ' : 'X'} report

  See \"help\" for more details."

      @long_help = "  Usage: #{@oneline_help}

  Actions:
    add \"THING I NEED TO DO +project @context\"
    a \"THING I NEED TO DO +project @context\"
      Adds THING I NEED TO DO to your todo.txt file on its own line.
      Project and context notation optional.
      Quotes optional.

  #{self.addm ? ' ' : 'X'} addm \"FIRST THING I NEED TO DO +project1 @context
    SECOND THING I NEED TO DO +project2 @context\"
      Adds FIRST THING I NEED TO DO to your todo.txt on its own line and
      Adds SECOND THING I NEED TO DO to you todo.txt on its own line.
      Project and context notation optional.
      Quotes optional.

    addto DEST \"TEXT TO ADD\"
      Adds a line of text to any file located in the todo.txt directory.
      For example, addto inbox.txt \"decide about vacation\"

  #{self.append ? ' ' : 'X'} append ITEM# \"TEXT TO APPEND\"
    app ITEM# \"TEXT TO APPEND\"
      Adds TEXT TO APPEND to the end of the task on line ITEM#.
      Quotes optional.

  #{self.archive ? ' ' : 'X'} archive
      Moves all done tasks from todo.txt to done.txt and removes blank lines.

  #{self.command ? ' ' : 'X'} command [ACTIONS]
      Runs the remaining arguments using only todo.sh builtins.
      Will not call any .todo.actions.d scripts.

    del ITEM# [TERM]
    rm ITEM# [TERM]
      Deletes the task on line ITEM# in todo.txt.
      If TERM specified, deletes only TERM from the task.

  #{self.depri ? ' ' : 'X'} depri ITEM#[, ITEM#, ITEM#, ...]
    dp ITEM#[, ITEM#, ITEM#, ...]
      Deprioritizes (removes the priority) from the task(s)
      on line ITEM# in todo.txt.

    do ITEM#[, ITEM#, ITEM#, ...]
      Marks task(s) on line ITEM# as done in todo.txt.

  #{self.help ? ' ' : 'X'} help
      Display this help message.

  #{self.list ? ' ' : 'X'} list [TERM...]
    ls [TERM...]
      Displays all tasks that contain TERM(s) sorted by priority with line
      numbers.  If no TERM specified, lists entire todo.txt.

  #{self.listall ? ' ' : 'X'} listall [TERM...]
    lsa [TERM...]
      Displays all the lines in todo.txt AND done.txt that contain TERM(s)
      sorted by priority with line  numbers.  If no TERM specified, lists
      entire todo.txt AND done.txt concatenated and sorted.

  #{self.listcon ? ' ' : 'X'} listcon
    lsc
      Lists all the task contexts that start with the @ sign in todo.txt.

  #{self.listfile ? ' ' : 'X'} listfile SRC [TERM...]
    lf SRC [TERM...]
      Displays all the lines in SRC file located in the todo.txt directory,
      sorted by priority with line  numbers.  If TERM specified, lists
      all lines that contain TERM in SRC file.

  #{self.listpri ? ' ' : 'X'} listpri [PRIORITY]
    lsp [PRIORITY]
      Displays all tasks prioritized PRIORITY.
      If no PRIORITY specified, lists all prioritized tasks.

  #{self.listproj ? ' ' : 'X'} listproj
    lsprj
      Lists all the projects that start with the + sign in todo.txt.

  #{self.move ? ' ' : 'X'} move ITEM# DEST [SRC]
    mv ITEM# DEST [SRC]
      Moves a line from source text file (SRC) to destination text file (DEST).
      Both source and destination file must be located in the directory defined
      in the configuration directory.  When SRC is not defined
      it's by default todo.txt.

  #{self.prepend ? ' ' : 'X'} prepend ITEM# \"TEXT TO PREPEND\"
    prep ITEM# \"TEXT TO PREPEND\"
      Adds TEXT TO PREPEND to the beginning of the task on line ITEM#.
      Quotes optional.

  #{self.pri ? ' ' : 'X'} pri ITEM# PRIORITY
    p ITEM# PRIORITY
      Adds PRIORITY to task on line ITEM#.  If the task is already
      prioritized, replaces current priority with new PRIORITY.
      PRIORITY must be an uppercase letter between A and Z.

  #{self.replace ? ' ' : 'X'} replace ITEM# \"UPDATED TODO\"
      Replaces task on line ITEM# with UPDATED TODO.

  #{self.report ? ' ' : 'X'} report
      Adds the number of open tasks and done tasks to report.txt.



  Options:
  #{self.set('-@') ? ' ' : 'X'} -@
        Hide context names in list output. Use twice to show context
        names (default).
  #{self.set('-+') ? ' ' : 'X'} -+
        Hide project names in list output. Use twice to show project
        names (default).
  #{self.set('-d') ? ' ' : 'X'} -d CONFIG_FILE
        Use a configuration file other than the default ~/.todo/config
  #{self.set('-f') ? ' ' : 'X'} -f
        Forces actions without confirmation or interactive input
  #{self.set('-h') ? ' ' : 'X'} -h
        Display a short help message
  #{self.set('-p') ? ' ' : 'X'} -p
        Plain mode turns off colors
  #{self.set('-P') ? ' ' : 'X'} -P
        Hide priority labels in list output. Use twice to show
        priority labels (default).
  #{self.set('-a') ? ' ' : 'X'} -a
        Don't auto-archive tasks automatically on completion
  #{self.set('-n') ? ' ' : 'X'} -n
        Don't preserve line numbers; automatically remove blank lines
        on task deletion
  #{self.set('-t') ? ' ' : 'X'} -t
        Prepend the current date to a task automatically
        when it's added.
  #{self.set('-v') ? ' ' : 'X'} -v
        Verbose mode turns on confirmation messages
  #{self.set('-vv') ? ' ' : 'X'} -vv
        Extra verbose mode prints some debugging information
  #{self.set('-V') ? ' ' : 'X'} -V
        Displays version, license and credits
  #{self.set('-x') ? ' ' : 'X'} -x
        Disables TODOTXT_FINAL_FILTER


        Environment variables:
        #{self.set('TODOTXT_AUTO_ARCHIVE')          ? ' ' : 'X'} TODOTXT_AUTO_ARCHIVE=0          is same as option -a
        #{self.set('TODOTXT_CFG_FILE')              ? ' ' : 'X'} TODOTXT_CFG_FILE=CONFIG_FILE    is same as option -d CONFIG_FILE
        #{self.set('TODOTXT_FORCE')                 ? ' ' : 'X'} TODOTXT_FORCE=1                 is same as option -f
        #{self.set('TODOTXT_PRESERVE_LINE_NUMBERS') ? ' ' : 'X'} TODOTXT_PRESERVE_LINE_NUMBERS=0 is same as option -n
        #{self.set('TODOTXT_PLAIN')                 ? ' ' : 'X'} TODOTXT_PLAIN=1                 is same as option -p
        #{self.set('TODOTXT_DATE_ON_ADD')           ? ' ' : 'X'} TODOTXT_DATE_ON_ADD=1           is same as option -t
        #{self.set('TODOTXT_VERBOSE')               ? ' ' : 'X'} TODOTXT_VERBOSE=1               is same as option -v
        #{self.set('TODOTXT_DEFAULT_ACTION')        ? ' ' : 'X'} TODOTXT_DEFAULT_ACTION=\"\"       run this when called with no arguments
        #{self.set('TODOTXT_SORT_COMMAND')          ? ' ' : 'X'} TODOTXT_SORT_COMMAND=\"sort ...\" customize list output
        #{self.set('TODOTXT_FINAL_FILTER')          ? ' ' : 'X'} TODOTXT_FINAL_FILTER=\"sed ...\"  customize list after color, P@+ hiding"
   end

   alias_method :ls, :list
   alias_method :listpri, :lsp
   alias_method :listall, :lsa
   alias_method :listcon, :lsc
   alias_method :listproj, :lsprj
   alias_method :listfile, :lf
end
