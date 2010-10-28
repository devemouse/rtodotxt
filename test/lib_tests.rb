
require 'fileutils'

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
