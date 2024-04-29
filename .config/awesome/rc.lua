-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
--Disable Notifications
naughty.suspend()
--naughty.config.defaults.timeout = 0
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Rounded Corners
local function set_shape(c)
    if not c.fullscreen and not c.maximized then
        c.shape = beautiful.client_shape_rounded
    else
        c.shape = gears.shape.rectangle
    end
end

client.connect_signal('request::manage', function(c)
      set_shape(c)
end)

client.connect_signal('request::border', function(c)
      set_shape(c)
end)

client.connect_signal('property::floating', function(c)
      set_shape(c)
end)

client.connect_signal('property::fullscreen', function(c)
      set_shape(c)
end)

client.connect_signal('property::maximized', function(c)
      set_shape(c)
end)

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    --awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock(" %l:%M:%S %p |  %a, %b %e, %Y ", 1, "America/New_York")
month_calendar = awful.widget.calendar_popup.month({start_sunday = true, bg = '#c0c0c0'})
month_calendar:attach( mytextclock, "tr" )

-- Debian Widget
myLogo = wibox.widget {
	    image = ".config/awesome/default/button.png",
	    widget = wibox.widget.imagebox
	}

	myLogo:connect_signal("button::release",
	    function()
		awful.spawn("rofi -show drun")
	    end
	)
	
-- Power Menu Widget
myPower = wibox.widget {
	    text = " ",
	    widget = wibox.widget.textbox
	}

    local myPower_tooltip = awful.tooltip
    {
        objects        = { myPower },
        timer_function = function()
            return io.popen("uptime -p | awk '{printf \"Uptime: %d Days, %d Hours, %d Minutes\", $2, $4, $6}'"):read("*a")
        end,
    }

	myPower:connect_signal("button::release", function(c, _, _, button)
		if button == 1 then
            awful.spawn("rofi -show power-menu -modi power-menu:rofi-power-menu")
	    end
    end)
	
--Weather Widget
myWeather = awful.widget.watch("curl wttr.in/?format=%c%t | awk '{printf \" %d\", $1}'", 600)

	myWeather:connect_signal("button::release",
	    function()
		awful.spawn("firefox-esr -new-tab https://www.weather.com/")
	    end
	)
	
-- Volume Widget
myVolume = wibox.widget {
    text   = "󰕾",
    widget = wibox.widget.textbox,
}

local myVolume_tooltip = awful.tooltip
{
    objects        = { myVolume },
    timer_function = function()
        return io.popen("pactl get-sink-volume 0 | awk '{printf \"%d%\", $5}' | sed 's/..$//'"):read("*a")
    end,
}
        
    myVolume:connect_signal("button::release", function(c, _, _, button)
        if button == 1 and c.text == "󰕾" then
            awful.spawn.easy_async_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            c.text = "󰝟"
        elseif button == 1 and c.text == "󰝟" then
            awful.spawn.easy_async_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
            c.text = "󰕾"
        elseif button == 4 then
            awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +1%")
        elseif button == 5 then
            awful.spawn.easy_async_with_shell("pactl set-sink-volume @DEFAULT_SINK@ -1%")
        end
    end)

-- Microphone Widget
myMic = wibox.widget {
    text   = "",
    widget = wibox.widget.textbox,
}

local myMic_tooltip = awful.tooltip
{
    objects        = { myMic },
    timer_function = function()
        return io.popen("pactl get-source-volume 0 | awk '{printf \"%d%\", $5}' | sed 's/..$//'"):read("*a")
    end,
}
        
    myMic:connect_signal("button::release", function(c, _, _, button)
        if button == 1 and c.text == "" then
            awful.spawn.easy_async_with_shell("pactl set-source-mute 0 toggle")
            c.text = ""
        elseif button == 1 and c.text == "" then
            awful.spawn.easy_async_with_shell("pactl set-source-mute 0 toggle")
            c.text = ""
        elseif button == 4 then
            awful.spawn.easy_async_with_shell("pactl set-source-volume 0 +1%")
        elseif button == 5 then
            awful.spawn.easy_async_with_shell("pactl set-source-volume 0 -1%")
        end
    end)

-- YouTube Widget
myYouTube = awful.widget.watch({"bash", "-c", "/usr/bin/python3 ~/.config/awesome/subscribers.py | awk '{printf \" %d\", $1}'"}, 600)

	myYouTube:connect_signal("button::release",
	    function()
		awful.spawn("firefox-esr -new-tab https://studio.youtube.com/")
	    end
	)

-- System Updates Widget
myUpdates = wibox.widget {
    text   = " ",
    widget = wibox.widget.textbox,
}

myUpdates:connect_signal("button::release", function(c, _, _, button)
    if button == 1 then
        awful.spawn.easy_async_with_shell("pkexec nala update")
    elseif button == 2 then
        awful.spawn.easy_async_with_shell("kitty --hold apt list --upgradable")
    elseif button == 3 then
        awful.spawn.easy_async_with_shell("kitty --hold sudo nala upgrade")
    end
end)

local myUpdates_tooltip = awful.tooltip
{
    objects        = { myUpdates },
    timer_function = function()
        return io.popen("apt list --upgradable | wc -l | awk '{printf \"%d Update(s) Available\", $1-1}'"):read("*a")
    end,
}

-- Internet Speed Widget
myNet = awful.widget.watch({"bash", "-c", "ifstat -i enp11s0 1s 1 | tail -n 1 | awk '{if ($1 < 1 && $2 < 1) {printf \" %.0fB  %.0fB \", $1*1000, $2*1000} else if ($1 >= 1000 || $2 >= 1000) {printf \" %.0fMB  %.0fMB \", $1/1000, $2/1000} else if ($1 >= 1000000 || $2 >= 1000000) {printf \" %.0fGB  %.0fGB \", $1/1000000, $2/1000000} else {printf \" %.0fKB  %.0fKB \", $1, $2}}'"}, 1)

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only()
                        if awful.tag.selected().name == "󰊠" then
                            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
                            awful.tag.selected().name = "󰮯"
                        end
                    end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen)
                        if awful.tag.selected().name == "󰊠" then
                            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
                            awful.tag.selected().name = "󰮯"
                        end
                    end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen)
                        if awful.tag.selected().name == "󰊠" then
                            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
                            awful.tag.selected().name = "󰮯"
                        end
                    end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "󰮯", "󰊠", "󰊠", "󰊠", "󰊠", "󰊠", "󰊠", "󰊠", "󰊠" }, s, awful.layout.layouts[2])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    
    -- Make sure you remove the default Mod4+Space and Mod4+Shift+Space
    -- keybindings before adding this.
    awful.keygrabber {
        start_callback = function() layout_popup.visible = true  end,
        stop_callback  = function() layout_popup.visible = false end,
        export_keybindings = true,
        release_event = 'release',
        stop_key = {'Escape', 'Super_L', 'Super_R'},
        keybindings = {
            {{ modkey          } , ' ' , function()
                awful.layout.set(gears.table.iterate_value(ll.layouts, ll.current_layout, 1))
            end},
            {{ modkey, 'Shift' } , ' ' , function()
                awful.layout.set(gears.table.iterate_value(ll.layouts, ll.current_layout, -1), nil)
            end},
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }
    

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
        --buttons = tasklist_buttons,
        style = {
        	align = "center",
        	tasklist_disable_icon = true,
        }
    }

    -- Create the wibox
    lc = function(cr,w,h) gears.shape.partially_rounded_rect(cr, w, h, true, false, false, true, 20) end
    rc = function(cr,w,h) gears.shape.partially_rounded_rect(cr, w, h, false, true, true, false, 20) end
    lrc = function(cr,w,h) gears.shape.partially_rounded_rect(cr, w, h, true, true, true, true, 20) end
    
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 35, ontop = false })

    widgetbg = "#c0c0c0"
    underlinebg = "#ffffff"
    bottomborder = 2

    -- Add widgets to the wibox
    s.mywibox:setup {
    {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            {{myWeather, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = lc, shape_clip = true},
	        {{wibox.widget.textbox(' | '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{myYouTube, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{wibox.widget.textbox(' | '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{awful.widget.watch({"bash", "-c", "vmstat 1 2 | tail -1 | awk '{printf \"  %d%\", 100-$15}'"}, 1), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{wibox.widget.textbox(' '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{awful.widget.watch({"bash", "-c", "free -m | grep \"Mem:\" | awk '{printf \" %d%\", $3/$2*100}'"}, 1), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{wibox.widget.textbox(' '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{awful.widget.watch({"bash", "-c", "df -H /dev/sda2 | grep \"/dev/sda2\" | awk '{printf \" %d%\", $5}'"}, 1), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{wibox.widget.textbox(' '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{myNet, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = rc, shape_clip = true},
        },
        { -- Middle widgets
            layout = wibox.layout.fixed.horizontal,
            {{myLogo, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = lc, shape_clip = true},
            {{s.mytaglist, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            --{{s.mylayoutbox, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            --{{s.mytasklist, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{myPower, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = rc, shape_clip = true},
	    },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            {{myUpdates, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = lc, shape_clip = true},
            {{wibox.widget.systray(), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{myVolume, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{myMic, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{wibox.widget.textbox(' | '), bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background},
            {{mytextclock, bottom = bottomborder, color = underlinebg, widget = wibox.container.margin,}, bg = widgetbg, widget = wibox.container.background, shape = rc, shape_clip = true},
        },
    },
        --bottom = 0, -- don't forget to increase wibar height
    	--color = "#ffffff",
        top = 10,
        left = 10,
        right = 10,
        bottom = 0,
    	widget = wibox.container.margin,
}
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext, function() 
        if awful.tag.selected().name == "󰊠" then
            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
            awful.tag.selected().name = "󰮯"
        end
    end),
    awful.button({ }, 5, awful.tag.viewprev, function() 
        if awful.tag.selected().name == "󰊠" then
            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
            awful.tag.selected().name = "󰮯"
        end
    end)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({}, "Print", function () awful.spawn("flameshot gui") end,
              {description = "take screenshot", group = "launcher"}),
    awful.key({ modkey,           }, "d", function () awful.spawn("rofi -show run") end,
              {description = "open Rofi", group = "launcher"}),
    awful.key({ "Mod1",           }, "Tab", function () awful.spawn("rofi -show window") end,
              {description = "open window switcher", group = "launcher"}),
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    --awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              --{description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),
              
-- Show/Hide Wibar
awful.key({ modkey }, "b",
        function ()
            local myscreen = awful.screen.focused()
            if myscreen.mywibox.visible then
                myscreen.mywibox.visible = false
            else 
                myscreen.mywibox.visible = true
            end 
        end,
        {description = "show/hide wibar", group = "launcher"})
        
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    --awful.key({ modkey,           }, "t",      function (c) c.sticky = not c.sticky            end,
              --{description = "toggle sticky", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                        if awful.tag.selected().name == "󰊠" then
                            awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
                            awful.tag.selected().name = "󰮯"
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    --{ rule_any = {type = { "normal", "dialog" }
    { rule_any = {type = { "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Rules For Autostarting Programs
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "" } },
    -- { rule = { class = "Discord" },
    --   properties = { screen = 1, tag = "" } }, 
}

----Turn on titlebar when client is floating
--client.connect_signal("property::floating", function (c)
--    if c.floating then
--        awful.titlebar.show(c)
--    else
--        awful.titlebar.hide(c)
--    end
--end)
--
----Turn on titlebar when layout is floating
--awful.tag.attached_connect_signal(nil, "property::layout", function (t)
--  local float = t.layout.name == "floating"
--  for _,c in pairs(t:clients()) do
--    c.floating = float
--  end
--end)

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 24, bg_normal = "#c0c0c0", fg_normal = "#000000"}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            align = "right",
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
    if awful.tag.selected().name == "󰊠" then
        awful.tag.find_by_name(nil, "󰮯").name = "󰊠"
        awful.tag.selected().name = "󰮯"
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--Autostart Applications
awful.spawn.once("xset -dpms")
awful.spawn.once("xset s off")
awful.spawn.once("xset s noblank")

awful.spawn.once("exec /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")

awful.spawn.once("pactl set-sink-volume @DEFAULT_SINK@ 100%")

awful.spawn.once("nm-applet")
awful.spawn.once("firefox-esr")
awful.spawn.once("discord")
