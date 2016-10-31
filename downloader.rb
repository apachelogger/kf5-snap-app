require 'fileutils'

module APT
  class Downloader
    def initialize(path)
      @_path = path
    end

    def path
      FileUtils.mkpath("#{@_path}/partial")
      @_path
    end

    def get(pkg)
      system('apt-get',
             '-o', "dir::cache::archives=#{path}",
             '-o', 'Debug::NoLocking=true',
             '--reinstall', '-d', 'install', pkg)
      files = Dir.glob("#{path}/#{pkg}_*.deb")
      raise "Couldnt resolve local name #{files}" unless files.size == 1
      files[0]
    end
  end
end

class Deb
  def initialize(path)
    @path = path
  end

  def cfield(fields)
    ret = `dpkg-deb -f #{@path} #{fields}`.strip
    $?.success? ? ret : raise
  end

  def upstream_version
    version = cfield('Version')
    version = version.split('-')[0..-2].join('-') # drop last part (revision)
    version.split(':')[-1] # drop potential epoch
  end

  def extract(target = Dir.pwd)
    system('dpkg-deb', '-x', @path, target)
  end
end

# sudo apt-get -o dir::cache::archives="/path/to/folder/" -d install package
