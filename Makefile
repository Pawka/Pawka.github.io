VIMWIKI_DIARY_PATH=~/Documents/Apps/vimwiki/diary
POSTS_PATH=./content/posts
STATIC_PATH=./static

.PHONY: diary
diary: content commit

.PHONY: content
content:
	bin/diary.sh $(VIMWIKI_DIARY_PATH) $(POSTS_PATH)

.PHONY: commit
commit:
	git add $(POSTS_PATH) $(STATIC_PATH)
	git commit -m "Updated content" || true


.PHONY: deploy
deploy: diary
	bin/deploy.sh

.PHONY: deps
deps:
	sudo apt-get install -y imagemagick exiftool
