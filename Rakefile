SOURCES = [
  'deb http://archive.neon.kde.org/user xenial main',
  'deb http://archive.neon.kde.org/release xenial main',
  'deb-src http://archive.neon.kde.org/release xenial main'
].freeze

task :'repo::setup' do
  File.open('/etc/apt/sources.list.d/neon.list', 'w') do |f|
    SOURCES.each { |line| f.puts(line) }
  end
  sh 'apt-key adv --keyserver keyserver.ubuntu.com --recv 55751E5D'
  sh 'apt update'
end

task :appstream do
  sh 'apt install -y appstream gir1.2-appstream-1.0 libappstream-dev libgirepository1.0-dev'
end
task :appstream => :'repo::setup'

task :generate do
  puts File.read('appname')
  sh 'apt update'
  sh 'apt dist-upgrade -y'
  sh 'apt install -y appstream devscripts ruby-dev'
  # Dependency of deb822 parser borrowed from pangea-tooling.
  sh 'gem install insensitive_hash'
  # So we can convert appstream html to markdown making it readable
  sh 'gem install reverse_markdown'
  sh 'gem install gir_ffi'
  ruby 'generate.rb'
end
task :generate => [:'repo::setup', :appstream]

task :snapcraft do
  # KDoctools is rubbish and lets meinproc resolve asset paths via QStandardPaths
  ENV['XDG_DATA_DIRS'] = "#{Dir.pwd}/stage/usr/local/share:#{Dir.pwd}/stage/usr/share:/usr/local/share:/usr/share"
  sh 'apt install -y snapcraft'
  sh 'snapcraft --debug'
end
task :snapcraft => :'repo::setup'

task :publish do
  # Compat, contain.rb currently has a bug overwriting the whitelist of vars.
  ENV['APPNAME'] = File.read('appname').strip
  require 'fileutils'
  sh 'apt update'
  sh 'apt install -y snapcraft'
  cfgdir = Dir.home + '/.config/snapcraft'
  FileUtils.mkpath(cfgdir)
  File.write("#{cfgdir}/snapcraft.cfg", File.read('snapcraft.cfg'))
  sh 'snapcraft push *.snap'
  rev_lines = `snapcraft revisions #{ENV['APPNAME']}`.strip.split($/)[1..-1]
  revs = rev_lines.collect { |l| Revision.new(l) }
  p rev = revs[0]
  if rev.channels != '-' # not published
    warn "#{ENV['APPNAME']} is already published in #{rev.channels}"
    return
  end
  sh "snapcraft release #{ENV['APPNAME']} #{rev} candidate,beta,edge"
end

class Revision
  attr_reader :number
  attr_reader :channels

  def initialize(line)
    @number, _date, _arch, _version, @channels = line.split(/\s+/, 5)
    @number = @number.to_i # convert from str to int
  end

  def to_s
    number.to_s
  end
end
