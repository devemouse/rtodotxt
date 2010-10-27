#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'
require 'pp'

class Test1010_date < Test::Unit::TestCase

   def setup
      @env_bkp = ENV['TODOTXT_CFG_FILE']
      ENV['TODOTXT_CFG_FILE'] = '' unless (@env_bkp.nil? or @env_bkp == '')

      self.hideFile(ENV['TODOTXT_CFG_FILE'].to_s)
      self.hideFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      self.hideFile(File.join(ENV['HOME'].to_s, "todo.cfg"))

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

      # restore ENV
      ENV['TODOTXT_CFG_FILE'] = @env_bkp unless (@env_bkp.nil? or @env_bkp == '')

      restoreFile(ENV['TODOTXT_CFG_FILE'].to_s)
      restoreFile(File.join(ENV['HOME'].to_s, ".todo" , "config"))
      restoreFile(File.join(ENV['HOME'].to_s, "todo.cfg"))
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
end

