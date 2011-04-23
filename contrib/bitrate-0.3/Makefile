# All files that should end up in the distribution archive.
DIST_FILES=Makefile bitrate.py COPYING README.txt bitrate-man.html default.css

VERSION=$(shell python -c "import bitrate; print bitrate.__version__")
DISTNAME=bitrate-$(VERSION)

all: doc

doc: bitrate-man.html

bitrate-man.html: README.txt
	rst2html.py README.txt > bitrate-man.html

epydoc: bitrate.py
	epydoc --name bitrate.py bitrate.py

dist: clean $(DIST_FILES)
	mkdir $(DISTNAME)
	cp -a $(DIST_FILES) $(DISTNAME)
	tar cvzf $(DISTNAME).tar.gz $(DISTNAME)
	rm -rf $(DISTNAME)

clean:
	rm -rf html *~ *.bck *.pyc *.html *.tar.gz
