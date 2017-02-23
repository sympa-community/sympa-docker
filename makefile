URL_BASE=



service/rest/

service/rest/$(TARBALL):
	cd service/rest && wget $(URL_BASE)/$(TARBALL) && tar xzf $(TARBALL)
