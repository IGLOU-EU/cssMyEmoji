#!/bin/bash
# Copyright 2018 Iglou.eu
# Copyright 2018 Adrien Kara
# license that can be found in the LICENSE file.
shopt -s extglob

emojiUrl="https://unicode.org/emoji/charts/full-emoji-list.html"
emojiList=""
emojiFile="$(pwd)/emoji.css"
emojiTest="$(pwd)/test.html"
emojiListFile="$(pwd)/emoji.list"

line=0
debug=0
entrie=0
cssOut=""
htmlOut=""

[[ ! -e $emojiListFile ]] && curl "$emojiUrl" -o "$emojiListFile"
emojiList="$(grep -e "'chars'" -e "'name'" "$emojiListFile")"
[[ $debug -ne 1 ]] && rm "$emojiListFile"

IFS=$'\n'
for data in $emojiList
do
    if [ $((line%2)) -eq 0 ]; then
        data=${data#*\'>}
        data=${data%</*}

        emoji[$entrie]=$data
    else
        data=${data#*class=\'name\'>}
        data=${data%</*}
        data=${data% (*}
        data=${data//\&amp;/and}
        data=${data//\#/sharp}
        data=${data//\*/asterisk}
        data=${data//[⊛’:“”\!.,]/}
        data=${data//+( )/_}

        cldr[$entrie]=$data
        ((entrie++))
    fi

        ((line++))
done

((entrie--))
echo "Total of emoji: $entrie"

while true; do
    if (("$entrie" < "0")); then
        break
    fi

    cssOut+=".emoji.${cldr[$entrie]}::before{content:\"${emoji[$entrie]}\"}"
    htmlOut+="<span role=\"image\" class=\"emoji ${cldr[$entrie]}\"><sup>.${cldr[$entrie]}</sup></span>"

    ((entrie--))
done

echo "$cssOut" > "$emojiFile"
echo "Css updated in '$emojiFile'"

echo "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><link rel='stylesheet' type='text/css' href='emoji.css'><style>body{display:grid;grid-template-columns:repeat(4,1fr);grid-gap:.5rem;}span{font-size:6em;padding:1rem;border:2px dashed lightblue;text-align:center}sup{font-size:1rem;display:block}</style></head><body>${htmlOut}</body></html>" > "$emojiTest"
echo "Html updated in '$emojiTest'"

exit 0
