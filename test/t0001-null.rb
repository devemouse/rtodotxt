#!/usr/bin/env ruby
require 'test/unit'
require '../RtodoCore'

class Test0001_null < Test::Unit::TestCase

   def setup
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

   ###############     ls      #################
   def test_nil_ls
      tasks = @rtodo.ls

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_list
      tasks = @rtodo.list

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_ls_filter
      tasks = @rtodo.ls('filter')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_list_filter
      tasks = @rtodo.list('filter')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end


   ###############     lsp     #################
   def test_nil_lsp
      tasks = @rtodo.lsp

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listpri
      tasks = @rtodo.listpri

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_lsp_filter
      tasks = @rtodo.lsp('A')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listpri_filter
      tasks = @rtodo.listpri('A')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   ###############     lsa     #################
   def test_nil_lsa
      tasks = @rtodo.lsa

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listall
      tasks = @rtodo.listall

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_lsa_filter
      tasks = @rtodo.lsa('filter')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listall_filter
      tasks = @rtodo.listall('filter')

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   ###############     lsc     #################
   def test_nil_lsc
      tasks = @rtodo.lsc

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listcon
      tasks = @rtodo.listcon

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   ###############     lsprj   #################
   def test_nil_lsprj
      tasks = @rtodo.lsprj

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listproj
      tasks = @rtodo.listproj

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   ###############     lf      #################
   def test_nil_lf
      tasks = @rtodo.lf

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listfile
      tasks = @rtodo.listfile

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listfile_filter
      #use some random file as a parameter
      tasks = @rtodo.listfile("filter")

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end

   def test_nil_listfile_file
      #use some random file as a parameter
      tasks = @rtodo.listfile("",  "FDSIUVSDRU.txt")

      assert_kind_of( Array, tasks)
      assert( tasks.empty? )

      assert( @rtodo.all_tasks.empty? )
   end


   def teardown
      FileUtils.remove_entry_secure @tmpdir
      FileUtils.remove_entry_secure @dotFname
   end

end
