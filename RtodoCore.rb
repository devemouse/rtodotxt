
class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

class Rtodo
   attr_reader :short_help, :help, :long_help, :oneline_help, :all_tasks

   def method_missing(method, *arg)
      false
   end

   def ls(filter = '')
      Array.new
   end

   def lsp(priority = '')
      Array.new
   end

   def lsa(filter = '')
      Array.new
   end

   def lsc()
      Array.new
   end

   def lsprj()
      Array.new
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
      if File.exists?(file_name)
         retval = Hash.new
         File.new(file_name).each do |line| 
            if /^ *export *(.*)=[ '\"]*([^\s'\"]*)[\s'\"]*/.match(line) then
               retval[$1] = $2
            end
         end 
      end
      retval
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
            @opts[:dotfile] = 1
         end
      end

      if @opts[:dotfile].nil?
         raise IOError
      end

      @all_tasks = Array.new



      @oneline_help="rtodo [-fhpantvV] [-d todo_config] action [task_number] [task_description]"

      @short_help = "Usage: #{@oneline_help}\nTry 'rtodo -h' for more information."

      @help = "  Usage: #{@oneline_help}

  Actions: (X means not implemented yet)
  #{self.add                 ? ' ' : 'X'} add|a \"THING I NEED TO DO +project @context\"
  #{self.addm                ? ' ' : 'X'} addm \"THINGS I NEED TO DO
  #{self.addto               ? ' ' : 'X'} addto DEST \"TEXT TO ADD\"
        MORE THINGS I NEED TO DO\"
  #{self.append              ? ' ' : 'X'} append|app ITEM# \"TEXT TO APPEND\"
  #{self.archive             ? ' ' : 'X'} archive
  #{self.command             ? ' ' : 'X'} command [ACTIONS]
  #{self.del                 ? ' ' : 'X'} del|rm ITEM# [TERM]
  #{self.depri               ? ' ' : 'X'} dp|depri ITEM#[, ITEM#, ITEM#, ...]
  #{self.do                  ? ' ' : 'X'} do ITEM#[, ITEM#, ITEM#, ...]
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
  #{self.add ? ' ' : 'X'} add \"THING I NEED TO DO +project @context\"
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

  #{self.addto ? ' ' : 'X'} addto DEST \"TEXT TO ADD\"
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

  #{self.del ? ' ' : 'X'} del ITEM# [TERM]
    rm ITEM# [TERM]
      Deletes the task on line ITEM# in todo.txt.
      If TERM specified, deletes only TERM from the task.

  #{self.depri ? ' ' : 'X'} depri ITEM#[, ITEM#, ITEM#, ...]
    dp ITEM#[, ITEM#, ITEM#, ...]
      Deprioritizes (removes the priority) from the task(s)
      on line ITEM# in todo.txt.

  #{self.do ? ' ' : 'X'} do ITEM#[, ITEM#, ITEM#, ...]
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

   alias_method :list, :ls
   alias_method :listpri, :lsp
   alias_method :listall, :lsa
   alias_method :listcon, :lsc
   alias_method :listproj, :lsprj
   alias_method :listfile, :lf
end
