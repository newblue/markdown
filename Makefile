include $(GOROOT)/src/Make.inc 

TARG=github.com/knieriem/markdown
GOFILES=\
	markdown.go\
	output.go\
	parser.leg.go\

package:

include $(GOROOT)/src/Make.pkg

all: cmd

#
# mdtest runs MarkdownTests-1.0.3 that come with original C sources
#
mdtest: package cmd orig-c-src
	make -C cmd test

cmd: package
	make -C cmd


CLEANFILES=\
	parser.leg.go\
	_obj\
	,,c\
	,,fmt\

distclean: clean clean-sub
	rm -rf orig-c-src

clean-sub:
	for dir in cmd peg peg/leg; do make -C $$dir clean; done


VCS = git
GITHUB = git://github.com
# also, if hggit extension is available:
# VCS = hg
VCS-PULLFLAGS = 


#
# LEG parser generator stuff
#
LEG = ./peg/leg/leg
%.leg.go: %.leg $(LEG)
	$(LEG) -switch $<

$(LEG):
	if(! test -d peg); then make peg; fi
	make -C peg all GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH)
	make -C peg/leg all GOOS=$(GOHOSTOS) GOARCH=$(GOHOSTARCH)

peg:
	$(VCS) clone $(GITHUB)/knieriem/peg

update-peg:
	cd peg && $(VCS) pull $(VCS-PULLFLAGS)
	cd peg/leg && make clean


#
# access to original C source files
#

orig-c-src:
	$(VCS) clone $(GITHUB)/jgm/peg-markdown.git $@



include misc/devel.mk

.PHONY: \
	cmd\
	distclean\
	mdtest\
