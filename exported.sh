#!/bin/sh
exported=$(find src/vzbv -type f -iname "*.xml" | cut -d'/' -f 3 | cut -d'.' -f1 | sort)
# echo $exported
echo "${exported}" | xargs -n1 -I{} gsed -n -e "s/<content-type>\(.*\)<\/content-type>/\1/p" "./src/vzbv/{}.xml" | sort | uniq -c