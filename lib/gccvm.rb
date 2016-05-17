def ignore_exception
   begin
	   yield  
	   rescue Exception
   end
end

class GCCVM
	BINDIR = "/usr/local/bin/"

	def self.main
		puts "GCC Version Manager 0.0.3"
		puts "(C) 2016 James Landrum"
		puts ""
		puts "Commands:"
		puts "--list-versions : Lists the available versions of GCC."
		puts "--use-version {v} : Sets the GCC version to use."
		puts "--reset : Reverts back to system GCC."
	end

	def self.error(msg)
		puts msg
		puts ''
		puts self.main
	end

	def self.configure(path)
		self.reset_links
		self.set(path)		
		puts "Process completed. Restart your shell."
	end

	def self.set(path)
		puts "Creating links..."
		File.symlink(Dir[path+'/bin/c++*'][0],self::BINDIR+"c++")
		File.symlink(Dir[path+'/bin/g++*'][0],self::BINDIR+"g++")
		File.symlink(Dir[path+'/bin/gcc*'][0],self::BINDIR+"gcc")
		File.symlink(Dir[path+'/bin/cpp*'][0],self::BINDIR+"cpp")
		File.symlink(Dir[path+'/bin/gcc*'][0],self::BINDIR+"cc")
		puts "All links created."
	end

	def self.reset
		self.reset_links
	end

	def self.reset_links
		puts "Clearing existing links..."
		ignore_exception { File.unlink(self::BINDIR+"c++") }
		ignore_exception { File.unlink(self::BINDIR+"g++") }
		ignore_exception { File.unlink(self::BINDIR+"gcc") }
		ignore_exception { File.unlink(self::BINDIR+"cpp") } 
		ignore_exception { File.unlink(self::BINDIR+"cc") }
		puts "All linked cleared."
	end

	def self.list_versions
		puts("Available GCC Versions are:")
		Dir.glob("/usr/local/Cellar/gcc*").select {
			|f| File.directory? f
			Dir[f+"/*"].each { |d| puts " "+d.split("/").last }		
		}
		return nil
	end

	def self.exec
		if ARGV.count == 0 then
			puts GCCVM.main
			exit
		end

		case ARGV[0]
			when '--list-versions'
				GCCVM.list_versions		
			when '--reset'
				GCCVM.reset
			when '--use-version'
				if ARGV.count == 1
					puts GCCVM.error("Please specify a version");
					exit
				end
				ver = ARGV[1]
				path = nil
				Dir["/usr/local/Cellar/gcc*"].each { |d| 
					if File.exists?(d+"/"+ver) 
						path = d+"/"+ver
					end
				}
				if path != nil
					GCCVM.configure(path)
				else
					puts("gcc-"+ver+" is not installed.")
					GCCVM.list_versions
					exit
				end
			else 
				puts GCCVM.error("Unknown command: " + ARGV[0])
		end
	end
end

