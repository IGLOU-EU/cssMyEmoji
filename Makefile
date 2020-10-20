.PHONY: build
build: clean
	go run cssMyEmoji.go

.PHONY: clean
clean:
	rm emoji.css
	rm test/index.html
