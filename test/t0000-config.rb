#!/usr/bin/env ruby
require 'test/unit'
require '../RtodoCore'
require 'fileutils'


class Test0000_Config < Test::Unit::TestCase

   def setup
      # backup ENV
      @env_bkp = ENV['TODOTXT_CFG_FILE']
      ENV['TODOTXT_CFG_FILE'] = '' unless (@env_bkp.nil? or @env_bkp == '')

      self.hideFile(ENV['TODOTXT_CFG_FILE'].to_s)
      self.hideFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      self.hideFile(File.join(ENV['HOME'].to_s, "todo.cfg"))

      @fname = "temp.cfg"
      unless File.exists?(@fname)
         open(@fname, 'a') { |f|
            f.puts "dummy"
         }
      end

      @verbose = false
   end

   def hideFile(filename)
      if File.exists?(filename)
         FileUtils.mv(filename, filename + ".bak", :verbose => @verbose)
      end
   end

   def restoreFile(filename)
      if File.exists?(filename + ".bak")
         FileUtils.mv(filename + ".bak", filename, :verbose => @verbose)
      end
   end

   def test_noConfig
      # Initialize with no config.
      assert_raise(IOError) { Rtodo.new() }

      # delete config files from all locations
      # run script
      # expect failure in constructor (exeption)
   end

   def test_sequenceConfig_Param
      # delete config files from all locations
      # setup config files under locations:
      #    parameter
      #    ENV
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
      #

      assert_nothing_raised(IOError) { Rtodo.new({:dotfile => @fname}) }
   end

   def test_sequenceConfig_ENV
      # delete config files from all locations
      # setup config files under locations:
      #    ENV
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
      ENV['TODOTXT_CFG_FILE'] = File.expand_path(@fname)

      assert_nothing_raised(IOError) { Rtodo.new() }
   end

   def test_sequenceConfig_Config
      # delete config files from all locations
      # setup config files under locations:
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used

      FileUtils.cp(File.expand_path(@fname), File.join(ENV['HOME'].to_s, ".todo" , "config"), :verbose => @verbose)

      assert_nothing_raised(IOError) { Rtodo.new() }

      FileUtils.rm(File.join(ENV['HOME'].to_s, ".todo" , "config"), :verbose => @verbose)
   end

   def test_sequenceConfig_TodoCfg
      # delete config files from all locations
      # setup config files under locations:
      #    ~/.todo/config
      #    todo.cfg
      # expect 1st one used
      FileUtils.cp(File.expand_path(@fname), File.join(ENV['HOME'].to_s, "todo.cfg"), :verbose => @verbose)

      assert_nothing_raised(IOError) { Rtodo.new() }

      FileUtils.rm(File.join(ENV['HOME'].to_s, "todo.cfg"), :verbose => @verbose)
   end

   def teardown
      # restore ENV
      ENV['TODOTXT_CFG_FILE'] = @env_bkp unless (@env_bkp.nil? or @env_bkp == '')

      restoreFile(ENV['TODOTXT_CFG_FILE'].to_s)
      restoreFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      restoreFile(File.join(ENV['HOME'].to_s, "todo.cfg"))

      FileUtils.rm(File.expand_path(@fname), :verbose => @verbose)
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
