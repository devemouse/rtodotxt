#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'test/lib_tests.rb'

class Test1301_ls_big < Test::Unit::TestCase

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



   def test_ls_big
      _tasks = [
                 '01 (A) @con01 +prj01 -- Some project 01 task, pri A',
                 '02 (A) @con01 +prj02 -- Some project 02 task, pri A',
                 '03 (A) @con02 +prj03 -- Some project 03 task, pri A',
                 '04 (A) @con02 +prj04 -- Some project 04 task, pri A',
                 '05 (B) @con01 +prj01 -- Some project 01 task, pri B',
                 '06 (B) @con01 +prj02 -- Some project 02 task, pri B',
                 '07 (B) @con02 +prj03 -- Some project 03 task, pri B',
                 '08 (B) @con02 +prj04 -- Some project 04 task, pri B',
                 '09 (C) @con01 +prj01 -- Some project 01 task, pri C',
                 '10 (C) @con01 +prj02 -- Some project 02 task, pri C',
                 '11 (C) @con02 +prj03 -- Some project 03 task, pri C',
                 '12 (C) @con02 +prj04 -- Some project 04 task, pri C',
                 '13 (D) @con01 +prj01 -- Some project 01 task, pri D',
                 '14 (D) @con01 +prj02 -- Some project 02 task, pri D',
                 '15 (D) @con02 +prj03 -- Some project 03 task, pri D',
                 '16 (D) @con02 +prj04 -- Some project 04 task, pri D',
                 '17 @con01 +prj01 -- Some project 01 task, no priority',
                 '18 @con01 +prj02 -- Some project 02 task, no priority',
                 '19 @con02 +prj03 -- Some project 03 task, no priorty',
                 '20 @con02 +prj04 -- Some project 04 task, no priority',
               ]

      assert_equal(_tasks, @rtodo.ls)
   end

   def test_ls_filtered_big
      _tasks = [
                 '01 (A) @con01 +prj01 -- Some project 01 task, pri A',
                 '02 (A) @con01 +prj02 -- Some project 02 task, pri A',
                 '05 (B) @con01 +prj01 -- Some project 01 task, pri B',
                 '06 (B) @con01 +prj02 -- Some project 02 task, pri B',
                 '09 (C) @con01 +prj01 -- Some project 01 task, pri C',
                 '10 (C) @con01 +prj02 -- Some project 02 task, pri C',
                 '13 (D) @con01 +prj01 -- Some project 01 task, pri D',
                 '14 (D) @con01 +prj02 -- Some project 02 task, pri D',
                 '17 @con01 +prj01 -- Some project 01 task, no priority',
                 '18 @con01 +prj02 -- Some project 02 task, no priority',
               ]

      assert_equal(_tasks, @rtodo.ls('@con01'))
   end

   def test_ls_filtered_hide_priority_big
      _tasks = [
                 '01 @con01 +prj01 -- Some project 01 task, pri A',
                 '02 @con01 +prj02 -- Some project 02 task, pri A',
                 '05 @con01 +prj01 -- Some project 01 task, pri B',
                 '06 @con01 +prj02 -- Some project 02 task, pri B',
                 '09 @con01 +prj01 -- Some project 01 task, pri C',
                 '10 @con01 +prj02 -- Some project 02 task, pri C',
                 '13 @con01 +prj01 -- Some project 01 task, pri D',
                 '14 @con01 +prj02 -- Some project 02 task, pri D',
                 '17 @con01 +prj01 -- Some project 01 task, no priority',
                 '18 @con01 +prj02 -- Some project 02 task, no priority',
               ]

      assert_equal(_tasks, @rtodo.ls('@con01', :hide_priority => true))
   end

   def test_ls_filtered_hide_project_big
      _tasks = [
                 '01 (A) @con01 -- Some project 01 task, pri A',
                 '02 (A) @con01 -- Some project 02 task, pri A',
                 '05 (B) @con01 -- Some project 01 task, pri B',
                 '06 (B) @con01 -- Some project 02 task, pri B',
                 '09 (C) @con01 -- Some project 01 task, pri C',
                 '10 (C) @con01 -- Some project 02 task, pri C',
                 '13 (D) @con01 -- Some project 01 task, pri D',
                 '14 (D) @con01 -- Some project 02 task, pri D',
                 '17 @con01 -- Some project 01 task, no priority',
                 '18 @con01 -- Some project 02 task, no priority',
               ]

      assert_equal(_tasks, @rtodo.ls('@con01', :hide_project => true))
   end

   def test_ls_filtered_hide_context_big
      _tasks = [
                 '01 (A) +prj01 -- Some project 01 task, pri A',
                 '02 (A) +prj02 -- Some project 02 task, pri A',
                 '05 (B) +prj01 -- Some project 01 task, pri B',
                 '06 (B) +prj02 -- Some project 02 task, pri B',
                 '09 (C) +prj01 -- Some project 01 task, pri C',
                 '10 (C) +prj02 -- Some project 02 task, pri C',
                 '13 (D) +prj01 -- Some project 01 task, pri D',
                 '14 (D) +prj02 -- Some project 02 task, pri D',
                 '17 +prj01 -- Some project 01 task, no priority',
                 '18 +prj02 -- Some project 02 task, no priority',
               ]

               #puts "\n============== NOW =============="
      assert_equal(_tasks, @rtodo.ls('@con01', :hide_context => true))
               #puts "\n============== WON =============="
   end

   def test_ls_filtered_hide_priority_and_context_big
      _tasks = [
                 '01 +prj01 -- Some project 01 task, pri A',
                 '02 +prj02 -- Some project 02 task, pri A',
                 '05 +prj01 -- Some project 01 task, pri B',
                 '06 +prj02 -- Some project 02 task, pri B',
                 '09 +prj01 -- Some project 01 task, pri C',
                 '10 +prj02 -- Some project 02 task, pri C',
                 '13 +prj01 -- Some project 01 task, pri D',
                 '14 +prj02 -- Some project 02 task, pri D',
                 '17 +prj01 -- Some project 01 task, no priority',
                 '18 +prj02 -- Some project 02 task, no priority',
               ]

               #puts "\n============== NOW =============="
      assert_equal(_tasks, @rtodo.ls('@con01', :hide_priority => true, :hide_context => true))
               #puts "\n============== WON =============="
   end

   def test_ls_filtered_hide_priority_context_and_project_big
      _tasks = [
                 '01 -- Some project 01 task, pri A',
                 '02 -- Some project 02 task, pri A',
                 '05 -- Some project 01 task, pri B',
                 '06 -- Some project 02 task, pri B',
                 '09 -- Some project 01 task, pri C',
                 '10 -- Some project 02 task, pri C',
                 '13 -- Some project 01 task, pri D',
                 '14 -- Some project 02 task, pri D',
                 '17 -- Some project 01 task, no priority',
                 '18 -- Some project 02 task, no priority',
               ]

               #puts "\n============== NOW =============="
      assert_equal(_tasks, @rtodo.ls('@con01', :hide_project => true, :hide_priority => true, :hide_context => true))
               #puts "\n============== WON =============="
   end

end

__END__
#!/bin/sh
#

test_description='list functionality

This test checks various list functionality including
sorting, output filtering and line numbering.
'
. ./test-lib.sh

TEST_TODO_=todo.cfg

cat > todo.txt <<EOF
ccc xxx this line should be third.
aaa zzz this line should be first.
bbb yyy this line should be second.
EOF

#
# check the sort filter (DS: done but custom sort not avaliable)
#
TEST_TODO1_=todo1.cfg
sed -e "s/^.*export TODOTXT_SORT_COMMAND=.*$/export TODOTXT_SORT_COMMAND='env LC_COLLATE=C sort -r -f -k2'/" "${TEST_TODO_}" > "${TEST_TODO1_}"

test_todo_session 'checking TODOTXT_SORT_COMMAND' <<EOF
>>> todo.sh ls
2 aaa zzz this line should be first.
3 bbb yyy this line should be second.
1 ccc xxx this line should be third.
--
TODO: 3 of 3 tasks shown

>>> todo.sh -d "$TEST_TODO1_" ls
1 ccc xxx this line should be third.
3 bbb yyy this line should be second.
2 aaa zzz this line should be first.
--
TODO: 3 of 3 tasks shown
EOF

#
# check the final filter (DS: not implemented)
#
TEST_TODO2_=todo2.cfg
sed -e "s%^.*export TODOTXT_FINAL_FILTER=.*$%export TODOTXT_FINAL_FILTER=\"sed 's/^\\\(..\\\{20\\\}\\\).....*$/\\\1.../'\"%" "${TEST_TODO_}" > "${TEST_TODO2_}"

test_todo_session 'checking TODOTXT_FINAL_FILTER' <<EOF
>>> todo.sh -d "$TEST_TODO2_" ls
2 aaa zzz this line s...
3 bbb yyy this line s...
1 ccc xxx this line s...
--
TODO: 3 of 3 tasks shown
EOF

#
# check the x command line option
#
TEST_TODO3_=todo3.cfg
sed -e "s%^.*export TODOTXT_FINAL_FILTER=.*$%export TODOTXT_FINAL_FILTER=\"grep -v xxx\"%" "${TEST_TODO_}" > "${TEST_TODO3_}"

cat > todo.txt <<EOF
foo
bar xxx
baz
EOF

test_todo_session 'final filter suppression' <<EOF
>>> todo.sh -d "$TEST_TODO3_" ls
3 baz
1 foo
--
TODO: 2 of 3 tasks shown

>>> todo.sh -d "$TEST_TODO3_" -x ls
2 bar xxx
3 baz
1 foo
--
TODO: 3 of 3 tasks shown
EOF

#
# check the p command line option (DS: Rtodo:CLI class will be added for such output)
#
cat > todo.txt <<EOF
(A) @con01 +prj01 -- Some project 01 task, pri A
(A) @con01 +prj02 -- Some project 02 task, pri A
(A) @con02 +prj03 -- Some project 03 task, pri A
(A) @con02 +prj04 -- Some project 04 task, pri A
(B) @con01 +prj01 -- Some project 01 task, pri B
(B) @con01 +prj02 -- Some project 02 task, pri B
(B) @con02 +prj03 -- Some project 03 task, pri B
(B) @con02 +prj04 -- Some project 04 task, pri B
(C) @con01 +prj01 -- Some project 01 task, pri C
(C) @con01 +prj02 -- Some project 02 task, pri C
(C) @con02 +prj03 -- Some project 03 task, pri C
(C) @con02 +prj04 -- Some project 04 task, pri C
(D) @con01 +prj01 -- Some project 01 task, pri D
(D) @con01 +prj02 -- Some project 02 task, pri D
(D) @con02 +prj03 -- Some project 03 task, pri D
(D) @con02 +prj04 -- Some project 04 task, pri D
@con01 +prj01 -- Some project 01 task, no priority
@con01 +prj02 -- Some project 02 task, no priority
@con02 +prj03 -- Some project 03 task, no priorty
@con02 +prj04 -- Some project 04 task, no priority
EOF
test_todo_session 'plain mode option' <<EOF
>>> todo.sh ls
[1;33m01 (A) @con01 +prj01 -- Some project 01 task, pri A[0m
[1;33m02 (A) @con01 +prj02 -- Some project 02 task, pri A[0m
[1;33m03 (A) @con02 +prj03 -- Some project 03 task, pri A[0m
[1;33m04 (A) @con02 +prj04 -- Some project 04 task, pri A[0m
[0;32m05 (B) @con01 +prj01 -- Some project 01 task, pri B[0m
[0;32m06 (B) @con01 +prj02 -- Some project 02 task, pri B[0m
[0;32m07 (B) @con02 +prj03 -- Some project 03 task, pri B[0m
[0;32m08 (B) @con02 +prj04 -- Some project 04 task, pri B[0m
[1;34m09 (C) @con01 +prj01 -- Some project 01 task, pri C[0m
[1;34m10 (C) @con01 +prj02 -- Some project 02 task, pri C[0m
[1;34m11 (C) @con02 +prj03 -- Some project 03 task, pri C[0m
[1;34m12 (C) @con02 +prj04 -- Some project 04 task, pri C[0m
[1;37m13 (D) @con01 +prj01 -- Some project 01 task, pri D[0m
[1;37m14 (D) @con01 +prj02 -- Some project 02 task, pri D[0m
[1;37m15 (D) @con02 +prj03 -- Some project 03 task, pri D[0m
[1;37m16 (D) @con02 +prj04 -- Some project 04 task, pri D[0m
17 @con01 +prj01 -- Some project 01 task, no priority
18 @con01 +prj02 -- Some project 02 task, no priority
19 @con02 +prj03 -- Some project 03 task, no priorty
20 @con02 +prj04 -- Some project 04 task, no priority
--
TODO: 20 of 20 tasks shown

>>> todo.sh -p ls
01 (A) @con01 +prj01 -- Some project 01 task, pri A
02 (A) @con01 +prj02 -- Some project 02 task, pri A
03 (A) @con02 +prj03 -- Some project 03 task, pri A
04 (A) @con02 +prj04 -- Some project 04 task, pri A
05 (B) @con01 +prj01 -- Some project 01 task, pri B
06 (B) @con01 +prj02 -- Some project 02 task, pri B
07 (B) @con02 +prj03 -- Some project 03 task, pri B
08 (B) @con02 +prj04 -- Some project 04 task, pri B
09 (C) @con01 +prj01 -- Some project 01 task, pri C
10 (C) @con01 +prj02 -- Some project 02 task, pri C
11 (C) @con02 +prj03 -- Some project 03 task, pri C
12 (C) @con02 +prj04 -- Some project 04 task, pri C
13 (D) @con01 +prj01 -- Some project 01 task, pri D
14 (D) @con01 +prj02 -- Some project 02 task, pri D
15 (D) @con02 +prj03 -- Some project 03 task, pri D
16 (D) @con02 +prj04 -- Some project 04 task, pri D
17 @con01 +prj01 -- Some project 01 task, no priority
18 @con01 +prj02 -- Some project 02 task, no priority
19 @con02 +prj03 -- Some project 03 task, no priorty
20 @con02 +prj04 -- Some project 04 task, no priority
--
TODO: 20 of 20 tasks shown
EOF


#
# check that blank lines are ignored.
#

# Less than 10
cat > todo.txt <<EOF
hex00 this is one line

hex02 this is another line
hex03 this is another line
hex04 this is another line
hex05 this is another line
hex06 this is another line
hex07 this is another line
EOF
test_todo_session 'check that blank lines are ignored for less than 10 items' <<EOF
>>> todo.sh ls
1 hex00 this is one line
3 hex02 this is another line
4 hex03 this is another line
5 hex04 this is another line
6 hex05 this is another line
7 hex06 this is another line
8 hex07 this is another line
--
TODO: 7 of 7 tasks shown
EOF

# More than 10
cat > todo.txt <<EOF
hex00 this is one line

hex02 this is another line
hex03 this is another line
hex04 this is another line
hex05 this is another line
hex06 this is another line
hex07 this is another line
hex08 this is another line
hex09 this is another line
EOF
test_todo_session 'check that blank lines are ignored for blank lines whose ID begins with `0` (one blank)' <<EOF
>>> todo.sh ls
01 hex00 this is one line
03 hex02 this is another line
04 hex03 this is another line
05 hex04 this is another line
06 hex05 this is another line
07 hex06 this is another line
08 hex07 this is another line
09 hex08 this is another line
10 hex09 this is another line
--
TODO: 9 of 9 tasks shown
EOF
cat > todo.txt <<EOF
hex00 this is one line

hex02 this is another line
hex03 this is another line
hex04 this is another line
hex05 this is another line

hex07 this is another line
hex08 this is another line
hex09 this is another line
EOF
test_todo_session 'check that blank lines are ignored for blank lines whose ID begins with `0` (many blanks)' <<EOF
>>> todo.sh ls
01 hex00 this is one line
03 hex02 this is another line
04 hex03 this is another line
05 hex04 this is another line
06 hex05 this is another line
08 hex07 this is another line
09 hex08 this is another line
10 hex09 this is another line
--
TODO: 8 of 8 tasks shown
EOF

test_done
