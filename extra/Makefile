name = practical-instance-recognition-2013a
DST = vgg@login.robots.ox.ac.uk:WWW/share
%DST = ~/d/Dropbox/Public

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
README \
vlfeat

data=\
data/oxbuild_lite \
data/oxbuild_lite_imdb.mat \
data/oxbuild_lite_imdb_100k_ellipse_dog.mat \
data/art_imdb_100k_disc_dog.mat \
data/queries \
data/graf

code:=$(addprefix $(CURDIR)/,$(code))
data:=$(addprefix $(CURDIR)/,$(data))

pack:
	rm -rf data/$(name)
	mkdir -p data/$(name)/data
	ln -sft data/$(name)/data/ $(data)
	ln -sft data/$(name)/ $(code)
	tar -C data -czvhf data/$(name).tar.gz $(name)/

pack-data:
	rm -rf data/$(name)
	mkdir -p data/$(name)/data
	ln -sft data/$(name)/data/ $(data)
	tar -C data -czvhf data/$(name)-data-only.tar.gz $(name)/

pack-code:
	rm -rf data/$(name)
	mkdir -p data/$(name)/data
	ln -sft data/$(name)/ $(code)
	tar -C data -czvhf data/$(name)-code-only.tar.gz $(name)/

post: pack-all
	rsync -v data/$(name).tar.gz $(DST)/
	rsync -v data/$(name)-data-only.tar.gz $(DST)/
	rsync -v data/$(name)-code-only.tar.gz $(DST)/

clean:
	find -name '*~' -delete

distclean: clean
	rm -f data/$(name)*.tar.gz
