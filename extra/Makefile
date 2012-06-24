name = practical-instance-search
DST = vgg@login.robots.ox.ac.uk:WWW/share
%DST = ~/d/Dropbox/Public

pack-all: pack pack-data pack-code

pack:
	tar -C .. -czvf $(name).tar.gz \
	  $(name)/data/oxbuild_lite \
	  $(name)/data/oxbuild_lite_imdb.mat \
	  $(name)/data/oxbuild_lite_imdb_100k_ellipse_hessian.mat \
	  $(name)/data/art_imdb_100k_disc_hessian.mat \
	  $(name)/data/queries \
	  $(name)/data/graf \
	  $$(git ls-tree -r HEAD --name-only | sed "s/^/$(name)\//") \
	  $(name)/vlfeat
	rsync -v $(name).tar.gz $(DST)

pack-data:
	tar -C .. -czvf $(name)-data-only.tar.gz \
	  $(name)/data/oxbuild_lite \
	  $(name)/data/oxbuild_lite_imdb.mat \
	  $(name)/data/oxbuild_lite_imdb_100k_ellipse_hessian.mat \
	  $(name)/data/art_imdb_100k_disc_hessian.mat \
	  $(name)/data/queries \
	  $(name)/data/graf
	rsync -v $(name)-data-only.tar.gz $(DST)

pack-code:
	tar -C .. -czvf $(name)-code-only.tar.gz \
	  $$(git ls-tree -r HEAD --name-only | sed "s/^/$(name)\//") \
	  $(name)/vlfeat
	rsync -v $(name)-code-only.tar.gz $(DST)
