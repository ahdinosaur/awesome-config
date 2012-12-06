terminal = os.getenv("HOME") .. '/bin/term' -- can be app in path, or full path e.g. /usr/bin/xterm
editor = "vim"

altkey = "Mod1"
modkey = "Mod4" -- your windows/apple key

wallpaper_dir = os.getenv("HOME") .. "/wallpapers/" -- grabs a random bg

taglist_numbers = "arabic" -- we support arabic (1,2,3...),
-- arabic, chinese, {east|persian}_arabic, roman, thai, random

cpugraph_enable = true -- show CPU graph
cputext_format = " $1%" -- %1 average cpu, %[2..] every other thread individually

membar_enable = true -- show memory bar
memtext_format = " $1%" -- %1 percentage, %2 used %3 total %4 free

date_format = "%a %m/%d/%Y %l:%M%p" -- refer to http://en.wikipedia.org/wiki/Date_(Unix) specifiers

networks = {'eth0', 'wlan0'} -- Add your devices network interface here netwidget, only show one that works
