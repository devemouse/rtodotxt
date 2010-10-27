#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'

class Test1010_date < Test::Unit::TestCase

   def setup
      @tmpdir = "temp"
      Dir.mkdir(@tmpdir)

      @dotFname = File.expand_path("temp.cfg")

      open(@dotFname, 'w') { |f|
            f.puts "export TODO_DIR=\"#{@tmpdir}\"
export TODO_FILE=\"$TODO_DIR/todo.txt\"
"
      }

       @rtodo = Rtodo.new({:dotfile => @dotFname})
   end

   def test_add_list_time
      tasks = ['conquer the World']

      assert_equal('1 ' + Time.now.strftime('%Y-%m-%d') + ' ' + tasks[0], @rtodo.add(tasks[0], :add_time => true))

      assert_equal(['1 ' + Time.now.strftime('%Y-%m-%d') + ' ' + tasks[0]], @rtodo.ls)
   end

   def test_add_list_time_from_cfg
      #add auto parse option
      open(@dotFname, 'a') { |f|
            f.puts "export TODOTXT_DATE_ON_ADD=1"
      }

      #reparse dotfile
      @rtodo = Rtodo.new({:dotfile => @dotFname})

      tasks = ['conquer the World']
      assert_equal('1 ' + Time.now.strftime('%Y-%m-%d') + ' ' + tasks[0], @rtodo.add(tasks[0]))

      assert_equal(['1 ' + Time.now.strftime('%Y-%m-%d') + ' ' + tasks[0]], @rtodo.ls)
   end

   def teardown
      FileUtils.remove_entry_secure @tmpdir
      FileUtils.remove_entry_secure @dotFname
   end

end

__END__
#!/bin/sh

test_description='test the date on add feature

Tests paths by which we might automatically add
a date to each item.
'
. ./test-lib.sh


# Switch to config file
echo "export TODOTXT_DATE_ON_ADD=1" >> todo.cfg

# Bump the clock, for good measure.
test_tick 3600

test_todo_session 'config file third day' <<EOF
>>> todo.sh add take out the trash
4 2009-02-15 take out the trash
TODO: 4 added.

>>> todo.sh list
1 2009-02-13 notice the daisies
2 2009-02-14 smell the roses
3 2009-02-15 mow the lawn
4 2009-02-15 take out the trash
--
TODO: 4 of 4 tasks shown
EOF

test_done
