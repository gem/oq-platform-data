#!/bin/bash
#set -x

if [ -f $HOME/.oq-platform-data.conf ]; then
    source $HOME/.oq-platform-data.conf
fi
#
#  GLOBAL VARS
GEM_USER="${GEM_USER:-gem-user}"
GEM_PASS="${GEM_PASS:-mypass}"
GEM_HOST="${GEM_HOST:-localhost}"
if [ "$GEM_PROTO" = "" ]; then
    GEM_PROTO="$(grep '^SITEURL' /etc/geonode/local_settings.py  | sed "s/^SITEURL *= *[\"']\([a-z]*\):.*/\1/g")"
fi
GEM_PROTO="${GEM_PROTO:-http}"
if [ "$GEM_PROTO" = "https" ]; then
    GEM_PORT="${GEM_PORT:-443}"
else
    GEM_PORT="${GEM_PORT:-80}"
fi

#
#  FUNCTIONS

usage() {
    local ret
    ret=$1
    cat <<EOF

USAGE:
    sudo $0 <prod|dev>

DESCRIPTION:
    update geodetic data to production version

ENVIRONMENT:
    GEM_USER - the name of the web-user that can perform rest api
    GEM_PASS - the password of the web-user that can perform rest api
    GEM_HOST - the public hostname where try to connect to the rest api
    GEM_PROTO (optional) - the protocol (http/https) to be used where try to connect to the rest api
    GEM_PORT (optional) - the port where try to connect to the rest api

FILES:
    \$HOME/.oq-platform-data.conf - if exists it is loaded at the beginning of the script
        you can use it to set GEM_* variables descripted in the environment above.

EOF
    exit $ret
}

gem_exit() {
    local ret 
    ret="$1"
    
    if [ $ret -ne 0 ]; then
        echo "something go wrong, you can find logs into ${GEM_TMPDIR} directory. Good luck."
    else
        rm -rf "${GEM_TMPDIR}"
    fi

    exit $ret
}

curl_proc () {
    local ret flog

    ret=$1
    flog="$2"

    if [ $ret -ne 0 ]; then
        return $ret
    fi

    grep -q '^< HTTP/1.1 2[0-9][0-9] ' "${flog}.log"
    return $ret
    }



#
#  MAIN
#

if [ "$GEM_TMPBASE" = "" -o ! -d "$GEM_TMPBASE" ]; then
    if [ -d /var/tmp ]; then
        GEM_TMPBASE=/var/tmp/
    else
        GEM_TMPBASE=/tmp/
    fi
fi
GEM_TMPDIR="${GEM_TMPBASE}oq-platform-data.$$/"
mkdir "$GEM_TMPDIR"
if [ $? -ne 0 ]; then
    echo "Temporary directory '$GEM_TMPDIR' creation failed"
    exit 1
fi

echo "GEM_USER [$GEM_USER]  GEM_PASS [<secret>]  GEM_HOST [$GEM_HOST]  GEM_PORT [$GEM_PORT]  GEM_PROTO [$GEM_PROTO]"
if [ "$1" = "prod" ]; then
    #
    # virtualenv initialization
    gemdir="$(pwd)"
    cd /var/lib/geonode
    source bin/activate
    cd src/GeoNodePy/geonode/

    #
    # geodetic update
    export DJANGO_SCHEMATA_DOMAIN=geodetic
    python manage.py reset --noinput geodetic
    python manage.py loaddata "${gemdir}/api/data/geodetic_prod.json"

elif [ "$1" = "dev" ]; then
    echo "TODO"
elif [ "$1" = "help" ]; then
    usage 0
fi

fname=reset.xml
curl -L -v -s -o "${GEM_TMPDIR}${fname}" -u $GEM_USER:$GEM_PASS  -XPOST "${GEM_PROTO}://$GEM_HOST:$GEM_PORT/geoserver/rest/reset" 2>"${GEM_TMPDIR}${fname}.log"
curl_proc $? "${GEM_TMPDIR}${fname}"

gem_exit 0
