VIMWIKI_DIARY_PATH=~/Documents/Apps/vimwiki/diary
POSTS_PATH=./content/posts

.PHONY: diary
diary: content
	git add $(POSTS_PATH)
	git commit -m "Updated content" || true

.PHONY: content
content:
	bin/diary.sh $(VIMWIKI_DIARY_PATH) $(POSTS_PATH)


.PHONY: deploy
deploy: diary
	bin/deploy.sh

.PHONY: deps
deps:
	sudo apt-get install -y imagemagick exiftool
