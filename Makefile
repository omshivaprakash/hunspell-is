TMP=tmp
TH_GEN_IDX=/usr/share/mythes/th_gen_idx.pl

all: packages

clean:
	rm -f dicts/is.aff dicts/is.dic dicts/th_is.dat dicts/th_is.idx dicts/is.oxt dicts/is.xpi
	rm -f ${TMP}/wiktionary.dic ${TMP}/wiktionary.aff ${TMP}/wiktionary.extracted ${TMP}/wordlist.diff
	rm -f ${TMP}/huntest.aff ${TMP}/huntest.dic
	rmdir --ignore-fail-on-non-empty dicts/ ${TMP}/
	#  rm -f ${TMP}/??wiktionary-latest-pages-articles.xml ${TMP}/??wiktionary-latest-pages-articles.xml.texts

test:
	./makedict.sh test is

packages: dicts/is.oxt dicts/is.xpi

# LibreOffice extension
dicts/is.oxt: %.oxt: %.aff %.dic dicts/th_is.dat dicts/th_is.idx \
		packages/libreoffice/META-INF/manifest.xml \
		packages/libreoffice/description.xml \
		packages/libreoffice/dictionaries.xcu \
		packages/libreoffice/license.txt
	./makedict.sh packages is

# Mozilla extension
%.xpi: %.aff %.dic
		packages/mozilla/install.js \
		packages/mozilla/install.rdf \
	./makedict.sh packages is

dicts/is.aff: makedict.sh
	./makedict.sh is

dicts/is.dic: makedict.sh
	./makedict.sh is

dicts/th_is.dat: makethes.sh
	./makethes.sh

%.idx: %.dat
	LC_ALL=is_IS.utf8 ${TH_GEN_IDX} -o $@ < $<
