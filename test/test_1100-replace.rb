#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'

class Test1100_Replace < Test::Unit::TestCase

   def setup
   end

   def test_NOT_IMPLEMENTED
      #flunk("OOPS")
   end

   def teardown
   end

end

__END__
#!/bin/sh

test_description='basic replace functionality

Ensure we can replace items successfully.
'
. ./test-lib.sh

#
# Set up the basic todo.txt
#
todo.sh add notice the daisies > /dev/null

test_todo_session 'replace usage' <<EOF
>>> todo.sh replace adf asdfa
=== 1
usage: todo.sh replace ITEM# "UPDATED ITEM"
EOF

test_todo_session 'basic replace' <<EOF
>>> todo.sh replace 1 "smell the cows"
1 notice the daisies
TODO: Replaced task with:
1 smell the cows

>>> todo.sh list
1 smell the cows
--
TODO: 1 of 1 tasks shown

>>> todo.sh replace 1 smell the roses
1 smell the cows
TODO: Replaced task with:
1 smell the roses

>>> todo.sh list
1 smell the roses
--
TODO: 1 of 1 tasks shown
EOF

cat > todo.txt <<EOF
smell the cows
grow some corn
thrash some hay
chase the chickens
EOF
test_todo_session 'replace in multi-item file' <<EOF
>>> todo.sh replace 1 smell the cheese
1 smell the cows
TODO: Replaced task with:
1 smell the cheese

>>> todo.sh replace 3 jump on hay
3 thrash some hay
TODO: Replaced task with:
3 jump on hay

>>> todo.sh replace 4 collect the eggs
4 chase the chickens
TODO: Replaced task with:
4 collect the eggs
EOF

test_todo_session 'replace with priority' <<EOF
>>> todo.sh pri 4 a
4 (A) collect the eggs
TODO: 4 prioritized (A).

>>> todo.sh replace 4 "collect the bread"
4 (A) collect the eggs
TODO: Replaced task with:
4 (A) collect the bread

>>> todo.sh replace 4 collect the eggs
4 (A) collect the bread
TODO: Replaced task with:
4 (A) collect the eggs
EOF

test_todo_session 'replace with &' << EOF
>>> todo.sh replace 3 "thrash the hay & thresh the wheat"
3 jump on hay
TODO: Replaced task with:
3 thrash the hay & thresh the wheat
EOF

test_todo_session 'replace error' << EOF
>>> todo.sh replace 10 "hej!"
=== 1
TODO: No task 10.
EOF

cat /dev/null > todo.txt
test_todo_session 'replace handling prepended date on add' <<EOF
>>> todo.sh -t add "new task"
1 2009-02-13 new task
TODO: 1 added.

>>> todo.sh replace 1 this is just a new one
1 2009-02-13 new task
TODO: Replaced task with:
1 2009-02-13 this is just a new one

>>> todo.sh replace 1 2010-07-04 this also has a new date
1 2009-02-13 this is just a new one
TODO: Replaced task with:
1 2010-07-04 this also has a new date
EOF

cat /dev/null > todo.txt
test_todo_session 'replace handling priority and prepended date on add' <<EOF
>>> todo.sh -t add "new task"
1 2009-02-13 new task
TODO: 1 added.

>>> todo.sh pri 1 A
1 (A) 2009-02-13 new task
TODO: 1 prioritized (A).

>>> todo.sh replace 1 this is just a new one
1 (A) 2009-02-13 new task
TODO: Replaced task with:
1 (A) 2009-02-13 this is just a new one
EOF

test_todo_session 'replace with prepended date replaces existing date' <<EOF
>>> todo.sh replace 1 2010-07-04 this also has a new date
1 (A) 2009-02-13 this is just a new one
TODO: Replaced task with:
1 (A) 2010-07-04 this also has a new date
EOF

test_done
