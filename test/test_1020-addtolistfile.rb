#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'test/lib_tests.rb'

class Test1020_addToListFile < Test::Unit::TestCase

   def setup
      @env_bkp = ENV['TODOTXT_CFG_FILE']
      ENV['TODOTXT_CFG_FILE'] = '' unless (@env_bkp.nil? or @env_bkp == '')

      hideFile(ENV['TODOTXT_CFG_FILE'].to_s)
      hideFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      hideFile(File.join(ENV['HOME'].to_s, "todo.cfg"))

      @tmpdir = "temp"
      Dir.mkdir(@tmpdir)

      @dotFname = File.expand_path("temp.cfg")

      open(@dotFname, 'w') { |f|
            f.puts "export TODO_DIR=\"#{@tmpdir}\"
export TODO_FILE=\"$TODO_DIR/todo.txt\"
"
      }

      @tmpFileName = "garden.txt"

      @rtodo = Rtodo.new({:dotfile => @dotFname})
   end



   def test_addto_not_existing_file
      #skip("Not sure if RtodoCore will support addto directly. This would be higher level task.")
      #assert_raise(IOError) { @rtodo.addto(@tmpFileName, 'notice the daisies')}
   end


   def test_addto_existing_file
      #skip("Not sure if RtodoCore will support addto directly. This would be higher level task.")
      #File.open(@tmpFileName, 'w') {|f| }
      #assert_nothing_raised(IOError) {
         #task = 'be a misionare'
         #assert_equal('1 ' + task, @rtodo.addto(@tmpFileName, task))
      #}
   end

   def teardown
      FileUtils.remove_entry_secure @tmpdir
      FileUtils.remove_entry_secure @dotFname
      FileUtils.remove_entry_secure @tmpFileName if File.exists?(@tmpFileName)

      # restore ENV
      ENV['TODOTXT_CFG_FILE'] = @env_bkp unless (@env_bkp.nil? or @env_bkp == '')

      restoreFile(ENV['TODOTXT_CFG_FILE'].to_s)
      restoreFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      restoreFile(File.join(ENV['HOME'].to_s, "todo.cfg"))
   end



end

__END__
#!/bin/sh

test_description='basic addto and list functionality

This test just makes sure the basic addto and listfile
commands work, including support for filtering.
'
. ./test-lib.sh

touch "$HOME/garden.txt"

test_todo_session 'basic addto/listfile' <<EOF
>>> todo.sh addto garden.txt notice the daisies
1 notice the daisies
GARDEN: 1 added.

>>> todo.sh listfile garden.txt
1 notice the daisies
--
GARDEN: 1 of 1 tasks shown

>>> todo.sh addto garden.txt smell the roses
2 smell the roses
GARDEN: 2 added.

>>> todo.sh listfile garden.txt
1 notice the daisies
2 smell the roses
--
GARDEN: 2 of 2 tasks shown
EOF

#
# Filter
#
test_todo_session 'basic listfile filtering' <<EOF
>>> todo.sh listfile garden.txt daisies
1 notice the daisies
--
GARDEN: 1 of 2 tasks shown

>>> todo.sh listfile garden.txt smell  
2 smell the roses
--
GARDEN: 1 of 2 tasks shown
EOF

test_todo_session 'case-insensitive filtering' <<EOF
>>> todo.sh addto garden.txt smell the uppercase Roses
3 smell the uppercase Roses
GARDEN: 3 added.

>>> todo.sh listfile garden.txt roses
2 smell the roses
3 smell the uppercase Roses
--
GARDEN: 2 of 3 tasks shown
EOF

test_todo_session 'addto with &' <<EOF
>>> todo.sh addto garden.txt "dig the garden & water the flowers"
4 dig the garden & water the flowers
GARDEN: 4 added.

>>> todo.sh listfile garden.txt 
4 dig the garden & water the flowers
1 notice the daisies
2 smell the roses
3 smell the uppercase Roses
--
GARDEN: 4 of 4 tasks shown
EOF

test_done
