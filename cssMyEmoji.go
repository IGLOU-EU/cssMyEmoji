package main

import (
	"bufio"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

var cssFile = "emoji.css"
var htmlFile = "test/index.html"
var emoji map[string]string

func main() {
	start := time.Now()
	emoji = make(map[string]string)

	res, err := http.Get("https://unicode.org/Public/emoji/13.1/emoji-test.txt")
	if err != nil {
		log.Fatal(err)
	}

	page, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		log.Fatal(err)
	}

	extractEmoji(string(page))
	makeCSSFile(emoji)
	makeDemoFile(emoji)

	fmt.Printf("In %s\n%d Emoji generated\nCSS file: ./%s\nPreview file: ./%s\n", time.Since(start), len(emoji), cssFile, htmlFile)
}

func extractEmoji(p string) {
	name := ""

	sc := bufio.NewScanner(strings.NewReader(p))
	re := regexp.MustCompile(`(?m)[^#]*# ([^ ]*) \D\d+\.\d+ (.+)`)
	reNoWord := regexp.MustCompile(`([^\w-_])`)
	reDeMult := regexp.MustCompile(`(_+)`)

	for sc.Scan() {
		l := sc.Text()

		if !strings.Contains(l, "fully-qualified") {
			continue
		}

		l = strings.TrimSpace(l)
		match := re.FindStringSubmatch(l)

		if len(match) != 3 {
			continue
		}

		name = match[2]

		name = strings.ReplaceAll(name, "+", "plus")
		name = strings.ReplaceAll(name, "=", "equal")
		name = strings.ReplaceAll(name, "?", "exclamation_point")
		name = strings.ReplaceAll(name, "!", "interrogation_point")
		name = strings.ReplaceAll(name, "$", "dollar")
		name = strings.ReplaceAll(name, "*", "asterisk")
		name = strings.ReplaceAll(name, "#", "sharp")
		name = strings.ReplaceAll(name, "&", "and")

		name = reNoWord.ReplaceAllString(match[2], "_")
		name = reDeMult.ReplaceAllString(name, "_")

		emoji[name] = match[1]
	}
}

func makeCSSFile(kl map[string]string) {
	css := `.emoji {font-family: "Monaco", "DejaVu Sans Mono", "Lucida Console", "Andale Mono", "monospace";}`

	f, err := os.OpenFile(cssFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	for k, i := range kl {
		css += ".emoji." + k + "::before{content:\"" + i + "\"}"
	}

	if _, err = f.WriteString(css); err != nil {
		log.Fatal(err)
	}
}

func makeDemoFile(kl map[string]string) {
	css := "<!DOCTYPE html><html><head><meta charset='utf-8'><link rel='stylesheet' type='text/css' href='../emoji.css'><style>#info{position:fixed;background:lightgreen;padding:1em;display:none}.active{display:block !important}body{display:grid;grid-template-columns:repeat(3,1fr);grid-gap:.5rem;}span{padding:1rem;border:2px dashed lightblue;text-align:center; min-height: 8em;display: flex;flex-direction: column;justify-content: space-around;white-space: nowrap;}sup{padding-top: .5em;margin-top: .5em;border-top: 1px dashed lightblue;display:block}::before{font-weight: bold;font-size: 4em;}</style><body>"

	f, err := os.OpenFile(htmlFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	for k := range kl {
		css += "<span role='img' class='emoji " + k + "'><sup>." + k + "</sup></span>"
	}

	css += "<div id='info'></div><script src='main.js'></script></body></html>"

	if _, err = f.WriteString(css); err != nil {
		log.Fatal(err)
	}
}
