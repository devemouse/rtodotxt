#!/usr/bin/env ruby
require 'test/unit'
require '../RtodoCore'

class Test0000_Config < Test::Unit::TestCase

   def setup
      # backup ENV
      #@env_bkp = ENV['TODOTXT_CFG_FILE']
      #ENV['TODOTXT_CFG_FILE'] = '' unless (@env_bkp.nil? or @env_bkp == '')
      #
      self.hideFile(ENV['TODOTXT_CFG_FILE'].to_s)
      self.hideFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      self.hideFile(File.join(ENV['HOME'].to_s, "todo.cfg"))
   end

   def hideFile(filename)
      if File.exists?(filename)
         File.rename(filename, filename + ".bak")
      end
   end

   def restoreFile(filename)
      if File.exists?(filename + ".bak")
         File.rename(filename + ".bak", filename)
      end
   end

   def test_noConfig


      flunk("not implemented")
      # delete config files from all locations
      # run script
      # expect failure in constructor (exeption)
   end

   def test_sequenceConfig_Param
      flunk("not implemented")
      # delete config files from all locations
      # setup config files under locations:
      #    parameter
      #    ENV
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
   end

   def test_sequenceConfig_ENV
      flunk("not implemented")
      # delete config files from all locations
      # setup config files under locations:
      #    ENV
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
   end

   def test_sequenceConfig_Config
      flunk("not implemented")
      # delete config files from all locations
      # setup config files under locations:
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
   end

   def test_sequenceConfig_TodoCfg
      flunk("not implemented")
      # delete config files from all locations
      # setup config files under locations:
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
   end

   def teardown
      # restore ENV
      #ENV['TODOTXT_CFG_FILE'] = @env_bkp unless (@env_bkp.nil? or @env_bkp == '')
      restoreFile(ENV['TODOTXT_CFG_FILE'].to_s)
      restoreFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      restoreFile(File.join(ENV['HOME'].to_s, "todo.cfg"))
   end

end

__END__



test_description='todo.sh configuration file location

This test just makes sure that todo.sh can find its
config files in the default locations and take arguments
to find it somewhere else.
'
. ./test-lib.sh

# Remove the pre-created todo.cfg to test behavior in its absence
rm -f todo.cfg
echo "Fatal Error: Cannot read configuration file $HOME/.todo/config" > expect
test_expect_success 'no config file' '
    todo.sh > output 2>&1 || test_cmp expect output
'

# All the below tests will output the usage message.
cat > expect << EOF
Usage: todo.sh [-fhpantvV] [-d todo_config] action [task_number] [task_description]
Try 'todo.sh -h' for more information.
EOF

cat > test.cfg << EOF
export TODO_DIR=.
export TODO_FILE="\$TODO_DIR/todo.txt"
export DONE_FILE="\$TODO_DIR/done.txt"
export REPORT_FILE="\$TODO_DIR/report.txt"
export TMP_FILE="\$TODO_DIR/todo.tmp"
touch used_config
EOF

rm -f used_config
test_expect_success 'config file (default location 1)' '
    mkdir .todo
    cp test.cfg .todo/config
    todo.sh > output;
    test_cmp expect output && test -f used_config &&
        rm -rf .todo
'

rm -f used_config
test_expect_success 'config file (default location 2)' '
    cp test.cfg todo.cfg
    todo.sh > output;
    test_cmp expect output && test -f used_config &&
        rm -f todo.cfg
'

rm -f used_config
test_expect_success 'config file (default location 3)' '
    cp test.cfg .todo.cfg
    todo.sh > output;
    test_cmp expect output && test -f used_config &&
        rm -f .todo.cfg
'

rm -f used_config
test_expect_success 'config file (command line)' '
    todo.sh -d test.cfg > output;
    test_cmp expect output && test -f used_config
'

rm -f used_config
test_expect_success 'config file (env variable)' '
    TODOTXT_CFG_FILE=test.cfg todo.sh > output;
    test_cmp expect output && test -f used_config
'

test_done
