#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'test/lib_tests.rb'

class Test1310_ListCon < Test::Unit::TestCase

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

      @tasks = [
                  '(A) @con01 +prj01 -- Some project 01 task, pri A', 
                  '(A) @con01 +prj02 -- Some project 02 task, pri A', 
                  '(A) @con02 +prj03 -- Some project 03 task, pri A', 
                  '(A) @con02 +prj04 -- Some project 04 task, pri A', 
                  '(B) @con01 +prj01 -- Some project 01 task, pri B', 
                  '(B) @con01 +prj02 -- Some project 02 task, pri B', 
                  '(B) @con02 +prj03 -- Some project 03 task, pri B', 
                  '(B) @con02 +prj04 -- Some project 04 task, pri B', 
                  '(C) @con01 +prj01 -- Some project 01 task, pri C', 
                  '(C) @con01 +prj02 -- Some project 02 task, pri C', 
                  '(C) @con02 +prj03 -- Some project 03 task, pri C', 
                  '(C) @con02 +prj04 -- Some project 04 task, pri C', 
                  '(D) @con01 +prj01 -- Some project 01 task, pri D', 
                  '(D) @con01 +prj02 -- Some project 02 task, pri D', 
                  '(D) @con02 +prj03 -- Some project 03 task, pri D', 
                  '(D) @con02 +prj04 -- Some project 04 task, pri D', 
                  '@con01 +prj01 -- Some project 01 task, no priority', 
                  '@con01 +prj02 -- Some project 02 task, no priority', 
                  '@con02 +prj03 -- Some project 03 task, no priorty', 
                  '@con02 +prj04 -- Some project 04 task, no priority', 
               ].sort

               #note diffrient sequence
      open(File.join(@tmpdir, @todoFileName), 'w') { |f|
         @tasks.each {|el| f.puts el}
      }


       @rtodo = Rtodo.new({:dotfile => @dotFname})
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

   def test_no_contexts
      flunk("not implemented")
   end


end

__END__
#!/bin/sh
#

test_description='listcon functionality

This test checks basic context listing functionality
'
. ./test-lib.sh

cat > todo.txt <<EOF
item 1
item 2
item 3
EOF
test_expect_success 'listcon no contexts' '
    todo.sh listcon > output && ! test -s output
'

cat > todo.txt <<EOF
(A) @1 -- Some context 1 task, whitespace, one char
(A) @c2 -- Some context 2 task, whitespace, two char
@con03 -- Some context 3 task, no whitespace
@con04 -- Some context 4 task, no whitespace
@con05@con06 -- weird context
EOF
test_todo_session 'Single context per line' <<EOF
>>> todo.sh listcon
@1
@c2
@con03
@con04
@con05@con06
EOF

cat > todo.txt <<EOF
@con01 -- Some context 1 task
@con02 -- Some context 2 task
@con02 @con03 -- Multi-context task
EOF
test_todo_session 'Multi-context per line' <<EOF
>>> todo.sh listcon
@con01
@con02
@con03
EOF

cat > todo.txt <<EOF
@con01 -- Some context 1 task
@con02 -- Some context 2 task
@con02 ginatrapani@gmail.com -- Some context 2 task
EOF
test_todo_session 'listcon e-mail address test' <<EOF
>>> todo.sh listcon
@con01
@con02
EOF

test_done
