#
# Requires:
#	- go (golang.org) (required on host to build/run, required on target to run)
#		- To add Go support on the Pi, in Raspbian:
#			sudo apt-get install golang
#	- Mercurial (hg) required by "go get":
#		- http://mercurial.selenic.com/wiki/Download, for Mac:
#			sudo port install mercurial
#	- Rebuild in linux/arm support for cross-compiling to the Pi.  On the Mac, this works:
#		cd /usr/local/go/src
#		sudo GOOS=linux GOARCH=arm ./make.bash
#		
PI=pi@raspberrypi
RUNONPI=ssh $(SSHFLAGS) -q -t $(PI) "cd rsinstall;"

VERSION:=$(shell git describe --tags --dirty)
LP_DIR=build/lessons

TGT_VAR_DIR=/var/local/raspberrystem/ide/
TGT_LESSONS_DIR=$(TGT_VAR_DIR)/website/lessons
OUT=$(abspath out)

# Final targets
LP_TAR:=$(OUT)/lesson_plans-$(VERSION).tar.gz
IM_PDF:=$(OUT)/RaspberrySTEM_Instructor_Manual-$(VERSION).pdf
SP_PDF:=$(OUT)/RaspberrySTEM_Supplementary_Projects-$(VERSION).pdf
UG_PDF:=$(OUT)/RaspberrySTEM_User_Guide-$(VERSION).pdf

TARGETS=
TARGETS+=$(LP_TAR)
#TARGETS+=$(IM_PDF)
#TARGETS+=$(SP_PDF)
#TARGETS+=$(UG_PDF)

all: $(TARGETS)

targets:
	@echo $(TARGETS)

clean:
	rm -f $(TARGETS)

install:
	scp $(LP_TAR) $(PI):/tmp
	$(RUNONPI) "cd $(TGT_LESSONS_DIR) && sudo tar xvf /tmp/$(notdir $(LP_TAR))"

$(OUT):
	mkdir -p $@

.PHONY: $(LP_TAR)
$(LP_TAR): $(shell git ls-files im)| $(OUT)
	rm -rf $(LP_DIR)
	mkdir -p $(LP_DIR)
	cp "im/RaspberrySTEM Instructor Manual.html" $(LP_DIR)/index.html
	cp im/default.css $(LP_DIR)
	cp -r im/images $(LP_DIR)
	cd $(LP_DIR) && tar cvzf $@ *