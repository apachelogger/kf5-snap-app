SOURCES = [
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

task :generate do
  puts File.read('appname')
  ruby 'generate.rb'
end
task :generate => :'repo::setup'

task :snapcraft do
  # TODO: can be dropped with KF5.28 https://git.reviewboard.kde.org/r/129273/
  Dir.mkdir('/usr/include/KF5') unless Dir.exist?('/usr/include/KF5')
  # KDoctools is rubbish and lets meinproc resolve asset paths via QStandardPaths
  ENV['XDG_DATA_DIRS'] = "#{Dir.pwd}/stage/usr/local/share:#{Dir.pwd}/stage/usr/share:/usr/local/share:/usr/share"
  sh 'apt install -y snapcraft'
  sh 'snapcraft'
end
task :snapcraft => :'repo::setup'
