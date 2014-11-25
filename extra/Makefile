name = practical-instance-recognition-2014a
DST = vgg@login.robots.ox.ac.uk:WWW/share
DSTDOC = vgg@login.robots.ox.ac.uk:WWW/practicals/instance-recognition

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
doc/instructions.html

data=\
data/oxbuild_lite \
data/oxbuild_lite_imdb.mat \
data/oxbuild_lite_imdb_100k_ellipse_dog.mat \
data/oxbuild_lite_imdb_100k_disc_dog.mat \
data/paintings_imdb_100k_disc_dog.mat \
data/queries \
data/graf

code:=$(addprefix $(CURDIR)/,$(code))
data:=$(addprefix $(CURDIR)/,$(data))
deps:=$(shell find $(code) $(doc) $(data) -type f | sed "s/ /\\\\ /g")

pack: data/$(name).tar.gz
pack-data: data/$(name)-data-only.tar.gz
pack-code: data/$(name)-code-only.tar.gz

data/$(name).tar.gz: $(deps)
	rm -rf data/$(name)
	mkdir -p data/$(name)/{doc,data}
	ln -sf $(data) data/$(name)/data/
	ln -sf $(doc) data/$(name)/doc/
	ln -sf $(code) data/$(name)/
	tar -C data -czvhf data/$(name).tar.gz $(name)/

data/$(name)-data-only.tar.gz: $(deps)
	rm -rf data/$(name)
	mkdir -p data/$(name)/{doc,data}
	ln -sf $(data) data/$(name)/
	tar -C data -czvhf data/$(name)-data-only.tar.gz $(name)/

data/$(name)-code-only.tar.gz: $(deps)
	rm -rf data/$(name)
	mkdir -p data/$(name)/{doc,data}
	ln -sf $(doc) data/$(name)/doc/
	ln -sf $(code) data/$(name)/
	tar -C data -czvhf data/$(name)-code-only.tar.gz $(name)/

post-doc:
	rsync -rvt doc/images $(DSTDOC)/
	rsync -vt doc/instructions.html $(DSTDOC)/index.html

post: pack-all
	rsync -vt data/$(name).tar.gz $(DST)/
	rsync -vt data/$(name)-data-only.tar.gz $(DST)/
	rsync -vt data/$(name)-code-only.tar.gz $(DST)/

clean:
	find . -name '*~' -delete

distclean: clean
	rm -f data/$(name)*.tar.gz
