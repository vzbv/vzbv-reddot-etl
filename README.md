# vzbv-reddot-etl

Transform single paged XML exports (e.g. from RedDot) into joined XML-Files one for each ContentType
This tools is multi-project aware, so you can use it to transform different export sets identified by a project-shortcode. As an example `vzbv` is used.

# Dependencies

* `xmllint`
* `xsltproc`

On OS X this is done via `homebrew install xmllint xsltproc`

# Usage

Place your raw source XML-Files into `src/<project-shortcode>` and then  
run `./<project-shortcode>` within `vzbv-reddot-etl`'s root folder.

e.g. for Project __vzbv__
```
$ ./vzbv
```

# Settings

Configuration takes place in `settings/<project-shortcode>.sh`. 

```
# Find all files that should be used for import, returns a list of filepaths
xmls=`find "${shortcode_folder}" -type f -iname "*.xml" -print0 | xargs -0 grep -L '<do-not-import/>' | sed 's/ /\\\\ /g' | xargs grep -l '<is-leaf-node/>' | sed 's/ /\\\\ /g'` 

# Define ContentTypes to be found, currently it looks for the Node <content-type> within each file to determine the type
terms=(meldung pm podcast urteil dokument vpk publikation)

# Optionally preprocess input files
# preprocess="gsed -i s,<href>/\./\(.*\)\.xml</href>,<href>\1</href>,g {}"
# or postprogress after XSL-Transformations have taken place
# postprocess="perl -0777 -p -i -e s/\s*\(Stand[:.]?\s*[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{2}([0-9]{2})?\s*\)\s*//g {}"

# Define how to call the File that contains all unmatched Types
default_type="Dummy"
```