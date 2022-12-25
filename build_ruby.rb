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

patchlevel = 0
source "https://railsexpress.de/downloads/ruby-#{version}-p#{patchlevel}.tar.gz",
       checksum: '3766d9c92306737b9dceff32d2e8ca7d66af122d3d6aa7ec2f95299496efc6db'

build_depends "autoconf"
build_depends "automake"
build_depends "bison"
build_depends "build-essential"
build_depends "curl"
build_depends "gawk"
build_depends "libffi-dev"
build_depends "libgdbm-dev"

build_depends "libgdbm-compat-dev"
build_depends "libgmp-dev"
build_depends "libncurses5-dev"
build_depends "libreadline-dev"
build_depends "libssl-dev"
build_depends "libtool"
build_depends "libyaml-dev"
build_depends "patch"
build_depends "pkg-config"
build_depends "ruby"
build_depends "zlib1g-dev"
build_depends "rustc"

depends "libc6"
if codename == "jammy"
  depends "libffi8"
elsif codename == "focal"
  depends "libffi7"
else
  depends "libffi6"
end
if codename == "focal" || codename == "jammy"
  depends "libgdbm6"
elsif codename == "bionic"
  depends "libgdbm5"
else
  depends "libgdbm3"
end
depends "libgmp10"
if codename == "focal" || codename == "jammy"
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

run "autoconf"
run "./configure", "--prefix=#{prefix}", "--with-opt-dir=#{prefix}",
     "--with-out-ext=tcl", "--with-out-ext=tk", "--disable-install-doc", "--enable-shared", "--enable-yjit"
run "make", "-j4"
run "make", "install"
run "mkdir", "-p", "#{prefix}/etc"
run "cp", ".gemrc", "#{prefix}/etc/gemrc"
# run "#{prefix}/bin/gem", "update", "-q", "--system", "3.3.26"

plugin "exclude"

# The rubygems update installs gem info in '/root/.local'. Excluding
# '/root/**' is not enough, as it does not match '/root'.
exclude "/root"
exclude "/root/**"

# Github actions install ruby in /opt/hostedtoolcache and for some
# reason it gets modified.
exclude "/opt/hostedtoolcache"
exclude "/opt/hostedtoolcache/**"

# When running in a tty, tzdata asks for the time zone and the next
# line fixes that problem.
plugin "env", "DEBIAN_FRONTEND" => "noninteractive"
