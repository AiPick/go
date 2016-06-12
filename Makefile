GIT_REVISION ?= $(shell git log -n 1 | head -n 1 | sed -e 's/^commit //' | head -c 8)

# Source directory of Lantern.
LANTERN_SRC_DIR ?= $(GOPATH)/src/github.com/getlantern/lantern

# Where is this patch going to be written to.
PATCHFILE ?= $(LANTERN_SRC_DIR)/patches/lantern-go1.6.2.diff

# Original Go source.
GO_SOURCE ?= https://storage.googleapis.com/golang/go1.6.2.src.tar.gz

# How to name the generated Go version.
LANTERN_GO_VERSION ?= go1.6.2_lantern_$(GIT_REVISION)

WORK_DIR ?= $(PWD)/tmp/
LANTERN_GO_DIR ?= $(WORK_DIR)/lantern-go

.PHONY: go-source diff distclean go-source

diff: go-source
	mkdir -p $(LANTERN_GO_DIR) && \
	mkdir -p $$(dirname $(PATCHFILE)) && \
	rsync -av --delete --exclude tmp --exclude '*.diff' --exclude '*.swp' --exclude '.git*' . $(LANTERN_GO_DIR) && \
	$(MAKE) -C $(LANTERN_GO_DIR) distclean && \
	echo $(LANTERN_GO_VERSION) > $(WORK_DIR)/$$(basename $(LANTERN_GO_DIR))/VERSION && \
	(cd $(WORK_DIR) && diff -Naur go $$(basename $(LANTERN_GO_DIR)) > $(PATCHFILE) || exit 0)

distclean:
	rm Makefile

clean:
	rm -rf $(WORK_DIR)

go-source:
	if [ ! -d $(WORK_DIR)/go ]; then \
		mkdir -p $(WORK_DIR) && \
		curl --progress-bar $(GO_SOURCE) | tar -xzf - -C $(WORK_DIR); \
	fi
