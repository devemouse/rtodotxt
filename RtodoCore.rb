
class String
   def color(color)
      return "\e[" + color + "m" + self + "\e[0m"
   end
end

class Rtodo
   @opts = Hash.new
   attr_reader :short_help, :help, :long_help, :oneline_help

   def method_missing(method, *arg)
      puts "Rtodo can not %s" % method
   end

   def output
   end

   def initialize (params = {:dotfile => '',
                   :operation => '',
                   :parameter => ''})



      @oneline_help="rtodo [-fhpantvV] [-d todo_config] action [task_number] [task_description]"

      @short_help = "Usage: #{@oneline_help}\nTry 'rtodo -h' for more information."

      @help = "  Usage: #{@oneline_help}

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

      @long_help = "  Usage: #{@oneline_help}

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
   end
end
