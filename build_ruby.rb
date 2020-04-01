prefix = ENV['LOGJAM_PREFIX'] || "/opt/logjam"

if prefix == "/opt/logjam"
  name "logjam-ruby"
else
  name "railsexpress-ruby"
end

v, i = File.read(File.expand_path(__dir__)+"/VERSION").chomp.split('-')
version v
iteration i

vendor "skaes@railsexpress.de"

ruby_version = "2.7.1"
patchlevel = 83
source "https://railsexpress.de/downloads/ruby-#{ruby_version}-p#{patchlevel}.tar.gz",
       checksum: 'a999f4548ecaced87cefa233a56d20bfd00bc9b7edb299d8b30ae5711e56790f'

build_depends "autoconf"
build_depends "automake"
build_depends "bison"
build_depends "build-essential"
build_depends "curl"
build_depends "gawk"
build_depends "libffi-dev"
build_depends "libgdbm-dev"
if codename == "bionic"
  build_depends "libgdbm-compat-dev"
end
build_depends "libgmp-dev"
build_depends "libncurses5-dev"
if codename == "bionic"
  build_depends "libreadline-dev"
else
  build_depends "libreadline6-dev"
end
build_depends "libssl-dev"
build_depends "libtool"
build_depends "libyaml-dev"
build_depends "patch"
build_depends "pkg-config"
build_depends "ruby"
build_depends "zlib1g-dev"

depends "libc6"
depends "libffi6"
if codename == "bionic"
  depends "libgdbm5"
else
  depends "libgdbm3"
end
depends "libgmp10"
if codename == "bionic"
  depends "libreadline7"
else
  depends "libreadline6"
end
depends "libyaml-0-2"
depends "openssl"
depends "zlib1g"

add "gemrc", ".gemrc"

run "cd", "ruby-#{ruby_version}-p#{patchlevel}"
run "./configure", "--prefix=#{prefix}", "--with-opt-dir=#{prefix}",
     "--with-out-ext=tcl", "--with-out-ext=tk", "--disable-install-doc", "--enable-shared"
run "make", "-j4"
run "make", "install"
run "cd", ".."
run "mkdir", "-p", "#{prefix}/etc"
run "cp", ".gemrc", "#{prefix}/etc/gemrc"
# install 1.x version of bundler to allow older Gemfile.locks to work
run "#{prefix}/bin/gem", "install", "bundler", "-v", "1.17.3"
# run "/opt/logjam/bin/gem", "install", "bundler", "-v", "2.1.2"
# run "/opt/logjam/bin/gem", "update", "-q", "--system", "3.1.2"

plugin "exclude"
exclude "/root/**"
