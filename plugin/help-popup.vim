vim9script

# ==============================================================================
# Vim Help Popup Plugin
# A modern, customizable popup help system for Vim
# ==============================================================================

# Plugin metadata
const PLUGIN_NAME = 'vim-help-popup'
const REQUIRED_VIM_VERSION = '9.0'
const POPUP_WIDTH = 80
const CONTENT_WIDTH = 78

# Check Vim version and features
if !has('vim9script')
  echoerr $'{PLUGIN_NAME}: Vim {REQUIRED_VIM_VERSION}+ with vim9script is required'
  finish
endif

if !has('popupwin')
  echoerr $'{PLUGIN_NAME}: +popupwin feature is required'
  finish
endif

# Prevent loading twice
if exists('g:loaded_help_popup')
  finish
endif
g:loaded_help_popup = 1

# Save compatible options
var save_cpo = &cpo
set cpo&vim

# Script-local variables
var help_g_pressed = false

# ==============================================================================
# Utility Functions
# ==============================================================================

# Calculate display width accurately for multi-byte characters
def GetDisplayWidth(str: string): number
  return strdisplaywidth(str)
enddef

# Pad string to specified width with spaces
def PadString(str: string, width: number): string
  var current_width = GetDisplayWidth(str)
  if current_width >= width
    return str
  endif
  return str .. repeat(' ', width - current_width)
enddef

# Create a line with proper box border and padding
def CreateBoxLine(content: string, total_width: number): string
  var content_width = total_width - 2  # Account for │ on both sides
  var padding = content_width - GetDisplayWidth(content)
  return '│' .. content .. repeat(' ', max([0, padding])) .. '│'
enddef

# Create separator lines for box design
def CreateBoxSeparator(char: string, total_width: number): string
  return repeat(char, total_width - 2)
enddef

# ==============================================================================
# Text Processing Functions
# ==============================================================================

# Wrap text with proper indentation and box formatting
def WrapTextInBox(prefix: string, text: string, max_width: number): list<string>
  if empty(text)
    return []
  endif
  
  var lines: list<string> = []
  var content_width = max_width - 2  # Reserve space for box borders
  var available_width = content_width - GetDisplayWidth(prefix)
  
  if GetDisplayWidth(text) <= available_width
    # Text fits on single line
    var content = prefix .. text
    add(lines, CreateBoxLine(content, max_width))
  else
    # Text needs wrapping
    var remaining_text = text
    var is_first_line = true
    
    while !empty(remaining_text)
      var line_prefix = is_first_line ? prefix : repeat(' ', GetDisplayWidth(prefix))
      var line_width = content_width - GetDisplayWidth(line_prefix)
      var break_point = FindTextBreakPoint(remaining_text, line_width)
      
      var line_text = remaining_text[0 : break_point - 1]
      var content = line_prefix .. line_text
      add(lines, CreateBoxLine(content, max_width))
      
      remaining_text = remaining_text[break_point :]
      is_first_line = false
    endwhile
  endif
  
  return lines
enddef

# Find appropriate break point for text wrapping
def FindTextBreakPoint(text: string, max_width: number): number
  var break_point = 0
  var display_width = 0
  var char_idx = 0
  
  while char_idx < strlen(text)
    var char = text[char_idx]
    var char_width = GetDisplayWidth(char)
    if display_width + char_width > max_width
      break
    endif
    display_width += char_width
    char_idx += 1
    break_point = char_idx
  endwhile
  
  # Ensure at least one character is included
  return max([1, break_point])
enddef

# ==============================================================================
# Content Formatting Functions
# ==============================================================================

# Format individual help section with clean styling
def FormatHelpSection(section_data: dict<any>): list<string>
  if !has_key(section_data, 'title') || !has_key(section_data, 'items')
    return []
  endif
  
  var lines: list<string> = []
  
  # Create section header
  extend(lines, CreateSectionHeader(section_data.title))
  
  # Process each item in the section
  for item in section_data.items
    extend(lines, FormatHelpItem(item))
  endfor
  
  # Create section footer
  extend(lines, CreateSectionFooter())
  
  return lines
enddef

# Create section header with title
def CreateSectionHeader(title: string): list<string>
  var lines: list<string> = []
  var title_len = GetDisplayWidth(title)
  var header_dashes = CONTENT_WIDTH - 3 - title_len  # Account for "┌─ "
  
  if header_dashes < 0
    header_dashes = 0
  endif
  
  add(lines, '┌─ ' .. title .. ' ' .. repeat('─', header_dashes) .. '┐')
  add(lines, CreateBoxLine('', POPUP_WIDTH))
  
  return lines
enddef

# Format individual help item (command, description, notes)
def FormatHelpItem(item: dict<any>): list<string>
  var lines: list<string> = []
  
  # Validate item structure
  if !has_key(item, 'command') || !has_key(item, 'description')
    return lines
  endif
  
  # Format command with minimal indentation
  extend(lines, WrapTextInBox('  ', item.command, POPUP_WIDTH))
  
  # Format description with deeper indentation
  extend(lines, WrapTextInBox('    ', item.description, POPUP_WIDTH))
  
  # Format optional notes with deepest indentation
  if has_key(item, 'notes') && !empty(item.notes)
    extend(lines, WrapTextInBox('      ', item.notes, POPUP_WIDTH))
  endif
  
  # Add spacing between items
  add(lines, CreateBoxLine('', POPUP_WIDTH))
  
  return lines
enddef

# Create section footer
def CreateSectionFooter(): list<string>
  var lines: list<string> = []
  add(lines, '└' .. CreateBoxSeparator('─', POPUP_WIDTH) .. '┘')
  add(lines, '')
  return lines
enddef

# ==============================================================================
# Navigation and Input Handling
# ==============================================================================

# Main popup filter for handling all key inputs
def HelpPopupFilter(winid: number, key: string): bool
  # Handle exit keys
  if HandleExitKeys(key, winid)
    return true
  endif
  
  # Handle navigation keys
  if HandleNavigationKeys(key, winid)
    return true
  endif
  
  # Handle special keys (gg command)
  if HandleSpecialKeys(key, winid)
    return true
  endif
  
  # Reset any pending states for unhandled keys
  ResetPendingStates()
  
  return false
enddef

# Handle exit/close keys
def HandleExitKeys(key: string, winid: number): bool
  if key == 'q' || key == "\<Esc>"
    popup_close(winid)
    return true
  endif
  return false
enddef

# Handle navigation and scrolling keys
def HandleNavigationKeys(key: string, winid: number): bool
  var navigation_map = {
    'j': "\<C-e>",
    "\<Down>": "\<C-e>",
    'k': "\<C-y>",
    "\<Up>": "\<C-y>",
    "\<C-d>": "\<C-d>",
    "\<C-u>": "\<C-u>",
    "\<C-f>": "\<C-f>",
    "\<PageDown>": "\<C-f>",
    "\<C-b>": "\<C-b>",
    "\<PageUp>": "\<C-b>",
    'G': 'G'
  }
  
  if has_key(navigation_map, key)
    win_execute(winid, $'normal! {navigation_map[key]}')
    return true
  endif
  
  return false
enddef

# Handle special key combinations (like gg)
def HandleSpecialKeys(key: string, winid: number): bool
  if key == 'g'
    return HandleGCommand(winid)
  endif
  return false
enddef

# Handle the 'gg' command (go to top)
def HandleGCommand(winid: number): bool
  if help_g_pressed
    # Second 'g' pressed - execute gg command
    win_execute(winid, 'normal! gg')
    help_g_pressed = false
  else
    # First 'g' pressed - wait for second
    help_g_pressed = true
    timer_start(1000, function('ResetGPressed'))
  endif
  return true
enddef

# Reset any pending command states
def ResetPendingStates(): void
  if help_g_pressed
    help_g_pressed = false
  endif
enddef

# Timer callback to reset g command state
def ResetGPressed(timer_id: number): void
  help_g_pressed = false
enddef

# ==============================================================================
# Main Plugin Interface
# ==============================================================================

# Main help popup function - displays all help content
def g:HelpPopup(): void
  # Validate configuration
  if !ValidateConfiguration()
    return
  endif
  
  # Build popup content
  var content_lines = BuildPopupContent()
  
  # Create and display popup
  var popup_options = CreatePopupOptions()
  popup_create(content_lines, popup_options)
enddef

# ==============================================================================
# Content Building Functions
# ==============================================================================

# Validate user configuration
def ValidateConfiguration(): bool
  if !exists('g:help_popup_content')
    echohl ErrorMsg
    echo $'{PLUGIN_NAME}: g:help_popup_content is not defined. Please define your help content.'
    echohl None
    return false
  endif
  
  if type(g:help_popup_content) != v:t_dict
    echohl ErrorMsg
    echo $'{PLUGIN_NAME}: g:help_popup_content must be a dictionary'
    echohl None
    return false
  endif
  
  return true
enddef

# Build complete popup content
def BuildPopupContent(): list<string>
  var all_lines: list<string> = []
  
  # Add header with navigation help
  extend(all_lines, CreatePopupHeader())
  
  # Add all help sections
  var sections = keys(g:help_popup_content)
  for section_key in sections
    var section_data = g:help_popup_content[section_key]
    extend(all_lines, FormatHelpSection(section_data))
  endfor
  
  return all_lines
enddef

# Create popup header with navigation information
def CreatePopupHeader(): list<string>
  var lines: list<string> = []
  
  # Header border
  add(lines, '┌' .. CreateBoxSeparator('─', POPUP_WIDTH) .. '┐')
  
  # Title line - centered
  var title_text = '» Help Commands «'
  add(lines, CreateCenteredBoxLine(title_text, POPUP_WIDTH))
  
  # Separator
  add(lines, '├' .. CreateBoxSeparator('─', POPUP_WIDTH) .. '┤')
  
  # Navigation help
  var nav_text = 'Navigation: j/k ↓↑  •  Scroll: C-d/u C-f/b  •  Jump: G/gg  •  Exit: q'
  add(lines, CreateBoxLine(' ' .. nav_text, POPUP_WIDTH))
  
  # Footer border
  add(lines, '└' .. CreateBoxSeparator('─', POPUP_WIDTH) .. '┘')
  
  # Spacing
  add(lines, '')
  add(lines, '')
  
  return lines
enddef

# Create centered text line within box
def CreateCenteredBoxLine(text: string, total_width: number): string
  var content_width = total_width - 2
  var text_width = GetDisplayWidth(text)
  var padding_left = (content_width - text_width) / 2
  var padding_right = content_width - text_width - padding_left
  return '│' .. repeat(' ', padding_left) .. text .. repeat(' ', padding_right) .. '│'
enddef

# Create popup window options
def CreatePopupOptions(): dict<any>
  var max_height = (&lines * 8) / 10
  
  return {
    line: 'cursor+1',
    col: 'cursor',
    pos: 'center',
    width: POPUP_WIDTH,
    maxheight: max_height,
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
enddef

# ==============================================================================
# Commands
# ==============================================================================

command! -nargs=0 HelpPopup call g:HelpPopup()

# Restore compatible options
&cpo = save_cpo