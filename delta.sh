imported=$(curl -L "${REMOTE_ENDPOINT}" | sort)

project=vzbv

types=(meldung pm podcast urteil dokument vpk publikation)

exported=$(find src/${project} -type f -iname "*.xml" | cut -d'/' -f 3 | cut -d'.' -f1 | sort)

echo "${imported}" > imported.txt
echo "${exported}" > exported.txt

delta=$(comm -13 <(echo "${imported}") <(echo "${exported}") | xargs -n1 -I{} gsed -n -e "s/<content-type>\(.*\)<\/content-type>/\1 {}/p" "./src/${project}/{}.xml" | sort)

echo "${delta}" > delta.txt
delta_count=$(echo "${delta}" | wc -l)

import_count=$(echo "${imported}" | wc -l)
export_count=$(echo "${exported}" | wc -l)

percent_off=$(echo "scale=2;(${delta_count}/${export_count})*100" | bc)

echo "Exported from RedDot: $export_count"
echo "Export stats"
echo "${exported}" | xargs -n1 -I{} gsed -n -e "s/<content-type>\(.*\)<\/content-type>/\1/p" "./src/${project}/{}.xml" | sort | uniq -c
echo "Imported into Drupal: $import_count"
echo "Import stats"
echo "${imported}" | xargs -n1 -I{} gsed -n -e "s/<content-type>\(.*\)<\/content-type>/\1/p" "./src/${project}/{}.xml" | sort | uniq -c
echo "Delta: $delta_count"
echo "${percent_off}% loss"

echo "Delta stats:"
echo "${delta}" | cut -d' ' -f 1 | uniq -c