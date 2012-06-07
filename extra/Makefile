name = practical-instance-search

pack-data:
	tar -czvf $(name)-data-only.tar.gz \
	  --exclude '*/cache' \
	  --exclude '*/myOtherImages' \
	  --exclude '*DS_Store*' \
	  --exclude '.*' \
	  data
	cp $(name)-data-only.tar.gz ~/d/Dropbox/Public

pack-code:
	tar -C .. -czvf $(name)-code-only.tar.gz \
	  --exclude '*/.git' \
	  --exclude '*/data' \
	  --exclude '*/*.tar.gz' \
	  --exclude '*DS_Store*' \
	  --exclude '.*' \
	  $(name)
	cp $(name)-code-only.tar.gz ~/d/Dropbox/Public
