.PHONY: diary deploy

VIMWIKI_DIARY_PATH=~/fs/Apps/vimwiki/diary/
POSTS_PATH=./content/posts/

deploy: diary
	bin/deploy.sh

diary:
	bin/diary.sh $(VIMWIKI_DIARY_PATH) $(POSTS_PATH)
