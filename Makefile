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
	@echo "Admin scripts usage below:"
	@echo
	./bin/api-admin.sh $@
	@echo
	./bin/geoserver-admin.sh $@

.PHONY: ALL prod dev help