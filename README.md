# vim-help-popup

A modern, customizable popup help system for Vim that displays your commands and shortcuts in a clean, organized format.

> ⚠️ **This plugin requires Vim 9.0+ with vim9script and +popupwin support**

## ⚠️ Experimental Project Notice

> 🤖 **This plugin was created by AI as an experimental project.**
> 
> 🚧 **Breaking changes may occur at any time without notice.**
> 
> 🔬 **Use at your own risk in production environments.**

## Features

- **Modern Design**: Clean, minimal box-style layout with proper text wrapping
- **Fixed Width**: 80-character wide popup for consistent display
- **Smart Navigation**: Full keyboard navigation (j/k, C-d/u, C-f/b, G/gg)
- **Intelligent Text Wrapping**: Handles long content without breaking layout
- **Multi-byte Support**: Perfect display for CJK characters and Unicode
- **Section Organization**: Logical grouping of related commands
- **Fast Performance**: Built with vim9script for optimal speed

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
let g:help_popup_content = {
  \ 'file': {
  \   'title': 'File Operations',
  \   'items': [
  \     {'command': ':e **/*<Tab>', 'description': 'Find files with fuzzy completion', 'notes': 'Use tab for file completion'},
  \     {'command': ':find', 'description': 'Search in path', 'notes': 'Requires set path+=**'},
  \     {'command': 'gf', 'description': 'Open file under cursor', 'notes': 'Works with relative and absolute paths'},
  \   ]
  \ },
  \ 'navigation': {
  \   'title': 'Navigation Commands',
  \   'items': [
  \     {'command': 'C-o', 'description': 'Jump back in jump list', 'notes': 'Previous cursor position'},
  \     {'command': 'C-i', 'description': 'Jump forward in jump list', 'notes': 'Next cursor position'},
  \     {'command': 'gd', 'description': 'Go to definition', 'notes': 'Local definition search'},
  \   ]
  \ }
  \}

" Optional: Create a mapping for quick access
nnoremap <leader>? :HelpPopup<CR>
```

### 2. Use the command

- `:HelpPopup` - Display all help sections in a single, scrollable popup window

### 3. Navigate the popup

**Basic Navigation:**
- `j`/`k` or `↓`/`↑` - Scroll line by line
- `q` or `ESC` - Close popup

**Advanced Scrolling:**
- `Ctrl-d`/`Ctrl-u` - Scroll half page down/up
- `Ctrl-f`/`Ctrl-b` - Scroll full page down/up
- `G`/`gg` - Jump to bottom/top

## Example Configuration

Here's a comprehensive example configuration:

```vim
let g:help_popup_content = {
  \ 'file': {
  \   'title': 'File Operations',
  \   'items': [
  \     {'command': ':e **/*<Tab>', 'description': 'Find and edit files', 'notes': 'Uses Vim'\''s built-in fuzzy finding with tab completion'},
  \     {'command': ':find filename', 'description': 'Search file in path', 'notes': 'Requires set path+=** in vimrc'},
  \     {'command': 'gf', 'description': 'Edit file under cursor', 'notes': 'Works with relative paths, URLs, and includes'},
  \     {'command': ':Explore', 'description': 'Open file explorer', 'notes': 'Built-in netrw file browser'},
  \   ]
  \ },
  \ 'windows': {
  \   'title': 'Window Management',
  \   'items': [
  \     {'command': 'C-w s', 'description': 'Split window horizontally', 'notes': 'Creates new horizontal split'},
  \     {'command': 'C-w v', 'description': 'Split window vertically', 'notes': 'Creates new vertical split'},
  \     {'command': 'C-w w', 'description': 'Switch between windows', 'notes': 'Cycles through all windows'},
  \     {'command': 'C-w q', 'description': 'Close current window', 'notes': 'Same as :q but for windows'},
  \   ]
  \ },
  \ 'search': {
  \   'title': 'Search & Replace',
  \   'items': [
  \     {'command': '/', 'description': 'Search forward', 'notes': 'Use n/N to navigate results'},
  \     {'command': '?', 'description': 'Search backward', 'notes': 'Use n/N to navigate results'},
  \     {'command': '*', 'description': 'Search word under cursor', 'notes': 'Searches for exact word boundaries'},
  \     {'command': ':%s/old/new/gc', 'description': 'Replace with confirmation', 'notes': 'g=all, c=confirm each replacement'},
  \   ]
  \ }
  \}

" Create convenient mapping
nnoremap <leader>h :HelpPopup<CR>
```

## Display Format

The plugin displays content in a clean, organized format:

```
┌─ File Operations ──────────────────────────────────────────┐
│                                                            │
│  :e **/*<Tab>                                              │
│    Find and edit files                                     │
│      Uses Vim's built-in fuzzy finding with completion    │
│                                                            │
│  gf                                                        │
│    Edit file under cursor                                  │
│      Works with relative paths, URLs, and includes        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Plugin Structure

Each help item should have:
- `command`: The Vim command or key combination
- `description`: Brief explanation of what it does
- `notes`: (Optional) Additional details, tips, or requirements

## Customization

The plugin automatically handles:
- Text wrapping for long content
- Proper indentation hierarchy
- Multi-byte character display
- Consistent 80-character width

## License

MIT License