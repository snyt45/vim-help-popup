# vim-help-popup

A customizable popup help system for Vim that displays your commands and shortcuts in a beautiful table format.

![Demo](https://user-images.githubusercontent.com/your-username/vim-help-popup/demo.gif)

## ⚠️ Experimental Project Notice

> 🤖 **This plugin was created by AI as an experimental project.**
> 
> 🚧 **Breaking changes may occur at any time without notice.**
> 
> 🔬 **Use at your own risk in production environments.**
## Features

- 📖 Display your custom help content in formatted tables
- 🎯 Section-based organization
- ⌨️  Scrollable popup windows (j/k, Ctrl-d/u, G/gg)
- 🎨 Beautiful box-drawing characters
- 🌏 Multi-byte character support (CJK friendly)
- ⚡ Fast and lightweight (vim9script)

## Requirements

- Vim 9.0+ with vim9script support
- `+popupwin` feature

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'snyt45/vim-help-popup'
```

### Compatibility Check

You can check if your Vim supports the required features:

```vim
:echo has('vim9script') && has('popupwin')
```

If it returns 0, you need to upgrade your Vim to version 9.0 or later.

## Usage
### 1. Define your help content in your vimrc

```vim
" Define your help content
g:help_popup_content = {
  \ 'file': {
  \   'title': 'File Operations',
  \   'items': [
  \     {'command': ':e **/*<Tab>', 'description': 'Find files', 'notes': 'With completion'},
  \     {'command': ':find', 'description': 'Search path', 'notes': 'Needs set path+=**'},
  \     {'command': 'gf', 'description': 'Goto file', 'notes': 'Under cursor'},
  \   ]
  \ },
  \ 'buffer': {
  \   'title': 'Buffer Operations', 
  \   'items': [
  \     {'command': ':ls', 'description': 'List buffers', 'notes': 'Show all buffers'},
  \     {'command': ':b <name>', 'description': 'Switch buffer', 'notes': 'Partial match OK'},
  \     {'command': ':bd', 'description': 'Delete buffer', 'notes': 'Close buffer'},
  \   ]
  \ }
  \}

" Optional: Define mappings for quick access
nnoremap <leader>? :HelpPopupIndex<CR>
nnoremap <leader>?f :HelpPopupShow file<CR>
nnoremap <leader>?b :HelpPopupShow buffer<CR>
```

### 2. Use the commands

- `:HelpPopupIndex` - Show the help index
- `:HelpPopupShow {section}` - Show a specific section

### 3. Navigate the popup

- `j`/`k` or `↓`/`↑` - Scroll line by line
- `Ctrl-d`/`Ctrl-u` - Scroll half page
- `G`/`gg` - Go to bottom/top
- `q` or `ESC` - Close popup

## Example Configuration

Here's a complete example with common Vim operations:

```vim
g:help_popup_content = {
  \ 'file': {
  \   'title': 'File Operations',
  \   'items': [
  \     {'command': ':e **/*<Tab>', 'description': 'Find files', 'notes': 'Fuzzy search with completion'},
  \     {'command': ':find', 'description': 'Search in path', 'notes': 'Requires set path+=**'},
  \     {'command': 'gf', 'description': 'Open file', 'notes': 'File under cursor'},
  \     {'command': ':Lex', 'description': 'File explorer', 'notes': 'Built-in netrw'},
  \   ]
  \ },
  \ 'git': {
  \   'title': 'Git Commands',
  \   'items': [
  \     {'command': ':!git status', 'description': 'Check status', 'notes': 'Current changes'},
  \     {'command': ':!git diff %', 'description': 'Diff current', 'notes': 'Current file only'},
  \     {'command': ':term git log', 'description': 'View history', 'notes': 'In terminal'},
  \   ]
  \ },
  \ 'search': {
  \   'title': 'Search & Replace',
  \   'items': [
  \     {'command': '/', 'description': 'Search forward', 'notes': 'n/N for next/prev'},
  \     {'command': '*', 'description': 'Search word', 'notes': 'Under cursor'},
  \     {'command': ':%s/old/new/g', 'description': 'Replace all', 'notes': 'Whole file'},
  \   ]
  \ }
  \}

" Set up convenient mappings
nnoremap <leader>? :HelpPopupIndex<CR>
nnoremap <leader>?f :HelpPopupShow file<CR>
nnoremap <leader>?g :HelpPopupShow git<CR>
nnoremap <leader>?s :HelpPopupShow search<CR>
```

## License

MIT License
