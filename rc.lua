-- {{{ License
--
-- Awesome configuration, using awesome 3.4.10 on Ubuntu 11.10
--   * Tony N <tony@git-pull.com>
--
-- Personalized and extended by
--   * Michael W <dinosaur@riseup.net>
--
-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- based off Adrian C. <anrxc@sysphere.org>'s rc.lua
-- }}}


-- {{{ Libraries
local awful = require("awful")
local awful_rules = require("awful.rules")
local awful_autofocus = require("awful.autofocus")
local naughty = require("naughty")
local beautiful = require("beautiful")
local wibox = require("wibox")
-- User libraries
local vicious = require("vicious") -- ./vicious
local helpers = require("helpers") -- helpers.lua
local bashets = require("bashets") -- http://awesome.naquadah.org/wiki/Bashets

local keydoc = require("keydoc")
-- }}}

-- {{{ Default configuration

terminal = os.getenv("HOME") .. '/bin/term' -- can be app in path, or full path e.g. /usr/bin/xterm
editor = "vim"
web_browser = "firefox"

altkey = "Mod1"
modkey = "Mod4" -- your windows/apple key

wallpaper_dir = os.getenv("HOME") .. "/images/wallpapers" -- grabs a random bg

taglist_numbers = "arabic" -- we support arabic (1,2,3...),
-- arabic, chinese, {east|persian}_arabic, roman, thai, random

cpugraph_enable = true -- show CPU graph
cputext_format = " $1%" -- %1 average cpu, %[2..] every other thread individually

membar_enable = true -- show memory bar
memtext_format = " $1%" -- %1 percentage, %2 used %3 total %4 free

date_format = "%a %m/%d/%Y %l:%M%p" -- refer to http://en.wikipedia.org/wiki/Date_(Unix) specifiers

networks = {'eth0', 'wlan0'} -- Add your devices network interface here netwidget, only show one that works

-- Create personal.lua in this same directory to override these defaults
require_safe('personal')

-- }}}

-- {{{ Variable definitions
local wallpaper_cmd = "find " .. wallpaper_dir .. " -type f -name '*.jpg'  -print0 | shuf -n1 -z | xargs -0 feh --bg-scale"
local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Beautiful theme
beautiful.init(awful.util.getdir("config") .. "/themes/zhongguo/zhongguo.lua")

-- {{{ Main Menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor .. " " .. awesome.conffile },
   { "reload", awesome.restart },
   { "quit", awesome.quit },
   { "reboot", "reboot" },
   { "shutdown", "shutdown" }
}

appsmenu = {
   { "firefox", "firefox" },
   { "thunar", "thunar" },
   { "htop", terminal .. " -e htop" },
}

gamesmenu = {
   { "warsow", "warsow" },
   { "nexuiz", "nexuiz" },
   { "xonotic", "xonotic" },
   { "openarena", "openarena" },
   { "alienarena", "alienarena" },
   { "teeworlds", "teeworlds" },
   { "frozen-bubble", "frozen-bubble" },
   { "warzone2100", "warzone2100" },
   { "wesnoth", "wesnoth" },
   { "supertuxkart", "supertuxkart" },
   { "xmoto" , "xmoto" },
   { "flightgear", "flightgear" },
   { "snes9x" , "snes9x" },

}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu },
                                    { "apps", appsmenu },
				    { "games", gamesmenu },
                                    { "terminal", terminal },
				    { "web browser", web_browser },
				    { "text editor", geditor }
                                  }
                        })

-- Window management layouts
layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.max,
  awful.layout.suit.magnifier,
  awful.layout.suit.floating
}
-- }}}

-- {{{ Tags

-- Taglist numerals
taglist_numbers_langs = { 'arabic', 'chinese', 'east_arabic', 'persian_arabic', }
taglist_numbers_sets = {
	arabic={ 1, 2, 3, 4, 5, 6, 7, 8, 9 },
	chinese={"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"},
	east_arabic={'١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'}, -- '٠' 0
	persian_arabic={'٠', '١', '٢', '٣', '۴', '۵', '۶', '٧', '٨', '٩'},
	roman={'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'},
	thai={'๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙', '๑๐'},
}
-- }}}

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
      --tags[s] = awful.tag({"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}, s, layouts[1])
      --tags[s] = awful.tag(taglist_numbers_sets[taglist_numbers], s, layouts[1])
	if taglist_numbers == 'random' then
		math.randomseed(os.time())
		local taglist = taglist_numbers_sets[taglist_numbers_langs[math.random(table.getn(taglist_numbers_langs))]]
		tags[s] = awful.tag(taglist, s, layouts[1])
	else
		tags[s] = awful.tag(taglist_numbers_sets[taglist_numbers], s, layouts[1])
	end
    --tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}


-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = wibox.widget.imagebox
separator:set_image(beautiful.widget_sep)

spacer = wibox.widget.textbox
spacer.width = 3
-- }}}

-- {{{ CPU usage

-- cpu icon
cpuicon = wibox.widget.imagebox
cpuicon:set_image(beautiful.widget_cpu)

-- check for cpugraph_enable == true in config
if cpugraph_enable then
	-- Initialize widget
	cpugraph  = awful.widget.graph()

	-- Graph properties
	cpugraph:set_width(40):set_height(16)
	cpugraph:set_background_color(beautiful.fg_off_widget)
	cpugraph:set_gradient_angle(0):set_gradient_colors({
	   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
	})

	-- Register graph widget
	vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
end

-- cpu text widget
cpuwidget = wibox.widget.textbox -- initialize
vicious.register(cpuwidget, vicious.widgets.cpu, cputext_format, 3) -- register

-- temperature
tzswidget = wibox.widget.textbox
vicious.register(tzswidget, vicious.widgets.thermal,
	function (widget, args)
		if args[1] > 0 then
			tzfound = true
			return " " .. args[1] .. "C°"
		else return "" 
		end
	end
	, 19, "thermal_zone0")

-- }}}


-- {{{ Battery state

-- Initialize widget
batwidget = wibox.widget.textbox
baticon = wibox.widget.imagebox

-- Register widget
vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			baticon:set_image(beautiful.widget_bat)
			return "<span color='white'>".. args[2] .. "%</span>"
		end
	end, 61, "BAT0"
)
-- }}}


-- {{{ Memory usage

-- icon
memicon = wibox.widget.imagebox
memicon:set_image(beautiful.widget_mem)

if membar_enable then
	-- Initialize widget
	membar = awful.widget.progressbar()
	-- Pogressbar properties
	membar:set_vertical(true):set_ticks(true)
	membar:set_height(16):set_width(8):set_ticks_size(2)
	membar:set_background_color(beautiful.fg_off_widget)
	membar:set_gradient_colors({ beautiful.fg_widget,
	   beautiful.fg_center_widget, beautiful.fg_end_widget
	}) -- Register widget
	vicious.register(membar, vicious.widgets.mem, "$1", 13)
end

-- mem text output
memtext = wibox.widget.textbox
vicious.register(memtext, vicious.widgets.mem, memtext_format, 13)
-- }}}

-- {{{ File system usage
fsicon = wibox.widget.imagebox
fsicon:set_image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  r = awful.widget.progressbar(), s = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(16):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
     beautiful.fg_center_widget, beautiful.fg_end_widget
  }) -- Register buttons
  w.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("dolphin", false) end)
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",            599)
vicious.register(fs.s, vicious.widgets.fs, "${/media/files used_p}", 599)
-- }}}

-- {{{ Network usage
function print_net(name, down, up)
	return '<span color="'
	.. beautiful.fg_netdn_widget ..'">' .. down .. '</span> <span color="'
	.. beautiful.fg_netup_widget ..'">' .. up  .. '</span>'
end

dnicon = wibox.widget.imagebox
upicon = wibox.widget.imagebox

-- Initialize widget
netwidget = wibox.widget.textbox
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
	function (widget, args)
		for _,device in pairs(networks) do
			if tonumber(args["{".. device .." carrier}"]) > 0 then
				netwidget.found = true
				dnicon:set_image(beautiful.widget_net)
				upicon:set_image(beautiful.widget_netup)
				return print_net(device, args["{"..device .." down_kb}"], args["{"..device.." up_kb}"])
			end
		end
	end, 3)
-- }}}



-- {{{ Volume level
volicon = wibox.widget.imagebox
volicon:set_image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = wibox.widget.textbox
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(16):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "PCM")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "PCM")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () sexec("alsamixer") end),
   awful.button({ }, 4, function () exec("amixer -q set PCM 2dB+", false) vicious.force({volbar, volwidget}) end),
   awful.button({ }, 5, function () exec("amixer -q set PCM 2dB-", false) vicious.force({volbar, volwidget}) end)
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())
-- }}}

-- {{{ Date and time
dateicon = wibox.widget.imagebox
dateicon:set_image(beautiful.widget_date)
-- Initialize widget
datewidget = wibox.widget.textbox
-- Register widget
vicious.register(datewidget, vicious.widgets.date, date_format, 61)
-- }}}

-- {{{ mpd

if whereis_app('curl') and whereis_app('mpd') then
	mpdwidget = widget({ type = "textbox" })
	vicious.register(mpdwidget, vicious.widgets.mpd,
		function (widget, args)
			if args["{state}"] == "Stop" or args["{state}"] == "Pause" or args["{state}"] == "N/A"
				or (args["{Artist}"] == "N/A" and args["{Title}"] == "N/A") then return ""
			else return '<span color="white">музыка:</span> '..
			     args["{Artist}"]..' - '.. args["{Title}"]
			end
		end
	)
end

-- }}}

-- {{{
-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { "us", "colemak", "de" }
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current] .. " ")
kbdcfg.switch = function ()
   kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
   local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
   kbdcfg.widget:set_text(t)
   os.execute( kbdcfg.cmd .. t )
end

-- Mouse bindings
kbdcfg.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () kbdcfg.switch() end)
))
-- }}}


-- {{{ System tray
systray = wibox.widget.systray
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
    awful.button({ },        1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, awful.client.toggletag),
    awful.button({ },        4, awful.tag.viewnext),
    awful.button({ },        5, awful.tag.viewprev
))


for s = 1, screen.count() do
    -- Create the taglist
    taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
    -- Create a promptbox
    promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create a layoutbox
    layoutbox[s] = awful.widget.layoutbox(s)
    layoutbox[s]:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
        awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
        awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))
    -- Create the wibox
    wibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 16,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_normal,
        border_width = beautiful.border_width
    })
    -- Add widgets to the wibox
    wibox[s].widgets = {
        {   taglist[s], layoutbox[s], separator, promptbox[s],
            mpdwidget and spacer, mpdwidget or nil, --kbdcfg.widget,
            ["layout"] = awful.widget.layout.horizontal.leftright
        },
        --s == screen.count() and systray or nil, -- show tray on last screen
        s == 1 and systray or nil, -- only show tray on first screen
        s == 1 and separator or nil, -- only show on first screen
        datewidget, dateicon,
        baticon.image and separator, batwidget, baticon or nil,
        separator, volwidget,  volbar.widget, volicon,
        dnicon.image and separator, upicon, netwidget, dnicon or nil,
        separator, fs.r.widget, fs.s.widget, fsicon,
        separator, memtext, membar_enable and membar.widget or nil, memicon,
        separator, tzfound and tzswidget or nil,
        cpugraph_enable and cpugraph.widget or nil, cpuwidget, cpuicon,
        ["layout"] = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Client bindings
clientbuttons = awful.util.table.join(
    awful.button({ },        1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    keydoc.group("focus"),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              "view previous tag"),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              "view next tag"),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              "view last accessed tag"),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end,
	"focus next window"),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end,
	"focus previous window"),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end,
              "show menu"),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              "jump to next screen"),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              "jump to previous screen"),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              "jump to urgent client"),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
	"focus previously unfocused window"),

    -- Layout manipulation
    keydoc.group("layout manipulation"),
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              "swap with next window"),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              "swap with previous window"),
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end,
              "increase master-width factor"),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end,
              "decrease master-width factor"),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster( 1)      end,
              "increase number of masters"),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster(-1)      end,
              "decrease number of masters"),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end,
              "increase number of columns"),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end,
              "decrease number of columns"),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end,
              "next layout"),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end,
              "previous layout"),
    awful.key({ modkey }, "b", function ()
         wibox[mouse.screen].visible = not wibox[mouse.screen].visible
    end, "remove awesome widget bar"),

    -- Standard program
    keydoc.group("programs"),
    awful.key({ modkey,	          }, "Return", function () exec(terminal) end,
              "start a terminal"),
    awful.key({ modkey,           }, "\\", function () exec(web_browser) end,
              "start a web browser"),
    awful.key({ modkey }, "r",     function () promptbox[mouse.screen]:run() end,
             "run program"),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end, "run lua code"),
    awful.key({ modkey, "Control" }, "r", awesome.restart, "restart awesome"),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, "quit awesome"),


    awful.key({ modkey }, "q", keydoc.display, "display this notifcation")
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "t",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Shift" }, "t", function (c)
        if   c.titlebar then awful.titlebar.remove(c)
           else awful.titlebar.add(c, { modkey = modkey }) end
    end),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
    { rule = { }, properties = {
      focus = true,      size_hints_honor = false,
      keys = clientkeys, buttons = clientbuttons,
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal }
    },
    { rule = { class = "ROX-Filer" },   properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Manage signal handler
client.connect_signal("manage", function (c, startup)
    -- Add titlebar to floaters, but remove those from rule callback
    if awful.client.floating.get(c)
    or awful.layout.get(c.screen) == awful.layout.suit.floating then
        if   c.titlebar then awful.titlebar.remove(c)
        else awful.titlebar.add(c, {modkey = modkey}) end
    end

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function (c)
        if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    -- Client placement
    if not startup then
        awful.client.setslave(c)

        if  not c.size_hints.program_position
        and not c.size_hints.user_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
-- }}}

-- {{{ Focus signal handlers
client.connect_signal("focus",   function (c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
-- }}}

x = 0

-- setup the timer
mytimer = timer { timeout = x }
mytimer:connect_signal("timeout", function()

  -- tell awsetbg to randomly choose a wallpaper from your wallpaper directory
  if file_exists(wallpaper_dir) and whereis_app('feh') then
	  os.execute(wallpaper_cmd)
  end
  -- stop the timer (we don't need multiple instances running at the same time)
  mytimer:stop()

  -- define the interval in which the next wallpaper change should occur in seconds
  -- (in this case anytime between 10 and 20 minutes)
  x = math.random( 600, 1200)

  --restart the timer
  mytimer.timeout = x
  mytimer:start()
end)

-- initial start when rc.lua is first run
mytimer:start()

require_safe('autorun')
