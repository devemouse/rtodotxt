#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'test/lib_tests.rb'

class Test1500_do < Test::Unit::TestCase

   def setup
      @env_bkp = ENV['TODOTXT_CFG_FILE']
      ENV['TODOTXT_CFG_FILE'] = '' unless (@env_bkp.nil? or @env_bkp == '')

      hideFile(ENV['TODOTXT_CFG_FILE'].to_s)
      hideFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      hideFile(File.join(ENV['HOME'].to_s, "todo.cfg"))

      @tmpdir = "temp"
      @todoFileName = 'todo.txt'
      Dir.mkdir(@tmpdir)

      @dotFname = File.expand_path("temp.cfg")

      open(@dotFname, 'w') { |f|
            f.puts "export TODO_DIR=\"#{@tmpdir}\"
export TODO_FILE=\"$TODO_DIR/#{@todoFileName}\"
"
      }
   end

   def teardown
      FileUtils.remove_entry_secure File.join(@tmpdir, @todoFileName)
      FileUtils.remove_entry_secure @dotFname
      FileUtils.remove_entry_secure @tmpdir

      # restore ENV
      ENV['TODOTXT_CFG_FILE'] = @env_bkp unless (@env_bkp.nil? or @env_bkp == '')

      restoreFile(ENV['TODOTXT_CFG_FILE'].to_s)
      restoreFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      restoreFile(File.join(ENV['HOME'].to_s, "todo.cfg"))
   end

   def test_do_with_string_argument_shall_return_nil
      createTodoFile(@tmpdir, @todoFileName, [
                 'fadfa',
                 'fadfa',
                 'fadfa',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       assert_equal(false, rtodo.do('B', 'B'))
   end

   def test_do_with_no_arguments
      createTodoFile(@tmpdir, @todoFileName, [
                 'fadfa',
                 'fadfa',
                 'fadfa',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       assert_equal(false, rtodo.do())
   end

   def test_basic_do
      createTodoFile(@tmpdir, @todoFileName, [
            'smell the uppercase Roses +flowers @outside',
            'notice the sunflowers',
            'stop',
            'remove1',
            'remove2',
            'remove3',
            'remove4',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       output = [
            '2 notice the sunflowers',
            '4 remove1',
            '5 remove2',
            '6 remove3',
            '7 remove4',
            '1 smell the uppercase Roses +flowers @outside',
            '3 stop',
       ]

       assert_equal(output, rtodo.ls)

       date = Time.now.strftime('%Y-%m-%d').to_s
       output = [
            '7 x ' + date + ' remove4',
            '6 x ' + date + ' remove3',
       ]

       #TODO: if someone passes '7,6' as cli argument, cli parser
       #is responsible for splitting that output.
       #RtodoCore shall be as fast as possible.
       #Later when I use this class in GUI version won't need extra
       #handling of '7,6' like input in here.
       #also output will be sorted
       assert_equal(output.sort, rtodo.do(7, 6).sort)

       output = [
            '2 notice the sunflowers',
            '4 remove1',
            '5 remove2',
            '1 smell the uppercase Roses +flowers @outside',
            '3 stop',
       ]

       assert_equal(output, rtodo.ls)

       output = [
            '5 x ' + date + ' remove2',
            '4 x ' + date + ' remove1',
       ]

       assert_equal(output.sort, rtodo.do(5, 4).sort)

   end
end

__END__
#!/bin/sh

test_description='do functionality
'
. ./test-lib.sh

#DATE=`date '+%Y-%m-%d'`

cat > todo.txt <<EOF
smell the uppercase Roses +flowers @outside
notice the sunflowers
stop
remove1
remove2
remove3
remove4
EOF

test_todo_session 'basic do' <<EOF
>>> todo.sh list
2 notice the sunflowers
4 remove1
5 remove2
6 remove3
7 remove4
1 smell the uppercase Roses +flowers @outside
3 stop
--
TODO: 7 of 7 tasks shown

>>> todo.sh do 7,6
7 x 2009-02-13 remove4
TODO: 7 marked as done.
6 x 2009-02-13 remove3
TODO: 6 marked as done.
x 2009-02-13 remove3
x 2009-02-13 remove4
TODO: $HOME/todo.txt archived.

>>> todo.sh -p list
2 notice the sunflowers
4 remove1
5 remove2
1 smell the uppercase Roses +flowers @outside
3 stop
--
TODO: 5 of 5 tasks shown

>>> todo.sh do 5 4
5 x 2009-02-13 remove2
TODO: 5 marked as done.
4 x 2009-02-13 remove1
TODO: 4 marked as done.
x 2009-02-13 remove1
x 2009-02-13 remove2
TODO: $HOME/todo.txt archived.

>>> todo.sh -p list
2 notice the sunflowers
1 smell the uppercase Roses +flowers @outside
3 stop
--
TODO: 3 of 3 tasks shown
EOF

test_todo_session 'fail multiple do attempts' <<EOF
>>> todo.sh -a do 3
3 x 2009-02-13 stop
TODO: 3 marked as done.

>>> todo.sh -a do 3
3 is already marked done
EOF
test_done
