.PHONY: clean

.DEFAULT: packages

clean:
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

PACKAGES:=package-noble package-noble-usr-local package-jammy package-jammy-usr-local package-focal package-focal-usr-local
.PHONY: packages $(PACKAGES)

ARCH := amd64

ifeq ($(ARCH),)
PLATFORM :=
LIBARCH :=
else
PLATFORM := --platform $(ARCH)
LIBARCH := $(ARCH:arm64=arm64v8)/
endif

packages: $(PACKAGES)

define build-package
  LOGJAM_PREFIX=$(2) RUBYOPT='-W0' bundle exec fpm-fry cook $(PLATFORM) --pull --update=always $(LIBARCH)ubuntu:$(1)
  mkdir -p packages/ubuntu/$(1) && mv *.deb packages/ubuntu/$(1)
endef

package-noble:
	$(call build-package,noble,/opt/logjam)
package-jammy:
	$(call build-package,jammy,/opt/logjam)
package-focal:
	$(call build-package,focal,/opt/logjam)
package-noble-usr-local:
	$(call build-package,noble,/usr/local)
package-jammy-usr-local:
	$(call build-package,jammy,/usr/local)
package-focal-usr-local:
	$(call build-package,focal,/usr/local)

LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-noble publish-jammy publish-focal publish-noble-usr-local publish-jammy-usr-local publish-focal-usr-local
publish: publish-noble publish-jammy publish-focal publish-noble-usr-local publish-jammy-usr-local publish-focal-usr-local

VERSION:=$(shell cat VERSION)
PACKAGE_NAME:=logjam-ruby_$(VERSION)_$(ARCH).deb
PACKAGE_NAME_USR_LOCAL:=railsexpress-ruby_$(VERSION)_$(ARCH).deb

define upload-package
@if ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) debian-package-exists $(1) $(2); then\
  echo package $(1)/$(2) already exists on the server;\
else\
  tmpdir=`ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d` &&\
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/$(2) $(LOGJAM_PACKAGE_HOST):$$tmpdir &&\
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) add-new-debian-packages $(1) $$tmpdir;\
fi
endef

publish-noble:
	$(call upload-package,noble,$(PACKAGE_NAME))
publish-jammy:
	$(call upload-package,jammy,$(PACKAGE_NAME))
publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))
publish-noble-usr-local:
	$(call upload-package,noble,$(PACKAGE_NAME_USR_LOCAL))
publish-jammy-usr-local:
	$(call upload-package,jammy,$(PACKAGE_NAME_USR_LOCAL))
publish-focal-usr-local:
	$(call upload-package,focal,$(PACKAGE_NAME_USR_LOCAL))
