#!/bin/bash
set -x

if [ -f $HOME/.oq-platform-data.conf ]; then
    source $HOME/.oq-platform-data.conf
fi
#
#  GLOBAL VARS
GEM_USER="${GEM_USER:=gem-user}"
GEM_PASS="${GEM_PASS:=mypass}"
GEM_HOST="${GEM_HOST:=localhost}"
GEM_PORT="${GEM_PORT:=8080}"
GEM_PROTO="http://"

ORIG_PATH="geoserver/data/Geotiffs/"
DEST_PATH="/var/lib/tomcat6/webapps/geoserver/data/data/Geotiffs/"

#
#  FUNCTIONS
gem_exit() {
    local ret 
    ret="$1"
    
    if [ $ret -ne 0 ]; then
        echo "something go wrong, you can find logs into ${GEM_TMPDIR} directory. Good luck."
    else
        echo fake rm -rf "${GEM_TMPDIR}"        
    fi

    exit $ret
}

tiffs_update () {
    local ltiffname ltiffcstore ltiffcover
    local gem_filepath

    declare -a ltiffname ltiffcstore ltiffcover

    ltiffname=("${!1}")
    ltiffcstore=("${!2}")
    ltiffcover=("${!3}")

    for i in $(seq 0  $(( ${#ltiffname[*]} - 1)) ); do
        if [ "${ltiffcstore[$i]}" = "" ]; then
            continue
        fi

        gem_filepath="${DEST_PATH}${ltiffname[$i]}"
        fname=my_geotiff_put${i}.xml
        curl -v -s -o "${GEM_TMPDIR}${fname}"  -u $GEM_USER:$GEM_PASS --data-ascii "file:$gem_filepath" -XPUT "http://$GEM_HOST:$GEM_PORT/geoserver/rest/workspaces/ged/coveragestores/${ltiffcstore[$i]}/external.geotiff?coverageName=${ltiffcover[$i]}"
        ret=$?
        if [ $ret -ne 0 ]; then
            return $ret
        fi
    done
    fname=reset.xml
    curl -v -s -o "${GEM_TMPDIR}${fname}" -u $GEM_USER:$GEM_PASS  -XPOST http://$GEM_HOST:$GEM_PORT/geoserver/rest/reset
        
}


#
#  MAIN
#
declare -a tiffcover
declare -a tiffname
declare -a tiffcstore

tiffcover[0]="pop_vals_aus_rural"  ; tiffcstore[0]="aus_pop_rural"
tiffcover[1]="pop_vals_aus_urban"  ; tiffcstore[1]="aus_pop_urban"
tiffcover[2]="pop_vals_che_rural"  ; tiffcstore[2]=""
tiffcover[3]="pop_vals_che_urban"  ; tiffcstore[3]=""
tiffcover[4]="pop_vals_chn_rural"  ; tiffcstore[4]="chn_rural"
tiffcover[5]="pop_vals_chn_urban"  ; tiffcstore[5]="chn_urban"
tiffcover[6]="pop_vals_gbr_rural"  ; tiffcstore[6]="gbr_rural"
tiffcover[7]="pop_vals_gbr_urban"  ; tiffcstore[7]="gbr_urban"
tiffcover[8]="pop_vals_ind_rural"  ; tiffcstore[8]="ind_rural"
tiffcover[9]="pop_vals_ind_urban"  ; tiffcstore[9]="ind_urban"
tiffcover[10]="pop_vals_ita_rural" ; tiffcstore[10]="ita_pop_rural"
tiffcover[11]="pop_vals_ita_urban" ; tiffcstore[11]="ita_pop_urban"
tiffcover[12]="pop_vals_jpn_rural" ; tiffcstore[12]="jpn_pop_rural"
tiffcover[13]="pop_vals_jpn_urban" ; tiffcstore[13]="jpn_pop_urban"
tiffcover[14]="pop_vals_lux_rural" ; tiffcstore[14]="lux_pop_rural"
tiffcover[15]="pop_vals_lux_urban" ; tiffcstore[15]="lux_pop_urban"
tiffcover[16]="pop_vals_mac_rural" ; tiffcstore[16]="mac_pop_rural"
tiffcover[17]="pop_vals_mac_urban" ; tiffcstore[17]="mac_pop_urban"
tiffcover[18]="pop_vals_reu_rural" ; tiffcstore[18]="reu_rural"
tiffcover[19]="pop_vals_reu_urban" ; tiffcstore[19]="reu_urban"

if [ "$GEM_TMPBASE" = "" -o ! -d "$GEM_TMPBASE" ]; then
    if [ -d /var/tmp ]; then
        GEM_TMPBASE=/var/tmp/
    else
        GEM_TMPBASE=/tmp/
    fi
fi
GEM_TMPDIR="${GEM_TMPBASE}oq-platform-data.$$"
mkdir "$GEM_TMPDIR"
if [ $? -ne 0 ]; then
    echo "Temporary directory '$GEM_TMPDIR' creation failed"
    exit 1
fi

echo "GEM_USER [$GEM_USER]  GEM_PASS [<secret>]  GEM_HOST [$GEM_HOST]  GEM_PORT [$GEM_PORT]  GEM_PROTO [$GEM_PROTO]"

if [ "$1" = "prod" ]; then
    for i in $(seq 0  $(( ${#tiffcover[*]} - 1)) ); do
        tiffname[$i]="${tiffcover[$i]}.tif"
        # echo "$i) ${tiffcover[$i]} | ${tiffname[$i]}"
        cp "${ORIG_PATH}${tiffname[$i]}" "${DEST_PATH}"
    done
elif [ "$1" = "dev" ]; then
    for i in $(seq 0 2 18); do
        tiffname[$i]="pop_vals_rural_dev.tif"
        tiffname[$((i + 1))]="pop_vals_urban_dev.tif"
    done
fi

tiffs_update tiffname[@] tiffcstore[@] tiffcover[@]
ret=$?

gem_exit $ret
