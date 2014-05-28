#!/bin/sh

shortcode=$0
shortcode="${shortcode#*/}"
shortcode_folder="./src/${shortcode}"
xsl_folder="./xsl/${shortcode}"

settings_file="settings/${shortcode}.sh"

errors=0

if [ ! -f "${settings_file}" ]; then
	echo "Settings: '${settings_file}' do not exist, please create it"
	echo "Put in the following variable declarations"
	echo "xmls=...how to find all relevant xml files"
	echo "terms=...names of content types to group by"
	echo "default_type=...name of xml file if content-type field is empty"
	exit 1
fi


. "${settings_file}"


if [ ! -d "${shortcode_folder}" ]; then
	echo "'${shortcode}' does not exist, aborting"
	exit 1
fi

# xmls=`find "${shortcode_folder}" -type f -iname "*.xml" -print0 | xargs -0 grep -L '<do-not-import/>' | sed 's/ /\\\\ /g' | xargs grep -l '<is-leaf-node/>' |  sed 's/ /\\\\ /g'`

# terms=(Produkte Informationen Kurzmeldungen Forum Umfrage Forderungen Themenschwerpunkt)

# #echo $terms

# # IFS=', ' read -ra array <<< "$terms"

# default_type="Artikel"

write_content_type_file() {
	local content_type=$1
	local file="./import/${shortcode}/${content_type}.xml"
	local results=$2

	mkdir -p "./import/${shortcode}"

	echo "${content_type}:"
	
	echo '<?xml version="1.0" encoding="UTF-8"?>\n<pages>' > "${file}"
	echo "$results" | sed 's/ /\\ /g' | xargs cat >> "${file}"
	echo '</pages>' >> "${file}"

	if [ ! -z "$preprocess" ]; then
		$(find "$file" -exec ${preprocess} \;;)
	fi

	if [ -r "${xsl_folder}/${content_type}.xsl" ]; then
		echo "XSL Postprocessing ${content_type}"
		transformed_file="${file//.xml/.transformed.xml}"

		# SHR API Edgecase
		if [ "${shortcode}" = "shrapi" ]; then
			url_shortcode="shr"
		else
			url_shortcode="${shortcode}"
		fi


		xsltproc --stringparam export_host "${EXPORT_HOST}/${url_shortcode}/XML-Pages/" "xsl/${shortcode}/${content_type}.xsl" "import/${shortcode}/${content_type}.xml" | xmllint --format -o "${transformed_file}" -
		if [ $? -eq 0 ] && [ -z "${DEBUG}" ]; then
			mv "${transformed_file}" "${file}"
		fi
	fi

	if [ ! -z "$postprocess" ]; then
		echo "Postprocessing"
		$(find "$file" -exec ${postprocess} \;;)
	fi

	xmllint "${file}" > /dev/null

	if [ $? -ne 0 ]; then
		echo "${content_type} XML is not valid"
		errors=1
	fi
	echo "${results}" | wc -l	
}

for i in `seq 1 ${#terms[@]}`;
do
	j=$( echo $i - 1 | bc )
	t="${terms[$j]}"	
	if [ "${ENV}" = "test" ]; then
		results=$(echo $xmls | xargs grep -l "<content-type>$t</content-type>" | head -n 15)
	else
		results=$(echo $xmls | xargs grep -l "<content-type>$t</content-type>")
	fi
	write_content_type_file "${t}" "$results"
done

results=$(echo $xmls | xargs grep -L "<content-type>")

write_content_type_file $default_type "$results"

if [ $errors -ne 0 ]; then
	echo "Not all XML-files are valid"
	exit 1
else
	echo "Successfully generated XML-Files for ${shortcode}"
	exit 0
fi