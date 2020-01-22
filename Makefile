.PHONY: clean

.DEFAULT: packages

clean:
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

PACKAGES:=package-bionic package-bionic-usr-local package-xenial package-xenial-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

package-bionic:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always ubuntu:bionic build_ruby.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always ubuntu:xenial build_ruby.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial
package-bionic-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always ubuntu:bionic build_ruby.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always ubuntu:xenial build_ruby.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial


LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-bionic publish-xenial
publish: publish-bionic publish-xenial

publish-bionic:
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/bionic/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/bionic/

publish-xenial:
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/xenial/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/xenial/
