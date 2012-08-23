ALL: help

prod:
	./bin/api-admin.sh $@
	./bin/geoserver-admin.sh $@

dev:
	./bin/api-admin.sh $@
	./bin/geoserver-admin.sh $@

help:
	@echo
	@echo "make prod - install production data"
	@echo "make dev  - revert to development data"
	@echo "make help - this help"
	@echo

.PHONY: ALL prod dev help