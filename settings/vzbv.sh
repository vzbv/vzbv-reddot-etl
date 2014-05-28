xmls=`find "${shortcode_folder}" -type f -iname "*.xml" -print0 | xargs -0 grep -L '<do-not-import/>' | sed 's/ /\\\\ /g' | xargs grep -l '<is-leaf-node/>' | sed 's/ /\\\\ /g'`

terms=(meldung pm podcast urteil dokument vpk publikation)
# SED_SCRIPT=$(cat <<EOF 

# EOF)


# preprocess="gsed -i s,<href>/\./\(.*\)\.xml</href>,<href>\1</href>,g {}"
# postprocess="perl -0777 -p -i -e s/\s*\(Stand[:.]?\s*[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{2}([0-9]{2})?\s*\)\s*//g {}"
default_type="Dummy"