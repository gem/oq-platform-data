CONTENT:

fearth_db.sql (Vers. 2.1.5) => md5sum 9ae1454c699e556e37582854ce185fcc

HOWTO BUILD:
as postgres user:

vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
createdb gaf
createuser -D -R -S -P oqplatform
psql -d gaf -f fearth_db_globals.sql
psql -d gaf -f fearth_db.sql
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
