local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

math.randomseed(os.time())

-- Appearance -----------------------------------------------------------------

local FONT = wezterm.font("JetBrainsMono Nerd Font")
local FONT_SIZE = 11.0

config.color_scheme = "Tokyo Night"
config.colors = {
	background = "#0b1020",
	foreground = "#c0caf5",
	cursor_bg = "#7dcfff",
	cursor_border = "#7dcfff",
	cursor_fg = "#0b1020",
	selection_bg = "#283457",
	selection_fg = "#c0caf5",
	tab_bar = {
		background = "#080d19",
		active_tab = { bg_color = "#1a2440", fg_color = "#c0caf5" },
		inactive_tab = { bg_color = "#0f1629", fg_color = "#737da1" },
		inactive_tab_hover = { bg_color = "#1e2842", fg_color = "#c0caf5" },
	},
}

config.font = FONT
config.font_size = FONT_SIZE
config.line_height = 1.20
config.default_cursor_style = "SteadyBar"

config.window_decorations = "NONE"
config.show_new_tab_button_in_tab_bar = false
config.window_frame = {
	font = FONT,
	font_size = FONT_SIZE,
	active_titlebar_bg = "#080d19",
	inactive_titlebar_bg = "#080d19",
}
config.window_padding = { left = 18, right = 18, top = 14, bottom = 14 }
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.72 }

config.command_palette_bg_color = "#0f1629"
config.command_palette_fg_color = "#c0caf5"
config.command_palette_font_size = FONT_SIZE
config.command_palette_rows = 14

-- Per-tab wallpapers ---------------------------------------------------------
-- Each tab gets a random image from WALLPAPER_DIRS (searched recursively).

local WALLPAPER_DIRS = {
	wezterm.home_dir .. "/Projects/Wallpapers",
	wezterm.home_dir .. "/Projects/Wallpaper",
}

local WALLPAPER_HSB = { hue = 1.0, saturation = 0.95, brightness = 0.55 }
local WALLPAPER_DIM = 0.32

local function is_image(path)
	local lower = path:lower()
	return lower:match("%.jpe?g$")
		or lower:match("%.png$")
		or lower:match("%.webp$")
		or lower:match("%.gif$")
		or lower:match("%.bmp$")
end

local function collect_images(dir, files)
	local ok, entries = pcall(wezterm.read_dir, dir)
	if not ok or not entries then
		return
	end
	for _, path in ipairs(entries) do
		if is_image(path) then
			table.insert(files, path)
		else
			collect_images(path, files)
		end
	end
end

local WALLPAPERS = {}
for _, dir in ipairs(WALLPAPER_DIRS) do
	collect_images(dir, WALLPAPERS)
end

-- Pick a random wallpaper, avoiding an immediate repeat when possible.
local function pick_wallpaper()
	local last = wezterm.GLOBAL.last_wallpaper
	local path
	for _ = 1, 8 do
		path = WALLPAPERS[math.random(#WALLPAPERS)]
		if path ~= last then
			break
		end
	end
	wezterm.GLOBAL.last_wallpaper = path
	return path
end

local function wallpaper_for_tab(tab_id)
	local id = tostring(tab_id)
	local map = wezterm.GLOBAL.tab_wallpapers or {}
	if not map[id] then
		map[id] = pick_wallpaper()
		wezterm.GLOBAL.tab_wallpapers = map
	end
	return map[id]
end

local function background_layers(path)
	return {
		{
			source = { File = path },
			width = "Cover",
			height = "Cover",
			horizontal_align = "Center",
			vertical_align = "Middle",
			repeat_x = "NoRepeat",
			repeat_y = "NoRepeat",
			hsb = WALLPAPER_HSB,
		},
		{
			source = { Color = "#07090f" },
			width = "100%",
			height = "100%",
			opacity = WALLPAPER_DIM,
		},
	}
end

local function apply_tab_wallpaper(window)
	if #WALLPAPERS == 0 then
		return
	end
	local tab = window:active_tab()
	if not tab then
		return
	end
	local path = wallpaper_for_tab(tab:tab_id())
	local overrides = window:get_config_overrides() or {}
	local current = overrides.background
	-- Skip when unchanged: set_config_overrides triggers a full config reload.
	if
		current
		and current[1].source.File == path
		and current[1].hsb.brightness == WALLPAPER_HSB.brightness
		and current[2].opacity == WALLPAPER_DIM
	then
		return
	end
	overrides.background = background_layers(path)
	window:set_config_overrides(overrides)
end

-- Tab colors -----------------------------------------------------------------
-- The chosen color is stored inside the tab title as MARK .. bg .. MARK .. title,
-- so it survives renames and needs no extra state.

local TAB_COLORS = {
	{ key = "r", digit = "1", bg = "#d64545" }, -- red
	{ key = "g", digit = "2", bg = "#2f9e6b" }, -- green
	{ key = "b", digit = "3", bg = "#3b6fe0" }, -- blue
	{ key = "v", digit = "4", bg = "#b05ae1" }, -- violet
	{ key = "y", digit = "5", bg = "#f0d040" }, -- yellow
	{ key = "o", digit = "6", bg = "#ff7a1a" }, -- orange
	{ key = "c", digit = "7", bg = "#2ec4d6" }, -- cyan
	{ key = "p", digit = "8", bg = "#ee6fa8" }, -- pink
	{ key = "w", digit = "9", bg = "#f4f1ea" }, -- white
	{ key = "m", digit = "0", bg = "#6ed9a0" }, -- mint
}

local TITLE_MARK = "\x1e"

local function encode_title(visible, spec)
	visible = visible or ""
	if not spec then
		return visible
	end
	return TITLE_MARK .. spec.bg .. TITLE_MARK .. visible
end

local function decode_title(raw)
	raw = raw or ""
	if raw:sub(1, 1) ~= TITLE_MARK then
		return raw, nil
	end
	local sep = raw:find(TITLE_MARK, 2, true)
	if not sep or sep == 2 then
		return raw, nil
	end
	return raw:sub(sep + 1), { bg = raw:sub(2, sep - 1) }
end

-- set_title only notifies the tab bar when the string changes, so force a change.
local function paint_tab_title(tab, title)
	if tab:get_title() == title then
		tab:set_title(title .. "\u{200b}")
	end
	tab:set_title(title)
end

-- Status bar -----------------------------------------------------------------

local color_hint_parts = {}
for _, spec in ipairs(TAB_COLORS) do
	table.insert(color_hint_parts, spec.digit .. spec.key)
end
local COLOR_HINT = " " .. table.concat(color_hint_parts, " ") .. "   n random   x clear "

local function current_folder(pane)
	local uri = pane:get_current_working_dir()
	local path = uri and (uri.file_path or tostring(uri)) or ""
	path = path:gsub("^file://[^/]*", ""):gsub("/+$", "")
	return path:match("([^/]+)$") or "~"
end

local function render_status(window, pane)
	local mode = window:active_key_table()
	if mode == "tab_color" then
		window:set_right_status(wezterm.format({
			{ Foreground = { Color = "#7dcfff" } },
			{ Text = COLOR_HINT },
		}))
		return
	end

	local elements = {
		{ Foreground = { Color = "#737da1" } },
		{ Text = "  󰉋  " .. current_folder(pane) .. "  " },
	}
	if mode then
		table.insert(elements, { Foreground = { Color = "#bb9af7" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = "  " .. mode:upper():gsub("_", " ") .. "  " })
	end
	window:set_right_status(wezterm.format(elements))
end

-- Events ---------------------------------------------------------------------

wezterm.on("update-status", function(window, pane)
	apply_tab_wallpaper(window)
	render_status(window, pane)
end)

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
	local visible, spec = decode_title(tab.tab_title)
	local title = visible ~= "" and visible or (tab.active_pane and tab.active_pane.title) or ""
	local index = tostring(tab.tab_index + 1)
	local chrome_width = 9 + #index
	title = wezterm.truncate_right(title, math.max(1, (tonumber(max_width) or 32) - chrome_width))

	local background = tab.is_active and "#1a2440" or "#0f1629"
	if hover and not tab.is_active then
		background = "#1e2842"
	end
	local foreground = tab.is_active and "#c0caf5" or "#737da1"
	local accent = spec and spec.bg or (tab.is_active and "#7dcfff" or "#39436a")

	return {
		{ Background = { Color = background } },
		{ Foreground = { Color = accent } },
		{ Text = "  ●  " },
		{ Foreground = { Color = foreground } },
		{ Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
		{ Text = index .. " " .. title .. "   " },
	}
end)

-- Actions --------------------------------------------------------------------

-- spec is a TAB_COLORS entry, "random", or "clear".
local function color_action(spec)
	return wezterm.action_callback(function(window, pane)
		local tab = window:active_tab()
		if not tab then
			return
		end
		local chosen = spec
		if spec == "random" then
			chosen = TAB_COLORS[math.random(#TAB_COLORS)]
		elseif spec == "clear" then
			chosen = nil
		end
		local visible = decode_title(tab:get_title())
		paint_tab_title(tab, encode_title(visible, chosen))
		render_status(window, pane)
	end)
end

local enter_tab_color = wezterm.action_callback(function(window, pane)
	window:perform_action(
		act.ActivateKeyTable({
			name = "tab_color",
			timeout_milliseconds = 4000,
			one_shot = true,
			replace_current = true,
			until_unknown = true,
		}),
		pane
	)
	render_status(window, pane)
end)

local rename_tab = act.PromptInputLine({
	description = "Rename tab",
	action = wezterm.action_callback(function(window, _pane, line)
		local tab = window:active_tab()
		if line == nil or not tab then
			return
		end
		local _, spec = decode_title(tab:get_title())
		paint_tab_title(tab, encode_title(line, spec))
	end),
})

-- Keys -----------------------------------------------------------------------
-- Ctrl+Shift is used for pane/tab actions to stay clear of niri's Super binds.
-- Leader is Ctrl+T; leader binds also accept Ctrl held down (Ctrl+T, Ctrl+R).
--
--   Ctrl+T r            rename tab (keeps its color)
--   Ctrl+T 0-9 / n / x  set tab color / random / clear
--   Ctrl+T c <key>      color mode: letter or digit from TAB_COLORS, n, x
--   Ctrl+Shift+T        new tab; press c within 1s to enter color mode

local function bind(list, key, mods, action)
	table.insert(list, { key = key, mods = mods, action = action })
end

local function bind_leader(list, key, action)
	bind(list, key, "LEADER", action)
	bind(list, key, "LEADER|CTRL", action)
end

-- Inside the color key table, accept the key with any Ctrl/Shift combination.
local function bind_color_key(list, key, action)
	bind(list, key, nil, action)
	bind(list, key, "CTRL", action)
	if key:match("%a") then
		bind(list, key:upper(), "SHIFT", action)
		bind(list, key:upper(), "CTRL|SHIFT", action)
	else
		bind(list, key, "CTRL|SHIFT", action)
	end
end

config.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	{ key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
	{ key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "D", mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "S", mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	-- Ctrl+Shift+X is WezTerm's copy mode, so close lives on Q.
	{ key = "Q", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "A", mods = "CTRL|SHIFT", action = act.SendString("rai\r") },
	{
		key = "T",
		mods = "CTRL|SHIFT",
		action = act.Multiple({
			act.SpawnTab("CurrentPaneDomain"),
			act.ActivateKeyTable({
				name = "after_new_tab",
				timeout_milliseconds = 1000,
				one_shot = false,
				until_unknown = true,
			}),
		}),
	},
	{ key = "l", mods = "LEADER", action = act.ShowLauncher },
}
bind_leader(config.keys, "c", enter_tab_color)
bind_leader(config.keys, "r", rename_tab)

local color_keys = {}
for _, spec in ipairs(TAB_COLORS) do
	local action = color_action(spec)
	bind_color_key(color_keys, spec.key, action)
	bind_color_key(color_keys, spec.digit, action)
	bind_leader(config.keys, spec.digit, action)
end

local random_color = color_action("random")
local clear_color = color_action("clear")
bind_color_key(color_keys, "n", random_color)
bind_color_key(color_keys, "x", clear_color)
bind(color_keys, "Backspace", nil, clear_color)
bind_leader(config.keys, "n", random_color)
bind_leader(config.keys, "x", clear_color)

config.key_tables = {
	after_new_tab = {
		{ key = "c", action = enter_tab_color },
		{ key = "c", mods = "CTRL|SHIFT", action = enter_tab_color },
	},
	tab_color = color_keys,
}

config.launch_menu = {
	{ label = "dev-ai shell (rai)", args = { "bash", "-ic", "rai" } },
}

return config
