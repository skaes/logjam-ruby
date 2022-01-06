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

ruby_version = "3.1.0"
patchlevel = 0
source "https://railsexpress.de/downloads/ruby-#{ruby_version}-p#{patchlevel}.tar.gz",
       checksum: 'a115eaba80356398f64d471057876e9d0a8f3142c78a99fa56ed0529bc41732b'

build_depends "autoconf"
build_depends "automake"
build_depends "bison"
build_depends "build-essential"
build_depends "curl"
build_depends "gawk"
build_depends "libffi-dev"
build_depends "libgdbm-dev"

if codename == "bionic" || codename == "focal"
  build_depends "libgdbm-compat-dev"
end
build_depends "libgmp-dev"
build_depends "libncurses5-dev"
if codename == "bionic" || codename == "focal"
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
if codename == "focal"
  depends "libffi7"
else
  depends "libffi6"
end
if codename == "focal"
  depends "libgdbm6"
elsif codename == "bionic"
  depends "libgdbm5"
else
  depends "libgdbm3"
end
depends "libgmp10"
if codename == "focal"
  depends "libreadline8"
elsif codename == "bionic"
  depends "libreadline7"
else
  depends "libreadline6"
end
depends "libyaml-0-2"
depends "openssl"
depends "zlib1g"

add "gemrc", ".gemrc"

run "cd", "ruby-#{ruby_version}-p#{patchlevel}"
run "autoconf"
run "./configure", "--prefix=#{prefix}", "--with-opt-dir=#{prefix}",
     "--with-out-ext=tcl", "--with-out-ext=tk", "--disable-install-doc", "--enable-shared"
run "make", "-j4"
run "make", "install"
run "cd", ".."
run "mkdir", "-p", "#{prefix}/etc"
run "cp", ".gemrc", "#{prefix}/etc/gemrc"
run "#{prefix}/bin/gem", "update", "-q", "--system", "3.3.4"

plugin "exclude"
exclude "/root/**"
