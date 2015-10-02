Requirements
============

You need an installed version of oq-platform (http or https version)
You need to configure some environment variables (or add them to a config script)
Run "make help" to take more info.


To install production data
==========================

sudo make prod


To revert to development data
=============================

sudo make dev


Production data for apps "world" and "svir"
===========================================

Fixtures in the api/data folder:
world_prod.json.bz2: the complete set of GADM countries simplified with
                     "bend simplify" algorithm (1000m tolerance)
svir_prod.json.bz2: the complete country-level socioeconomic database

To install the data on the platform you must run:

```python manage.py loaddata world_prod.json.bz2 svir_prod.json.bz2   # development```

```sudo openquakeplatform manage.py loaddata world_prod.json.bz2 svir_prod.json.bz2   # production```
