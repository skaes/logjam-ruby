# logjam-ruby

Build ruby package for logjam pipeline. Supports Ubuntu Focal, Jammy
and Noble. Provides two different package flavors:
`logjam-ruby_x.x.x_x_amd64.deb` installs in `/opt/logjam` and
`railsexpress-ruby_x.x.x-x_amd64.deb` installs in `/usr/local`.

[![build](https://github.com/skaes/logjam-ruby/actions/workflows/build.yml/badge.svg)](https://github.com/skaes/logjam-ruby/actions/workflows/build.yml)


## Releasing a new version

Edit `build_ruby.rb` and change the version/iteration number. Then
push to Github. This will build 4 new packages.
