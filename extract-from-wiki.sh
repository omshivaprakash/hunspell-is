#!/usr/bin/bash

TMP=tmp
LANG=is
RULE=`basename "$1"`
RULEDIR=$1

echo "   Extracting rule $RULE"

echo "#$RULE" >> dicts/$LANG.aff
echo "SFX $FLAG N $LINECOUNT" >> dicts/${LANG}.aff
cat "${RULEDIR}/aff" | sed "s/SFX X/SFX $FLAG/g" >> dicts/${LANG}.aff

if [ -e "$i/print-dic-entry" ]; then
	grep -o "^{{$RULE|[^}]\+" ${TMP}/${LANG}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | "./${RULEDIR}/print-dic-entry" $FLAG >> ${TMP}/${LANG}wiktionary.extracted
else
        if [ -e "${RULEDIR}/format" ]; then
		REFORMATSTRING="`cat "${RULEDIR}/format"`"
	else
		REFORMATSTRING="%s%s%s"
	fi
	grep -o "^{{$RULE|[^}]\+" ${TMP}/${LANG}wiktionary-latest-pages-articles.xml.texts | grep -o "|.*" | gawk -F "|" '{printf "'$REFORMATSTRING'\n", $1, $2, $3"/"'"$FLAG"'}' >> ${TMP}/${LANG}wiktionary.extracted
fi

