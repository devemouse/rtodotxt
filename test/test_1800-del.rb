#!/usr/bin/env ruby
require 'test/unit'
require 'RtodoCore'

class Test1800_del < Test::Unit::TestCase

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

   def off_test_del_wrong_parameter
      # wrong parameter shall be filtered out by upper layer
      createTodoFile(@tmpdir, @todoFileName, [
                 'fadfa',
                 'fadfa',
                 'fadfa',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       assert_equal(false, rtodo.del('B'))
   end

   def test_nonexisting_item
      createTodoFile(@tmpdir, @todoFileName, [
                 'fadfa',
                 'fadfa',
                 'fadfa',
      ])

       rtodo = Rtodo.new({:dotfile => @dotFname})

       assert_equal(false, rtodo.del(42))
   end

   def test_normal_delete
      createTodoFile(@tmpdir, @todoFileName, [
                     '(B) smell the uppercase Roses +flowers @outside',
                     '(A) notice the sunflowers',
                     'stop',
      ])

      rtodo = Rtodo.new({:dotfile => @dotFname})

      tasks = [
         '2 (A) notice the sunflowers',
         '1 (B) smell the uppercase Roses +flowers @outside',
         '3 stop',
      ]

      assert_equal(tasks, rtodo.ls)

      del_tasks = '1 (B) smell the uppercase Roses +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:preserve_line_num => true}))

      tasks = [
         '2 (A) notice the sunflowers',
         '3 stop',
      ]

      assert_equal(tasks, rtodo.ls)
   end

   def test_preserve_lines
      createTodoFile(@tmpdir, @todoFileName, [
                     '(B) smell the uppercase Roses +flowers @outside',
                     '(A) notice the sunflowers',
                     'stop',
      ])

      rtodo = Rtodo.new({:dotfile => @dotFname})

      tasks = [
         '2 (A) notice the sunflowers',
         '1 (B) smell the uppercase Roses +flowers @outside',
         '3 stop',
      ]

      assert_equal(tasks, rtodo.ls)

      del_tasks = '1 (B) smell the uppercase Roses +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:preserve_line_num => true}))

      tasks = [
         '2 (A) notice the sunflowers',
         '3 stop',
      ]

      assert_equal(tasks, rtodo.ls)

      #at this point the 1 task does not exist anymore
      assert_equal(false, rtodo.del(1, {:preserve_line_num => true}))

      task = 'A new task'

      assert_equal('4 ' +task, rtodo.add(task))

      tasks = [
         '2 (A) notice the sunflowers',
         '4 A new task',
         '3 stop',
      ]
      assert_equal(tasks, rtodo.ls)

      del_tasks = '2 (A) notice the sunflowers'

      assert_equal(del_tasks, rtodo.del(2, {:preserve_line_num => false}))

      task = 'Another new task'

      assert_equal('3 ' +task, rtodo.add(task))

      tasks = [
         '2 A new task',
         '3 Another new task',
         '1 stop',
      ]

      assert_equal(tasks, rtodo.ls)
   end

   def test_normal_delete_term
      createTodoFile(@tmpdir, @todoFileName, [
                     '(B) smell the uppercase Roses +flowers @outside',
                     '(A) notice the sunflowers',
                     '(C) stop',
      ])

      rtodo = Rtodo.new({:dotfile => @dotFname})

      tasks = [
         '2 (A) notice the sunflowers',
         '1 (B) smell the uppercase Roses +flowers @outside',
         '3 (C) stop',
      ]

      assert_equal(tasks, rtodo.ls)

      del_tasks = '1 (B) smell the Roses +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:term => 'uppercase'}))

      tasks = [
         '2 (A) notice the sunflowers',
         '1 (B) smell the Roses +flowers @outside',
         '3 (C) stop',
      ]

      assert_equal(tasks, rtodo.ls)

      del_tasks = '1 (B) smell +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:term => 'the Roses'}))

      del_tasks = '1 (B) sell +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:term => 'm'}))

      del_tasks = '1 (B) sell +flowers'

      assert_equal(del_tasks, rtodo.del(1, {:term => '@outside'}))

      del_tasks = '1 (B) +flowers'

      assert_equal(del_tasks, rtodo.del(1, {:term => 'sell'}))
   end

   def test_delete_non_existing_term
      createTodoFile(@tmpdir, @todoFileName, [
                     '(B) smell the uppercase Roses +flowers @outside',
                     '(A) notice the sunflowers',
                     '(C) stop',
      ])

      rtodo = Rtodo.new({:dotfile => @dotFname})

      del_tasks = '1 (B) smell the uppercase Roses +flowers @outside'

      assert_equal(del_tasks, rtodo.del(1, {:term => 'dung'}))

      tasks = [
         '2 (A) notice the sunflowers',
         '1 (B) smell the uppercase Roses +flowers @outside',
         '3 (C) stop',
      ]

      assert_equal(tasks, rtodo.ls)
   end
end

