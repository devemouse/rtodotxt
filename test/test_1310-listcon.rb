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
      createTodoFile(@tmpdir, @todoFileName, [
                 'item 1',
                 'item 2',
                 'item 3',
      ])

       @rtodo = Rtodo.new({:dotfile => @dotFname})
      assert_equal([], @rtodo.lsc)
   end

   def test_weridcontext
      createTodoFile(@tmpdir, @todoFileName, [
         '(A) @1 -- Some context 1 task, whitespace, one char',
         '(A) @c2 -- Some context 2 task, whitespace, two char',
         '@con03 -- Some context 3 task, no whitespace',
         '@con04 -- Some context 4 task, no whitespace',
         '@con05@con06 -- weird context',
      ])

      @rtodo = Rtodo.new({:dotfile => @dotFname})

      contexts = [
            '@1',
            '@c2',
            '@con03',
            '@con04',
            '@con05@con06',
      ]

      assert_equal(contexts, @rtodo.lsc)
   end

   def test_multicontext
      createTodoFile(@tmpdir, @todoFileName, [
         '@con01 -- Some context 1 task',
         '@con02 -- Some context 2 task',
         '@con02 @con03 -- Multi-context task',
         '@con01 @con02 @con03 -- Multi-context task',
      ])

      @rtodo = Rtodo.new({:dotfile => @dotFname})

      contexts = [
         '@con01',
         '@con02',
         '@con03',
      ]

      assert_equal(contexts, @rtodo.lsc)
   end

   def test_mail
      createTodoFile(@tmpdir, @todoFileName, [
         '@con01 -- Some context 1 task',
         '@con02 -- Some context 2 task',
         '@con02 ginatrapani@gmail.com -- Some context 2 task',
         '@con03 ginatrapani@gmail.com -- Some context 2 task',
      ])

      @rtodo = Rtodo.new({:dotfile => @dotFname})

      contexts = [
         '@con01',
         '@con02',
         '@con03',
      ]

      assert_equal(contexts, @rtodo.lsc)
   end
end

