d = (z) ->
  console.log z

STATES =
  MAIN: 1
  TEXT: 2
  CMD: 3

suggestions =
  1: #main
    list: []
    selection: 0
  3: #cmd
    list: []
    selection: null

NUM_SUGGESTIONS = 5

PERIOD = 46
TAB = 9
BACKSPACE = 8
N = 78
P = 80
J = 74
K = 75

state = STATES.MAIN
text_entered = ''
context = null
main_i = -2
main_choice = null
text_mode_text = ''
timer_id = null
suggestions_are_visible = false
sessions = []#todo load
bookmarks = []

$f = (id) ->
  if id[0] is '#'
    document.getElementById id[1..]
  else
    document.getElementsByTagName(id)[0]

is_down = (e) ->
  k = e.keyCode
  k is KEYS.CODES.PAGE_DOWN or
    k is KEYS.CODES.DOWN or
    ((e.altKey or e.ctrlKey) and (k is N or k is J))


# need some delay between calling this and user entering text
refresh_all = ->
  chrome.management.getAll (apps) =>
    chrome.bookmarks.getTree (tree) =>
      flatten_bookmarks tree[0]
      chrome.windows.getAll populate: true, (wins) =>
        tabs = (tab for tab in _.flatten(win.tabs for win in wins)) 
        suggestions[STATES.MAIN].list = COMMAND_NAMES[CONTEXTS.MAIN]
          .concat tabs
          .concat apps
          .concat sessions
          .concat bookmarks
          .concat SPECIAL_PAGES

        #todo remove?
        # if $f '#ferro'
        #   $f('#f-box').style.opacity = 1
        # else
        #   append_template()

flatten_bookmarks = (node) ->
  if node.children
    unless node.children.length is 0
      flatten_bookmarks child for child in node.children
  else
    bookmarks.push node

update_selection = (down) -> 
  unless suggestions_are_visible
    display_suggestions()
  cur = suggestions[state].selection
#  $f('#f-' + cur).className = 'f-suggest';
  if down
    cur = (cur + 1) % NUM_SUGGESTIONS
  else
    cur = (cur - 1 + NUM_SUGGESTIONS) % NUM_SUGGESTIONS
#  $f('#f-' + cur).className += ' f-selected';
  suggestions[state].selection = cur
  display_suggestions()

show_suggestions = =>
  suggestions_are_visible = true # done early to diminish race
  display_suggestions()
  
update = (e) ->
  d 'inside update'
  suggestions[state].selection = 0
  c = String.fromCharCode e.keyCode
  d c

  # don't do anything with unprintable chars
  return if not c or e.altKey or e.ctrlKey or e.shiftKey 

  d c
  unless suggestions_are_visible
    if timer_id # very minor race condition
      clearTimeout timer_id
    timer_id = setTimeout (-> show_suggestions()), 200
  set_entered text_entered + c
  chrome.history.search {text: text_entered, maxResults: 5}, (results) =>
    suggestions[state].list = suggestions[state].list.concat results
    re_sort()

gear_icon = chrome.extension.getURL 'images/gear.png'
page_icon = chrome.extension.getURL 'images/page.ico'
pages_icon = chrome.extension.getURL 'images/pages.ico'
filter = _.filter
  
re_sort = ->
  suggestions[state].list = _.sortBy suggestions[state].list, (s) =>
#     x = s.name or s.title or s.url
# #    d s
#     x.charCodeAt(0)

    # everything has a name except for tabs
    if s.name
      weight = s.name.score text_entered
    else
      weight = _.max [s.title?.score text_entered, s.url?.score text_entered]
    1 - weight 

  # for s in suggestions[state].list
  #   if s.name
  #     weight = s.name.score text_entered
  #   else
  #     weight = _.max [s.title?.score text_entered, s.url?.score text_entered]
  #   d 1 - weight 
  if suggestions_are_visible
    display_suggestions()

set_suggestions_visibility = (visible) ->
  d 'set_suggestions_visibility'
  $f('#f-suggestions').style.opacity = if visible then 1 else 0
  suggestions_are_visible = visible
  if visible
    $('body').addClass('full')
  else
    $('body').removeClass('full')
  if timer_id
    clearTimeout timer_id
    timer_id = null

is_up = (e) ->
  k = e.keyCode
  k is KEYS.CODES.PAGE_UP or
    k is KEYS.CODES.UP or
    ((e.altKey or e.ctrlKey) and (k is P or k is K))

# todo remove?
set_entered = (e) ->
  text_entered = e
  $f('#f-entered-text').innerHTML = e.toLowerCase()

execute = ->
  if main_i < 0
    d 'yes'
    d suggestions[STATES.MAIN].selection
  d 'suggestions'
  d suggestions
  d 'main_choice:'
  d main_choice()
  if main_choice().cmd and not text_mode_text
    d 'main_choice.cmd'
    send_cmd main_choice().cmd
  else
    d 'execute else'
    cmd_i = suggestions[STATES.CMD].selection
    cmd_choice = suggestions[STATES.CMD].list[cmd_i]?.cmd
    cmd_choice or= COMMANDS[DEFAULTS[get_type main_choice()]]
    d 'cmd_choice'
    d cmd_choice
    arg = text_mode_text or main_choice()
    d 'arg'
    d arg      
    send_cmd cmd_choice, arg
  # window.close()
  d 'window.close'

# if no arg, uses current tab
send_cmd = (choice, arg = null) ->
  chrome.tabs.getSelected (tab) ->
    d 'send_cmd current tab'
    d tab
    choice.fn arg or tab

get_type = (o) -> # see, wouldn't a class system be nice?
  if 'cmd' of o
    CONTEXTS.COMMAND
  else if 'version' of o
    if o?.isApp then CONTEXTS.APP else CONTEXTS.EXTENSION
  else if 'dateAdded' of o
    CONTEXTS.BOOKMARK
  else if 'index' of o
    CONTEXTS.TAB
  else if 'wins' of o
    CONTEXTS.SESSION
  else if 'id' of o
    CONTEXTS.HISTORY
  else
    CONTEXTS.SPECIAL
  
switch_to_command = ->
  if text_mode_text
    context = CONTEXTS.TEXT
  else
    type = get_type main_choice()
    if type is CONTEXTS.COMMAND
      return
    else
      context = type
  suggestions[STATES.CMD].list = COMMAND_NAMES[context]
  state = STATES.CMD
  set_entered ''
  set_suggestions_visibility false
  $f('#f-main').className = ''  #todo for text
  $f('#f-cmd').className = 'f-selected'
  
switch_to_main = ->
  state = if text_mode_text then STATES.TEXT else STATES.MAIN
  set_entered ''

  set_suggestions_visibility false
  $f('#f-main').className = 'f-selected'
  if text_mode_text
    $f('#f-text').focus() 
  $f('#f-cmd').className = ''
  
append_template = =>
  d 'appending template'
  # tem = templates.ferro {suggestions, state, text_entered: text_entered.toLowerCase(), ferro, gear_icon, page_icon, pages_icon, filter}
  div = document.createElement 'div'
  # div.innerHTML = tem
#  $f('body').appendChild
  x = coffeecup.render popup_template, {
    text_mode_text, state, STATES, suggestions, text_entered: text_entered.toLowerCase(), NUM_SUGGESTIONS, gear_icon, page_icon, pages_icon, filter
  }
  div.innerHTML = x
  div.id = 'ferro-container'
  $f('body').appendChild div
  $f('#f-text').value = text_mode_text
  d 'done appending'

display_suggestions = ->
  felem = $f '#ferro-container'
  # felem = $f '#ferro'
  body = $f 'body'
  body.removeChild felem if felem
  append_template()
  set_suggestions_visibility true

main_choice = ->
  main_i = suggestions[STATES.MAIN].selection
  suggestions[STATES.MAIN].list[main_i]

#here not changing
update_default_cmd = ->
  setTimeout ->
    suggestions[STATES.CMD].selection = 0
    cmd_name = DEFAULTS[get_type main_choice()]
    cmd = COMMANDS[cmd_name]
    cmd.name = cmd_name      
    suggestions[STATES.CMD].list = [cmd]
    display_suggestions()
  , 800 


# STATE machine
# TODO key.preventDefault()
window.onkeydown = (key) =>
  d 'onkeydown ' + key.keyCode
  return if key.keyCode is 91 # apple command key

  if key.keyCode is KEYS.CODES.RETURN and text_entered
    execute()
    return

  switch state
    when STATES.MAIN
      if _([PERIOD, 190, 110]).contains key.keyCode # todo are there other equiv key codes? switch to keypressed and char codes?
        window.setTimeout ->
          $f('#f-text').value = ''
        , 10
        $f('#f-text').style.visibility = 'visible'
        $f('#f-text').focus()
        state = STATES.TEXT
      else if key.keyCode is TAB
        switch_to_command()
      else if key.keyCode is BACKSPACE
        set_entered ''
      else if is_down(key) or is_up(key)
        update_selection is_down key
      else 
        if key.keyCode > 31 # is viewable char
          update key
          update_default_cmd()
    when STATES.TEXT
      if key.keyCode is TAB
        text_mode_text = $f('#f-text').value
        $f('#f-cmd').focus()
        switch_to_command()
    when STATES.CMD
      if key.keyCode is TAB
        switch_to_main()
        key.preventDefault()
      else if is_down(key) or is_up(key)
        update_selection is_down key
      else
        suggestions[state].selection or= 0
        update key
        key.preventDefault() # prevents character briefly showing up in #f-text


