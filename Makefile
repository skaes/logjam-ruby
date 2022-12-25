.PHONY: clean

.DEFAULT: packages

clean:
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

PACKAGES:=package-jammy package-jammy-usr-local package-focal package-focal-usr-local package-bionic package-bionic-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

define build-package
  LOGJAM_PREFIX=$(2) RUBYOPT='-W0' bundle exec fpm-fry cook --update=always ubuntu:$(1) build_ruby.rb
  mkdir -p packages/ubuntu/$(1) && mv *.deb packages/ubuntu/$(1)
endef

package-jammy:
	$(call build-package,jammy,/opt/logjam)
package-focal:
	$(call build-package,focal,/opt/logjam)
package-bionic:
	$(call build-package,bionic,/opt/logjam)
package-jammy-usr-local:
	$(call build-package,jammy,/usr/local)
package-focal-usr-local:
	$(call build-package,focal,/usr/local)
package-bionic-usr-local:
	$(call build-package,bionic,/usr/local)

LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-jammy publish-focal publish-bionic  publish-jammy-usr-local publish-focal-usr-local publish-bionic-usr-local
publish: publish-jammy publish-focal publish-bionic publish-jammy-usr-local publish-focal-usr-local publish-bionic-usr-local

VERSION:=$(shell cat VERSION)
PACKAGE_NAME:=logjam-ruby_$(VERSION)_amd64.deb
PACKAGE_NAME_USR_LOCAL:=railsexpress-ruby_$(VERSION)_amd64.deb

define upload-package
@if ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) debian-package-exists $(1) $(2); then\
  echo package $(1)/$(2) already exists on the server;\
else\
  tmpdir=`ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d` &&\
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/* $(LOGJAM_PACKAGE_HOST):$$tmpdir &&\
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) add-new-debian-packages $(1) $$tmpdir;\
fi
endef

publish-jammy:
	$(call upload-package,jammy,$(PACKAGE_NAME))

publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))

publish-bionic:
	$(call upload-package,bionic,$(PACKAGE_NAME))

publish-jammy-usr-local:
	$(call upload-package,jammy,$(PACKAGE_NAME_USR_LOCAL))

publish-focal-usr-local:
	$(call upload-package,focal,$(PACKAGE_NAME_USR_LOCAL))

publish-bionic-usr-local:
	$(call upload-package,bionic,$(PACKAGE_NAME_USR_LOCAL))
