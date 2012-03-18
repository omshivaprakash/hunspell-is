LANG = is
TMP = tmp

#todo: read this from dir
RULES="Fallbeyging\ hk\ sb\ 01" \
	"Fallbeyging\ hk\ sb\ 01\ et"

all: ${TMP}/${LANG}wiktionary.extracted \
	dicts/${LANG}.dic \
	dicts/${LANG}.aff

langs/${LANG}/rules/$(RULES).test :
	  echo "Testing rule $(RULES)"
	  cat langs/${LANG}/common-aff.d/*.aff > ${TMP}/huntest.aff
	  LINECOUNT=$(shell grep -cve '^\s*$' "langs/${LANG}/rules/$(RULES)/aff")
	  echo "SFX X N ${LINECOUNT}" >> ${TMP}/huntest.aff
	  cp "$i/dic" ${TMP}/huntest.dic
	  test -z "`hunspell -l -d ${TMP}/huntest < "$i/good"`" || { echo "Good word test for $TESTNAME failed: `hunspell -l -d ${TMP}/huntest < "$i/good"`"; exit 1; }
	  test -z "`hunspell -G -d ${TMP}/huntest < "$i/bad"`" || { echo "Bad word test for $TESTNAME failed: `hunspell -G -d ${TMP}/huntest < "$i/bad"`"; exit 1; }

tests: langs/${LANG}/rules/$(RULES).test

test:
	find langs/${LANG}/rules/* -type d | while read i
	do
	  cat langs/${LANG}/common-aff.d/*.aff > ${TMP}/huntest.aff
	  LINECOUNT="`grep -cve '^\s*$' "$i/aff"`"
	  echo "SFX X N $LINECOUNT" >> ${TMP}/huntest.aff
	  cat "$i/aff" >> ${TMP}/huntest.aff
	  TESTNAME="`basename "$i"`"
	  echo "Testing rule $TESTNAME"
	  cp "$i/dic" ${TMP}/huntest.dic
	  test -z "`hunspell -l -d ${TMP}/huntest < "$i/good"`" || { echo "Good word test for $TESTNAME failed: `hunspell -l -d ${TMP}/huntest < "$i/good"`"; exit 1; }
	  test -z "`hunspell -G -d ${TMP}/huntest < "$i/bad"`" || { echo "Bad word test for $TESTNAME failed: `hunspell -G -d ${TMP}/huntest < "$i/bad"`"; exit 1; }
	done
	echo "All passed."

${TMP}/${LANG}wiktionary-latest-pages-articles.xml.bz2 :
	echo "Downloading from dumps.wikimedia.org"
	wget --no-use-server-timestamps http://dumps.wikimedia.org/${LANG}wiktionary/latest/${LANG}wiktionary-latest-pages-articles.xml.bz2 -O $@

${TMP}/${LANG}wiktionary-latest-pages-articles.xml : ${TMP}/${LANG}wiktionary-latest-pages-articles.xml.bz2
	echo "Extracting archive"
	bunzip2 -kf ${TMP}/${LANG}wiktionary-latest-pages-articles.xml.bz2
	touch $@

${TMP}/${LANG}wiktionary-latest-pages-articles.xml.texts : tmp/${LANG}wiktionary-latest-pages-articles.xml
	echo "Filtering xml"
	grep -o "{{[^.|]*|[^-.][^}]*" ${TMP}/${LANG}wiktionary-latest-pages-articles.xml | grep -v "{{.*|.*[ =]" | sort | uniq > $@

${TMP}/${LANG}wiktionary.extracted : ${TMP}/${LANG}wiktionary-latest-pages-articles.xml.texts
	echo "Extracting valid words from the wiktionary dump..."
	rm -f $@
	FLAG=$(shell grep -h -o [[:space:]][[:digit:]]*[[:space:]]N[[:space:]] langs/${LANG}/common-aff.d/*.aff | gawk 'BEGIN {max = 0} {if($$1>max) max=$$1} END {print max}')
	
	#extracting from wiki-templates based on defined rules
	$(foreach i, langs/${LANG}/rules/*, $(call extract-from-wiki.sh $i))
	
	#extracting abbreviations
	grep -C 3 "{{-is-}}" ${TMP}/${LANG}wiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-skammstöfun-}}" | grep "'''" | grep -o "[^']*" >> $@
	
	#extracting adverbs
	grep -C 3 "{{-is-}}" ${TMP}/${LANG}wiktionary-latest-pages-articles.xml | grep -C 2 "{{-is-atviksorð-}}" | grep "'''[^ ]*'''$" | grep -o "[^']*" | xargs printf "%s\tpo:a\n" >> $@
		

dict/${LANG}.dic : tmp/${LANG}wiktionary-latest-pages-articles.xml.texts
	ls


