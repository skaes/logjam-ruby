# logjam-ruby

Build ruby package for logjam pipeline. Supports Ubuntu Bionic and Xenial and provides two
different packages: `logjam-ruby_x.x.x_x_amd64.deb` installs in `/opt/logjam` and
`railsexpress-ruby_x.x.x-x_amd64.deb` installs in `/usr/local`.

## Releasing a new version

Edit `build_ruby.rb` and change the version/iteration number. Then push to Github. This
will build 4 new packages.
