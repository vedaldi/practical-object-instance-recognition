name = practical-instance-recognition-2016a
DST = vgg@login.robots.ox.ac.uk:WWW/share
DSTDOC = vgg@login.robots.ox.ac.uk:WWW/practicals/instance-recognition
TMPDIR = /tmp

.PHONY: prepack, pack, pack-data, pack-code, post, clean, distclean

pack-all: pack-data pack-code pack

code=\
exercise1.m \
exercise2.m \
exercise3.m \
exercise4.m \
findNeighbours.m \
geometricVerification.m \
getFeatures.m \
getHistogramFromImage.m \
getHistogram.m \
loadIndex.m \
matchWords.m \
plotMatches.m \
plotQueryImage.m \
plotRetrievedImages.m \
search.m \
setup.m \
README.md \
vlfeat

doc=\
doc/images \
doc/base.css \
doc/instructions.html

data=\
data/oxbuild_lite \
data/oxbuild_lite_imdb.mat \
data/oxbuild_lite_imdb_100k_ellipse_dog.mat \
data/oxbuild_lite_imdb_100k_disc_dog.mat \
data/paintings_imdb_100k_disc_dog.mat \
data/queries \
data/graf

tarflags=--exclude='.git*'

code:=$(addprefix $(CURDIR)/,$(code))
data:=$(addprefix $(CURDIR)/,$(data))
doc:=$(addprefix $(CURDIR)/,$(doc))
deps:=$(shell find $(code) $(doc) $(data) -type f | sed "s/ /\\\\ /g")

.PHONY: doc
doc: doc/instructions.html

pack: $(TMPDIR)/$(name).tar.gz
pack-data: $(TMPDIR)/$(name)-data-only.tar.gz
pack-code: $(TMPDIR)/$(name)-code-only.tar.gz

$(TMPDIR)/$(name).tar.gz: $(deps)
	rm -rf $(TMPDIR)/$(name)
	mkdir -p $(TMPDIR)/$(name)/{doc,data}
	ln -sf $(data) $(TMPDIR)/$(name)/data/
	ln -sf $(doc) $(TMPDIR)/$(name)/doc/
	ln -sf $(code) $(TMPDIR)/$(name)/
	tar -C $(TMPDIR) -czvhf $(TMPDIR)/$(name).tar.gz $(tarflags) $(name)/

$(TMPDIR)/$(name)-data-only.tar.gz: $(deps)
	rm -rf $(TMPDIR)/$(name)
	mkdir -p $(TMPDIR)/$(name)/{doc,data}
	ln -sf $(data) $(TMPDIR)/$(name)/
	tar -C $(TMPDIR) -czvhf $(TMPDIR)/$(name)-data-only.tar.gz $(tarflags) $(name)/

$(TMPDIR)/$(name)-code-only.tar.gz: $(deps)
	rm -rf $(TMPDIR)/$(name)
	mkdir -p $(TMPDIR)/$(name)/{doc,data}
	ln -sf $(doc) $(TMPDIR)/$(name)/doc/
	ln -sf $(code) $(TMPDIR)/$(name)/
	tar -C $(TMPDIR) -czvhf $(TMPDIR)/$(name)-code-only.tar.gz $(tarflags) $(name)/

doc/instructions.html : doc/instructions.md doc/base.html extra/Makefile
	cp doc/base.html "$@"
	python -m markdown \
	  -x toc -x footnotes -x tables -x fenced_code \
	  "$<" >> "$@"
	cat doc/end.html >> "$@"

post-doc: doc/instructions.html
	rsync -rvt doc/base.css doc/images $(DSTDOC)/
	rsync -vt doc/instructions.html $(DSTDOC)/index.html

post: pack-all
	rsync -vt $(TMPDIR)/$(name).tar.gz $(DST)/
	rsync -vt $(TMPDIR)/$(name)-data-only.tar.gz $(DST)/
	rsync -vt $(TMPDIR)/$(name)-code-only.tar.gz $(DST)/

clean:
	find . -name '*~' -delete

distclean: clean
	rm -f $(TMPDIR)/$(name)*.tar.gz
