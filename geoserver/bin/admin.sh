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

















# GEM_FILEPATH=/home/nastasi/git/geonode/gs-data/data/mop.tif
GEM_FILEPATH=/var/lib/tomcat6/webapps/geoserver/data/data/Geotiffs/my_geotiff_light.tif
#

GEM_COVERSTORE=chn_urban
# GEM_COVERAGE="$(basename $GEM_FILEPATH .tif)"
GEM_COVERAGE=pop_vals_chn_urban
#  private vars
OUTDIR=output/
TB='	'
NL='
'



GEM_FILEPATH=/var/lib/tomcat6/webapps/geoserver/data/data/Geotiffs/pop_vals_chn_urban.tif
# GEM_FILEPATH=/var/lib/tomcat6/webapps/geoserver/data/data/Geotiffs/my_geotiff_light.tif
fname=my_geotiff_put.xml
curl -v -s -o "${OUTDIR}${dname}${fname}"  -u $GEM_USER:$GEM_PASS --data-ascii "file:$GEM_FILEPATH" -XPUT "http://$GEM_HOST:$GEM_PORT/geoserver/rest/workspaces/ged/coveragestores/$GEM_COVERSTORE/external.geotiff?coverageName=$GEM_COVERAGE"

fname=my_layer_out.xml
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS  -H 'Content-type: application/xml' -d '<layer><defaultStyle>exposure_pop_urban</defaultStyle><enabled>true</enabled></layer>' -XPUT http://$GEM_HOST:$GEM_PORT/geoserver/rest/layers/ged:${GEM_COVERAGE}.xml

if [ 1 -eq 1 ]; then
fname=my_coverage_put.xml
#<keywords><string>WCS</string><string>GeoTIFF</string><string>my_geotiff_light</string></keywords>
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: application/xml' \
 --data "<coverage><name>$GEM_COVERAGE</name><title>$GEM_COVERAGE</title><enabled>true</enabled><keywords><string></string></keywords><metadata><entry key=\"cachingEnabled\">false</entry></metadata><metadataLinks><metadataLink><type>text/xml</type><metadataType>TC211</metadataType><content>http://178.79.187.26/geonetwork/srv/en/csw?outputschema=http%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd&amp;service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;elementsetname=full&amp;id=c800df22-f652-404d-b081-0b3de465a1f0</content></metadataLink></metadataLinks></coverage>" -XPUT "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/ged/coveragestores/$GEM_COVERSTORE/coverages/${GEM_COVERAGE}.xml"
fi

# 


curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS  -XPOST http://$GEM_HOST:$GEM_PORT/geoserver/rest/reset

exit 123

fname=workspace.txt
# curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -XGET "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces.xml"

#
#   WORKSPACE
#


# retrieve a workspace
fname=my_workspace_get.xml
curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -XGET "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace.xml"

grep -q -w 200 "${OUTDIR}${dname}${fname}.hea" >/dev/null
if [ $? -eq 0 ]; then
    # retrieve the eventually workspace content
    fname=my_geotiff_get.xml
    curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -XGET "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff.xml"
    grep -q -w 200 "${OUTDIR}${dname}${fname}.hea" >/dev/null
    if [ $? -eq 0 ]; then
        fname=my_geotiff_cover_get.xml
        curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -XGET "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/coverages/${GEM_COVERAGE}.xml"
        grep -q -w 200 "${OUTDIR}${dname}${fname}.hea" >/dev/null
        if [ $? -eq 0 ]; then
            fname=my_layer_del.xml
            curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS  -XDELETE http://$GEM_HOST:$GEM_PORT/geoserver/rest/layers/my_workspace:${GEM_COVERAGE}.xml

            fname=my_geotiff_cover_del.xml
            curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -d recurse=true -XDELETE http://$GEM_HOST:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/coverages/${GEM_COVERAGE}.xml


        fi
        
        # delete the content
        fname=my_geotiff_del.xml
        curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -d recurse=true  -XDELETE "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff.xml"
    fi

    # delete a workspace
    fname=my_workspace_del.xml
    curl -v -s -o "${OUTDIR}${dname}${fname}" -D "${OUTDIR}${dname}${fname}.hea" -u $GEM_USER:$GEM_PASS -XDELETE "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace.xml"
fi
# exit 111
# create workspace
fname=my_workspace_post.xml
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: text/xml' -d '<workspace><name>my_workspace</name></workspace>' -XPOST "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces"

#
#  STORES
#

# workspace deletion also imply store deletion

fname=my_geotiff_post.xml
#   <url>file:data/Geotiffs/pop_vals_gbr_urban.tif</url>
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: text/xml' -d '<coverageStore><name>my_geotiff</name><type>GeoTIFF</type><workspace>my_workspace</workspace><enabled>true</enabled></coverageStore>' -XPOST "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores"
# temp curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: text/xml' -d '<coverageStore><name>my_geotiff</name><type>GeoTIFF</type><enabled>true</enabled><workspace>my_workspace</workspace><url>file:data/Geotiffs/my_geotiff_light.tif</url></coverageStore>' -XPOST "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores"

# 
#  COVERAGES
#
if [ 1 -eq 0 ]; then
fname=my_coverage_put.xml
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: application/xml' \
 --data '<coverage><name>my_geotiff</name><enabled>true</enabled><metadataLinks><metadataLink><type>text/xml</type><metadataType>TC211</metadataType><content>http://178.79.187.26/geonetwork/srv/en/csw?outputschema=http%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd&amp;service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;elementsetname=full&amp;id=c800df22-f652-404d-b081-0b3de465a1f0</content></metadataLink></metadataLinks></coverage>' -XPOST "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/coverages"
fi
#
#  PUT GEOTIFF
# 
read pre
fname=my_geotiff_put.xml
# curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: application/geotiff' --data-binary @my_geotiff.tif -XPUT http://oq-platform-mn.birds.lan:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/file.geotiff
# curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -H 'Content-type: text/plain' -d 'file://data/Geotiffs/my_geotiff_light.tif' -XPUT "http://oq-platform-mn.birds.lan:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/external.geotiff?configure=first&coverageName=my_geotiff"
# curl -v -s -o "${OUTDIR}${dname}${fname}"  -u $GEM_USER:$GEM_PASS -XPUT -H 'Content-type: text/plain' --data-ascii '/home/nastasi/git/geonode/gs-data/data/mop.tif' "http://$GEM_HOST:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/external.geotiff?coverageName=my_geotiff&configure=first"

curl -v -s -o "${OUTDIR}${dname}${fname}"  -u $GEM_USER:$GEM_PASS --data-ascii "file:$GEM_FILEPATH" -XPUT "http://$GEM_HOST:$GEM_PORT/geoserver/rest/workspaces/my_workspace/coveragestores/my_geotiff/external.geotiff?coverageName=$GEM_COVERAGE"

read post



fname=my_layer_out.xml
curl -v -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS  -H 'Content-type: application/xml' -d '<layer><defaultStyle>exposure_pop_urban</defaultStyle><enabled>true</enabled></layer>' -XPUT http://oq-platform-mn.birds.lan:$GEM_PORT/geoserver/rest/layers/my_workspace:my_geotiff.xml


exit 123

declare -a stack
stack_i=0
retrieve_xml () {
    local i url pat dname fname
 
    url="$1"

    pat="$(echo "$url" | sed "s@http://${GEM_HOST}:$GEM_PORT/geoserver/rest/@@g")"
    dname="$(dirname "$pat")/"
    fname="$(basename "$pat")"
    if [ -f "${OUTDIR}${dname}${fname}" ]; then
        return
    fi
    if [ ! -d "${OUTDIR}$dname" ]; then
        mkdir -p "${OUTDIR}$dname"
    fi
    curl -s -o "${OUTDIR}${dname}${fname}" -u $GEM_USER:$GEM_PASS -XGET -H 'Accept: text/xml' "$url"

    echo "$pat" | grep -q '.*datastores/[^/]*.xml$'
    if [ $? -eq 0 ]; then
        echo "[$pat] match datastores"
        subdir="$(basename "$fname" .xml)/"
        if [ ! -f "${OUTDIR}${dname}$subdir/file.shp" ]; then
            curl -s -o "${OUTDIR}${dname}${subdir}file.shp" -u $GEM_USER:$GEM_PASS -XGET -H 'Accept: text/xml' "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/${dname}${subdir}file.shp"
  #          exit 123
        fi
    fi

    stack[$stack_i]="$(xmlstarlet sel -N atom=http://www.w3.org/2005/Atom -t -m "//atom:link" -v "concat(@href,'$NL')" "${OUTDIR}${dname}${fname}")"
    for i in ${stack[$stack_i]}; do
        # echo "inside loop"
        echo
        echo "STACK_I: $stack_i   I: [$i]"
        echo
        stack_i=$((stack_i + 1))
        retrieve_xml "$i"
        stack_i=$((stack_i - 1))
    done
}
# 
#  MAIN
IFS="$NL"

# if [ -d "$OUTDIR" ]; then
#     rm -rf "$OUTDIR"
# fi

# curl -o "test.xxx" -u $GEM_USER:$GEM_PASS -XGET "http://oq-platform2-mn.gem.lan/geonetwork/srv/en/csw?outputschema=http%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd&service=CSW&request=GetRecordById&version=2.0.2&elementsetname=full&id=99e52e0c-a892-41ac-bffd-6b4219b630c7"
curl -o "test.xxx" -u $GEM_USER:$GEM_PASS -XGET 'http://oq-platform2-mn.gem.lan/geonetwork/srv/en/csw?outputschema=http%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd&service=CSW&request=GetRecordById&version=2.0.2&elementsetname=full&id=34a9b491-dd16-4e8d-8675-29eb6b99ba1a'
exit 123

retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces.xml"
retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces/default.xml"
retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/namespaces.xml"
retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/namespaces/default.xml"
retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/layers.xml"
retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/layergroups.xml"
# retrieve_xml "http://oq-platform2-mn.gem.lan/geonetwork/srv/en/csw?outputschema=http%3A%2F%2Fwww.isotc211.org%2F2005%2Fgmd&service=CSW&request=GetRecordById&version=2.0.2&elementsetname=full&id=99e52e0c-a892-41ac-bffd-6b4219b630c7"
# retrieve_xml "http://${GEM_HOST}:$GEM_PORT/geoserver/rest/styles.xml"

# if [ -d "$OUTDIR" ]; then
#     rm -rf "$OUTDIR"
# fi
# mkdir "$OUTDIR"

# curl -o "${OUTDIR}/workspaces.xml" -u $GEM_USER:$GEM_PASS -XGET -H 'Accept: text/xml' http://${GEM_HOST}:$GEM_PORT/geoserver/rest/workspaces
# curl -o "${OUTDIR}/namespaces.xml" -u $GEM_USER:$GEM_PASS -XGET -H 'Accept: text/xml' http://${GEM_HOST}:$GEM_PORT/geoserver/rest/namespaces


# 
#  workspaces management
