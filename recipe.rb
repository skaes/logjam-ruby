prefix = ENV['LOGJAM_PREFIX'] || "/opt/logjam"

if prefix == "/opt/logjam"
  name "logjam-ruby"
else
  name "railsexpress-ruby"
end

version_info = YAML::load_file(File.expand_path(__dir__)+"/version.yml")
package, patchlevel, checksum, rubygems_version = version_info.values_at(*%w[package patchlevel checksum rubygems_version])

v, i = package.split('-')
version v
iteration i

vendor "skaes@railsexpress.de"

source "https://railsexpress.de/downloads/ruby-#{version}-p#{patchlevel}.tar.gz", checksum: checksum

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
if codename == "jammy" || codename == "noble"
  depends "libffi8"
elsif codename == "focal"
  depends "libffi7"
else
  depends "libffi6"
end

if codename == "noble"
  depends "libgdbm6t64"
elsif codename == "focal" || codename == "jammy"
  depends "libgdbm6"
else
  depends "libgdbm3"
end

depends "libgmp10"

if codename == "noble"
  depends "libreadline8t64"
elsif codename == "focal" || codename == "jammy" || codename == "noble"
  depends "libreadline8"
else
  depends "libreadline6"
end

depends "libyaml-0-2"

if codename == "noble"
  depends "libssl3t64"
elsif codename == "jammy"
  depends "libssl3"
else
  depends "libssl1.1"
end
depends "zlib1g"

add "gemrc", ".gemrc"

if codename == "jammy" || codename == "noble"
  run "autoreconf", "-i"
else
  run "autoconf"
end
run "./configure", "--prefix=#{prefix}", "--with-opt-dir=#{prefix}",
     "--with-out-ext=tcl", "--with-out-ext=tk", "--disable-install-doc", "--enable-shared", "--enable-yjit"
run "make", "-j4"
run "make", "install"
run "mkdir", "-p", "#{prefix}/etc"
run "cp", ".gemrc", "#{prefix}/etc/gemrc"
run "#{prefix}/bin/gem", "update", "-q", "--system", rubygems_version

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
