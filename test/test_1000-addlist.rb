#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'

class Test1000_addlist < Test::Unit::TestCase

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

   def test_add
      task = 'conquer the world'
      assert_equal('1 ' + task, @rtodo.add(task))
   end

   def test_add_and_list
      task = 'conquer the world'
      assert_equal('1 ' + task, @rtodo.add(task))
      assert_equal(['1 ' + task], @rtodo.ls)

      task = 'be a milionare'
      assert_equal('2 ' + task, @rtodo.add(task))
      assert_equal('2 ' + task, @rtodo.ls[1])
   end

   def test_add_and_list_filtered
      @rtodo.add('conquer the World')
      @rtodo.add('be a milionare')

      #filtering shall be case insensitive
      assert_equal(['1 conquer the World'], @rtodo.list('world'))
      assert_equal(['2 be a milionare'], @rtodo.list('milion'))
   end

   def test_add_with_and
      #not sure why original author needed this test but I reproduced it ;)
      tasks = ['conquer the World',
               'be a milionare',
               'be the best & the preetiest']
      @rtodo.add(tasks[0])
      @rtodo.add(tasks[1])
      @rtodo.add(tasks[2])

      assert_equal(['3 ' + tasks[2]], @rtodo.list('pree'))
   end

   def teardown
      FileUtils.remove_entry_secure @tmpdir
      FileUtils.remove_entry_secure @dotFname
   end

end

__END__
#!/bin/sh

test_description='basic add and list functionality

This test just makes sure the basic add and list
command work, including support for filtering.
'
. ./test-lib.sh

>>> todo.sh list
4 dig the garden & water the flowers
1 notice the daisies
2 smell the roses
3 smell the uppercase Roses
--
TODO: 4 of 4 tasks shown

EOF

test_done
