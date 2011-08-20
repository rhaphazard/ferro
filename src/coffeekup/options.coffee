t = text

doctype 5
html ->
  head ->
    title 'Ferro - Chrome Extension'
    link
      href: 'compiled/options.css'
      media: 'all'
      rel: 'stylesheet'
      type: 'text/css'
    script src: 'vendor/json2.js'
    script src: 'vendor/jquery-1.6.1.min.js'
    script src: 'vendor/underscore-min.js'
    script src: 'vendor/underscore.string.min.js'
    script src: 'vendor/backbone.js'
    script src: 'vendor/backbone-localstorage.js'
    script src: 'compiled/options-backbone.js'
  body ->
    h2 'Ferro'
    p "Note that Ferro does not work on any special chrome:// pages, including this one, and Google's extension and app galleries. It also does not work in a tab whose page has not finished loading or when focus is on the address bar."
    h3 'Keyboard Shortcut'
    p 'Changes only take effect todo'
    h2 'Recommendations'
    h3 'Other extensions'
    ul id: 'session-list', ->
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/dbepggeogbaibhgnhhndojpepiihcmeb', -> 'Vimium'
    	  ': Provides better keyboard navigation. You can even customize the shortcuts to better match the one true editor.'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/hdokiejnpimakedhajhdlcegeplioahd', -> 'Lastpass'
    	  ': Automatically generate, remember, and fill in random passwords.'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/bjclhonkhgkidmlkghlkiffhoikhaajg', -> 'Greplin'
    	  ': Search your data.'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/gijmaphaippejlhagngohjmehmanbehd', -> 'QuickShift'
    	  ': Move Chrome tabs to a different window or to a new location within the current window using your keyboard.'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/ahmiiblnmmnijkhboligioinfchkeagi', -> 'Minimalist for Facebook'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/mgljgiacemcbnibkkmbolnljeffaadna', -> 'Minimalist for Google Calendar'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/oddhbkghjoccbljmagcgoklbfdjeiinb', -> 'Minimalist for Gmail'
    	li ->
    	  a href: 'https://chrome.google.com/webstore/detail/hihakjfhbmlmjdnnhegiciffjplmdhin', -> 'Rapportive'
    	  ': Replaces Gmail right-hand sidebar with information about who you are corresponding with.'
    h3 ->
      t 'Features to enable in '
      a href: 'about:flags', ->
        'about:flags'
    ul ->
    	li 'Tab Overview'
    	li 'GPU Accelerated Compositing'
    	li 'Print Preview'
    	li 'Web Page Prerendering -> Always Enabled'
    	li 'Confirm to Quit'
    	li 'Click to play'
    	li 'Enable better omnibox history matching'
