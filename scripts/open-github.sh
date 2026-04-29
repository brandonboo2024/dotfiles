#!/bin/sh

cd $(tmux run "echo #{pane_current_path}")

url=$(git remote get-url origin)

if [[ $url == *github.com* ]]; then
  if [[ $url == git@* ]]; then
  url="${url#git@}"
  url="${url/:/\/}"
  url="https://$url"
  fi
elif [[ $url == *sr.ht* ]]; then
  url="${url#git@}"
  url="${url/:/\/}"
  url="https://$url"
else
  echo "This is not a valid github/sourcehut repo"
  exit 0
fi

xdg-open "$url"
