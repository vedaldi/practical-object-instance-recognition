name = practical-instance-search

pack-data:
	tar -czvf $(name)-data-only.tar.gz \
	  --include 'data/oxbuild_images' \
	  --include 'data/oxbuild_imdb.mat' \
	  --include 'data/oxbuild_imdb_100k_ellipse_hessian.mat' \
          --include 'data/graf' \
	  --exclude 'data/*' \
	data
	cp $(name)-data-only.tar.gz ~/d/Dropbox/Public

pack-code:
	tar -C .. -czvf $(name)-code-only.tar.gz \
	  --exclude '*/.git' \
	  --exclude '*/data' \
	  --exclude '*/*.tar.gz' \
	  --exclude '*DS_Store*' \
	  --exclude '.*' \
	  --exclude '*/~' \
	  $(name)
	cp $(name)-code-only.tar.gz ~/d/Dropbox/Public
