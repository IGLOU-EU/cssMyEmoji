#!/bin/bash
# Copyright 2018 Iglou.eu
# Copyright 2018 Adrien Kara
# license that can be found in the LICENSE file.

emojiList="https://unicode.org/emoji/charts/full-emoji-list.html"
emojiFile="$(pwd)/emoji.css"
emojiTest="$(pwd)/test.html"

#
emojiList="$(curl ${emojiList}|grep -e "'chars'" -e "'name'")"

line=0
entrie=0
cssOut=""
htmlOut=""

IFS=$'\n'
for data in $emojiList
do
    if [ $((line%2)) -eq 0 ]; then
        data=${data#*\'>}
        data=${data%</*}

        emoji[$entrie]=$data
    else
        data=${data#*\'>}
        data=${data%</*}
        data=${data% (*}
        data=${data// /_}
        data=${data// &amp;/}
        data=${data//⊛ /}
        data=${data//[⊛’:“”\!.,]/}
        data=${data//keycap_#/keycap_sharp}
        data=${data//keycap_\*/keycap_asterisk}

        cldr[$entrie]=$data
        ((entrie++))
    fi

        ((line++))
done

while true; do
    if (("$entrie" < "0")); then
        break
    fi

    cssOut+=".emoji.${cldr[$entrie]}::before{content:\"${emoji[$entrie]}\"}"
    htmlOut+="<span class=\"emoji ${cldr[$entrie]}\"></span>"

    ((entrie--))
done

echo "$cssOut" > "$emojiFile"
echo "<!DOCTYPE html><html><head><meta charset="utf-8"><link rel='stylesheet' type='text/css' href='emoji.css'><style>body{display:flex;flex-wrap:wrap}span{font-size:6em;padding: 10px}</style></head><body>${htmlOut}</body></html>" > "$emojiTest"

exit 0
