name = practical-instance-search
DST = vgg@login.robots.ox.ac.uk:WWW/share
%DST = ~/d/Dropbox/Public

pack-data:
	tar -czvf $(name)-data-only.tar.gz \
	  data/oxbuild_lite \
	  data/oxbuild_lite_imdb.mat \
	  data/oxbuild_lite_imdb_100k_ellipse_hessian.mat \
	  data/graf
	rsync -v $(name)-data-only.tar.gz $(DST)

pack-code:
	tar -C .. -czvf $(name)-code-only.tar.gz \
	  $$(git ls-tree -r HEAD --name-only | sed "s/^/$(name)\//") \
	  $(name)/vlfeat
	rsync -v $(name)-code-only.tar.gz $(DST)
