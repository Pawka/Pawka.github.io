.PHONY: diary

VIMWIKI_DIARY_PATH=~/fs/Apps/vimwiki/diary/
POSTS_PATH=./content/posts/

diary:
	bin/diary.sh $(VIMWIKI_DIARY_PATH) $(POSTS_PATH)
