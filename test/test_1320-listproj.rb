#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'test/lib_tests.rb'

class Test1320_listProj < Test::Unit::TestCase

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

   def test_no_projects
      createTodoFile(@tmpdir, @todoFileName, [
                 'item 1',
                 'item 2',
                 'item 3',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})
       assert_equal([], rtodo.lsp)
   end

   def test_no_projects
      createTodoFile(@tmpdir, @todoFileName, [
         '(A) +1 -- Some project 1 task, whitespace, one char',
         '(A) +p2 -- Some project 2 task, whitespace, two char',
         '+prj03 -- Some project 3 task, no whitespace',
         '+prj04 -- Some project 4 task, no whitespace',
         '+prj05+prj06 -- weird project',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       projetcts = [
            '+1',
            '+p2',
            '+prj03',
            '+prj04',
            '+prj05+prj06',
       ]
       assert_equal([], rtodo.lsp)
   end

end

__END__
#!/bin/sh
#

test_description='listproj functionality

This test checks basic project listing functionality
'
. ./test-lib.sh

cat > todo.txt <<EOF
(A) +1 -- Some project 1 task, whitespace, one char
(A) +p2 -- Some project 2 task, whitespace, two char
+prj03 -- Some project 3 task, no whitespace
+prj04 -- Some project 4 task, no whitespace
+prj05+prj06 -- weird project
EOF
test_todo_session 'Single project per line' <<EOF
>>> todo.sh listproj
+1
+p2
+prj03
+prj04
+prj05+prj06
EOF

cat > todo.txt <<EOF
+prj01 -- Some project 1 task
+prj02 -- Some project 2 task
+prj02 +prj03 -- Multi-project task
EOF
test_todo_session 'Multi-project per line' <<EOF
>>> todo.sh listproj
+prj01
+prj02
+prj03
EOF

cat > todo.txt <<EOF
+prj01 -- Some project 1 task
+prj02 -- Some project 2 task
+prj02 ginatrapani+todo@gmail.com -- Some project 2 task
EOF
test_todo_session 'listproj embedded + test' <<EOF
>>> todo.sh listproj
+prj01
+prj02
EOF

test_done
