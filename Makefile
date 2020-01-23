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

define tmpdir
$(shell ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d)
endef

define upload-package
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/* $(LOGJAM_PACKAGE_HOST):$(2)
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) /usr/local/bin/add-new-debian-packages $(1) $(2)
endef

publish-bionic:
	$(call upload-package,bionic,$(call tmpdir))

publish-xenial:
	$(call upload-package,xenial,$(call tmpdir))
