# Personal snippets

Store snippets in major-mode directories, for example `python-mode/dbg`.
Use `M-x yas-new-snippet`, then `M-x yas-load-snippet-buffer-and-close`
to save and activate a snippet. After pulling snippets from another machine,
run `M-x yas-reload-all` if Emacs is already running.

Commit this directory along with the Emacs configuration to share snippets
between machines. Installed `yasnippet-snippets` remain available separately.
