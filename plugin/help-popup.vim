vim9script

# ==============================================================================
# Vim Help Popup Plugin
# ==============================================================================
# Check Vim version and features
if !has('vim9script')
  finish
endif

if !has('popupwin')
  echoerr 'vim-help-popup: +popupwin feature is required'
  finish
endif

# Prevent loading twice
if exists('g:loaded_help_popup')
  finish
endif
g:loaded_help_popup = 1

# ==============================================================================
# Internal Functions
# ==============================================================================

# Calculate display width accurately for multi-byte characters
def GetDisplayWidth(str: string): number
  return strdisplaywidth(str)
enddef

# Pad string to specified width
def PadString(str: string, width: number): string
  var current_width = GetDisplayWidth(str)
  if current_width >= width
    return str
  endif
  return str .. repeat(' ', width - current_width)
enddef

# Format help section into table
def FormatHelpSection(section_data: dict<any>): list<string>
  var lines: list<string> = []
  
  # Calculate column widths
  var cmd_width = 16
  var desc_width = 14
  var notes_width = 34
  
  # Adjust widths based on content
  for item in section_data.items
    cmd_width = max([cmd_width, GetDisplayWidth(item.command)])
    desc_width = max([desc_width, GetDisplayWidth(item.description)])
    notes_width = max([notes_width, GetDisplayWidth(item.notes)])
  endfor
  
  # Consider header widths
  cmd_width = max([cmd_width, GetDisplayWidth('Command')])
  desc_width = max([desc_width, GetDisplayWidth('Description')])
  notes_width = max([notes_width, GetDisplayWidth('Notes')])
  
  # Total width
  var total_width = cmd_width + desc_width + notes_width + 10
  
  # Title row
  add(lines, '╔' .. repeat('═', total_width - 2) .. '╗')
  var title_padding = (total_width - 2 - GetDisplayWidth(section_data.title)) / 2
  add(lines, '║' .. repeat(' ', title_padding) .. section_data.title .. 
             repeat(' ', total_width - 2 - title_padding - GetDisplayWidth(section_data.title)) .. '║')
  
  # Header separator
  add(lines, '╠' .. repeat('═', cmd_width + 2) .. '╪' .. 
             repeat('═', desc_width + 2) .. '╪' .. 
             repeat('═', notes_width + 2) .. '╣')
  
  # Header row
  add(lines, '║ ' .. PadString('Command', cmd_width) .. ' │ ' .. 
             PadString('Description', desc_width) .. ' │ ' .. 
             PadString('Notes', notes_width) .. ' ║')
  
  # Header bottom separator
  add(lines, '╠' .. repeat('═', cmd_width + 2) .. '╪' .. 
             repeat('═', desc_width + 2) .. '╪' .. 
             repeat('═', notes_width + 2) .. '╣')
  
  # Data rows
  for item in section_data.items
    add(lines, '║ ' .. PadString(item.command, cmd_width) .. ' │ ' .. 
               PadString(item.description, desc_width) .. ' │ ' .. 
               PadString(item.notes, notes_width) .. ' ║')
  endfor
  
  # Footer
  add(lines, '╚' .. repeat('═', cmd_width + 2) .. '╧' .. 
             repeat('═', desc_width + 2) .. '╧' .. 
             repeat('═', notes_width + 2) .. '╝')
  
  return lines
enddef

# Popup filter for scrolling
def HelpPopupFilter(winid: number, key: string): bool
  if key == 'q' || key == "\<Esc>"
    popup_close(winid)
    return true
  elseif key == 'j' || key == "\<Down>"
    win_execute(winid, "normal! \<C-e>")
    return true
  elseif key == 'k' || key == "\<Up>"
    win_execute(winid, "normal! \<C-y>")
    return true
  elseif key == "\<C-d>" || key == "\<PageDown>"
    win_execute(winid, "normal! \<C-d>")
    return true
  elseif key == "\<C-u>" || key == "\<PageUp>"
    win_execute(winid, "normal! \<C-u>")
    return true
  elseif key == 'G'
    win_execute(winid, "normal! G")
    return true
  elseif key == 'g'
    g:help_g_pressed = true
    return true
  elseif get(g:, 'help_g_pressed', false) && key == 'g'
    win_execute(winid, "normal! gg")
    g:help_g_pressed = false
    return true
  endif
  
  if exists('g:help_g_pressed')
    g:help_g_pressed = false
  endif
  
  return false
enddef

# ==============================================================================
# Public Functions
# ==============================================================================

# Show help section
def g:HelpPopupShow(section: string): void
  if !exists('g:help_popup_content')
    echo "Error: g:help_popup_content is not defined. Please define your help content."
    return
  endif
  
  if !has_key(g:help_popup_content, section)
    echo "Unknown help section: " .. section
    return
  endif
  
  # Generate content
  var content = FormatHelpSection(g:help_popup_content[section])
  add(content, '')
  add(content, '  j/k: scroll  │  C-d/C-u: page  │  G/gg: bottom/top  │  q/ESC: close')
  
  # Calculate popup size
  var max_height = float2nr(&lines * 0.8)
  var max_width = float2nr(&columns * 0.9)
  
  # Popup options
  var opts = {
    line: 'cursor+1',
    col: 'cursor',
    pos: 'center',
    maxheight: max_height,
    maxwidth: max_width,
    minwidth: 60,
    minheight: 10,
    border: [],
    padding: [0, 1, 0, 1],
    scrollbar: 1,
    wrap: 0,
    highlight: 'Normal',
    borderhighlight: ['Comment'],
    mapping: false,
    filter: HelpPopupFilter,
    firstline: 1,
  }
  
  popup_create(content, opts)
enddef

# Show help index
def g:HelpPopupIndex(): void
  if !exists('g:help_popup_content')
    echo "Error: g:help_popup_content is not defined. Please define your help content."
    return
  endif
  
  var sections = keys(g:help_popup_content)
  var index_lines: list<string> = []
  
  # Generate index dynamically
  add(index_lines, '╔════════════════════════════════════════════════════════════════╗')
  add(index_lines, '║                      Vim Help Index                             ║')
  add(index_lines, '╠════════════════════════════════════════════════════════════════╣')
  
  var idx = 1
  for section in sort(sections)
    var title = g:help_popup_content[section].title
    var key_hint = exists('g:help_popup_mappings') && has_key(g:help_popup_mappings, section) 
                   ? printf('(%s)', g:help_popup_mappings[section]) 
                   : ''
    var line_content = printf('  %d. %-25s %-20s', idx, title, key_hint)
    add(index_lines, '║' .. PadString(line_content, 64) .. '║')
    idx += 1
  endfor
  
  add(index_lines, '╠════════════════════════════════════════════════════════════════╣')
  add(index_lines, '║         Press number key to show section                        ║')
  add(index_lines, '║              Press q or ESC to close                            ║')
  add(index_lines, '╚════════════════════════════════════════════════════════════════╝')
  
  var opts = {
    line: 'cursor+1',
    col: 'cursor',
    pos: 'center',
    border: [],
    padding: [0, 1, 0, 1],
    highlight: 'Normal',
    borderhighlight: ['Comment'],
    mapping: false,
    filter: HelpIndexFilter,
  }
  
  g:help_index_popup = popup_create(index_lines, opts)
enddef

# Index filter function
def HelpIndexFilter(winid: number, key: string): bool
  if key == 'q' || key == "\<Esc>"
    popup_close(winid)
    return true
  elseif key >= '1' && key <= '9'
    popup_close(winid)
    var sections = sort(keys(g:help_popup_content))
    var index = str2nr(key) - 1
    if index < len(sections)
      g:HelpPopupShow(sections[index])
    endif
    return true
  endif
  return false
enddef

# ==============================================================================
# Commands
# ==============================================================================

command! -nargs=0 HelpPopupIndex call g:HelpPopupIndex()
command! -nargs=1 HelpPopupShow call g:HelpPopupShow(<q-args>)

# Restore compatible options
&cpo = save_cpo
