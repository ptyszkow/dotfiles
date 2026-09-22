local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

math.randomseed(os.time())

-- appearance: cinematic midnight palette with restrained neon accents
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
		new_tab = { bg_color = "#080d19", fg_color = "#737da1" },
		new_tab_hover = { bg_color = "#1e2842", fg_color = "#7dcfff" },
	},
}
config.window_background_opacity = 1.0
config.macos_window_background_blur = 20
config.window_decorations = "NONE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.show_new_tab_button_in_tab_bar = false
config.status_update_interval = 1000
config.window_frame = {
	font = wezterm.font("JetBrainsMono Nerd Font"),
	font_size = 11.0,
	active_titlebar_bg = "#080d19",
	inactive_titlebar_bg = "#080d19",
}
config.window_padding = {
	left = 18,
	right = 18,
	top = 14,
	bottom = 14,
}
config.inactive_pane_hsb = {
	saturation = 0.85,
	brightness = 0.72,
}

-- text
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0
config.line_height = 1.20

-- command palette: compact, readable, and matched to the terminal chrome
config.command_palette_bg_color = "#0f1629"
config.command_palette_fg_color = "#c0caf5"
config.command_palette_font = wezterm.font("JetBrainsMono Nerd Font")
config.command_palette_font_size = 11.0
config.command_palette_rows = 14

-- cursor
config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0

local WALLPAPER_DIRS = {
	wezterm.home_dir .. "/Projects/Wallpapers",
	wezterm.home_dir .. "/Projects/Wallpaper",
}

local IMAGE_PATTERNS = {
	"/*.jpg",
	"/*.jpeg",
	"/*.png",
	"/*.webp",
	"/*.gif",
	"/*.bmp",
	"/*/*.jpg",
	"/*/*.jpeg",
	"/*/*.png",
	"/*/*.webp",
	"/*/*.gif",
	"/*/*.bmp",
}

-- Basic tab colors. Digit is Ctrl+T then that key. Letter is Ctrl+T, c, then the letter.
local TAB_COLORS = {
	{ key = "r", digit = "1", name = "red", bg = "#d64545", fg = "#fff5f5" },
	{ key = "g", digit = "2", name = "green", bg = "#2f9e6b", fg = "#f3fff8" },
	{ key = "b", digit = "3", name = "blue", bg = "#3b6fe0", fg = "#f4f7ff" },
	{ key = "v", digit = "4", name = "violet", bg = "#b05ae1", fg = "#1a1020" },
	{ key = "y", digit = "5", name = "yellow", bg = "#f0d040", fg = "#1a1408" },
	{ key = "o", digit = "6", name = "orange", bg = "#ff7a1a", fg = "#2a1004" },
	{ key = "c", digit = "7", name = "cyan", bg = "#2ec4d6", fg = "#042026" },
	{ key = "p", digit = "8", name = "pink", bg = "#ee6fa8", fg = "#2a1020" },
	{ key = "w", digit = "9", name = "white", bg = "#f4f1ea", fg = "#1a1a1a" },
	{ key = "m", digit = "0", name = "mint", bg = "#6ed9a0", fg = "#042214" },
}

local TITLE_MARK = "\x1e"

local function encode_title(visible, spec)
	visible = visible or ""
	if not spec then
		return visible
	end
	return TITLE_MARK .. spec.bg .. TITLE_MARK .. spec.fg .. TITLE_MARK .. visible
end

local function decode_title(raw)
	raw = raw or ""
	if raw:sub(1, 1) ~= TITLE_MARK then
		return raw, nil
	end
	local first = raw:find(TITLE_MARK, 2, true)
	local second = first and raw:find(TITLE_MARK, first + 1, true)
	if not first or not second then
		return raw, nil
	end
	local bg = raw:sub(2, first - 1)
	local fg = raw:sub(first + 1, second - 1)
	if bg == "" or fg == "" then
		return raw, nil
	end
	return raw:sub(second + 1), { bg = bg, fg = fg }
end

local color_hint_parts = {}
for _, spec in ipairs(TAB_COLORS) do
	table.insert(color_hint_parts, spec.digit .. spec.key)
end
local COLOR_HINT = " " .. table.concat(color_hint_parts, " ") .. "   n random   x clear "

local function is_image(path)
	local lower = path:lower()
	return lower:match("%.jpe?g$")
		or lower:match("%.png$")
		or lower:match("%.webp$")
		or lower:match("%.gif$")
		or lower:match("%.bmp$")
end

local function collect_from_dir(dir, acc)
	local ok, entries = pcall(wezterm.read_dir, dir)
	if not ok or not entries then
		return acc
	end
	for _, path in ipairs(entries) do
		if is_image(path) then
			table.insert(acc, path)
		else
			collect_from_dir(path, acc)
		end
	end
	return acc
end

local function collect_wallpapers()
	local files = {}
	local seen = {}
	for _, dir in ipairs(WALLPAPER_DIRS) do
		for _, pattern in ipairs(IMAGE_PATTERNS) do
			local ok, matches = pcall(wezterm.glob, dir .. pattern)
			if ok and matches then
				for _, path in ipairs(matches) do
					if not seen[path] then
						seen[path] = true
						table.insert(files, path)
					end
				end
			end
		end
		collect_from_dir(dir, files)
	end
	local unique = {}
	seen = {}
	for _, path in ipairs(files) do
		if not seen[path] then
			seen[path] = true
			table.insert(unique, path)
		end
	end
	return unique
end

local WALLPAPERS = collect_wallpapers()

local function pick_wallpaper()
	if #WALLPAPERS == 0 then
		return nil
	end
	local last = wezterm.GLOBAL.last_wallpaper
	local path
	for _ = 1, 8 do
		path = WALLPAPERS[math.random(#WALLPAPERS)]
		if path ~= last or #WALLPAPERS == 1 then
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
			hsb = { hue = 1.0, saturation = 0.95, brightness = 0.55 },
		},
		{
			source = { Color = "#07090f" },
			width = "100%",
			height = "100%",
			opacity = 0.32,
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
	if not path then
		return
	end
	local overrides = window:get_config_overrides() or {}
	local layers = background_layers(path)
	local current = overrides.background
	local current_path = current and current[1] and current[1].source and current[1].source.File
	local current_brightness = current and current[1] and current[1].hsb and current[1].hsb.brightness
	local current_overlay = current and current[2] and current[2].opacity
	if
		current_path == path
		and current_brightness == layers[1].hsb.brightness
		and current_overlay == layers[2].opacity
	then
		return
	end
	overrides.background = layers
	overrides.window_background_opacity = 1.0
	window:set_config_overrides(overrides)
end

local function current_folder(pane)
	local uri = pane:get_current_working_dir()
	local path = uri and (uri.file_path or tostring(uri)) or ""
	path = path:gsub("^file://[^/]*", ""):gsub("/+$", "")
	return path:match("([^/]+)$") or "~"
end

local function render_status(window, pane)
	if wezterm.GLOBAL.color_hint then
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
	local mode = window:active_key_table()
	if mode then
		table.insert(elements, { Foreground = { Color = "#bb9af7" } })
		table.insert(elements, { Attribute = { Intensity = "Bold" } })
		table.insert(elements, { Text = "  " .. mode:upper():gsub("_", " ") .. "  " })
	end
	window:set_right_status(wezterm.format(elements))
end

local function paint_tab_title(tab, title)
	local current = tab:get_title() or ""
	if current ~= title then
		tab:set_title(title)
		return
	end
	-- set_title only notifies the tab bar when the string changes.
	tab:set_title(title .. "\u{200b}")
	tab:set_title(title)
end

local function apply_tab_color(window, pane, spec)
	local tab = window:active_tab()
	if not tab then
		return
	end
	if spec == "random" then
		spec = TAB_COLORS[math.random(#TAB_COLORS)]
	elseif spec == "clear" then
		spec = nil
	end
	local visible = decode_title(tab:get_title())
	paint_tab_title(tab, encode_title(visible, spec))
	wezterm.GLOBAL.color_hint = false
	render_status(window, pane)
end

local function enter_tab_color(window, pane)
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
	wezterm.GLOBAL.color_hint = true
	render_status(window, pane)
end

wezterm.on("update-status", function(window, pane)
	apply_tab_wallpaper(window)
	if wezterm.GLOBAL.color_hint and window:active_key_table() ~= "tab_color" then
		wezterm.GLOBAL.color_hint = false
	end
	render_status(window, pane)
end)

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _config, hover, max_width)
	local visible, spec = decode_title(tab.tab_title)
	local title = visible
	if not title or title == "" then
		title = (tab.active_pane and tab.active_pane.title) or ""
	end
	local limit = tonumber(max_width) or 32
	local index = tostring(tab.tab_index + 1)
	local chrome_width = 9 + #index
	title = wezterm.truncate_right(title, math.max(1, limit - chrome_width))
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

local function color_action(spec)
	return wezterm.action_callback(function(window, pane)
		apply_tab_color(window, pane, spec)
	end)
end

local function bind_key(list, key, mods, action)
	local entry = { key = key, action = action }
	if mods then
		entry.mods = mods
	end
	table.insert(list, entry)
end

local color_letter_keys = {}
local leader_color_keys = {}

local function bind_color_key(list, key, action)
	bind_key(list, key, nil, action)
	bind_key(list, key, "CTRL", action)
	bind_key(list, key, "CTRL|SHIFT", action)
end

for _, spec in ipairs(TAB_COLORS) do
	local chosen = spec
	local action = color_action(chosen)
	bind_color_key(color_letter_keys, chosen.key, action)
	bind_color_key(color_letter_keys, chosen.digit, action)
	bind_key(color_letter_keys, string.upper(chosen.key), "SHIFT", action)
	bind_key(color_letter_keys, string.upper(chosen.key), "CTRL|SHIFT", action)
	bind_key(leader_color_keys, chosen.digit, "LEADER", action)
	bind_key(leader_color_keys, chosen.digit, "LEADER|CTRL", action)
end

local random_color = color_action("random")
local clear_color = color_action("clear")
bind_color_key(color_letter_keys, "n", random_color)
bind_color_key(color_letter_keys, "x", clear_color)
bind_key(color_letter_keys, "N", "SHIFT", random_color)
bind_key(color_letter_keys, "N", "CTRL|SHIFT", random_color)
bind_key(color_letter_keys, "X", "SHIFT", clear_color)
bind_key(color_letter_keys, "X", "CTRL|SHIFT", clear_color)
bind_key(color_letter_keys, "Backspace", nil, clear_color)
for _, mods in ipairs({ "LEADER", "LEADER|CTRL" }) do
	bind_key(leader_color_keys, "n", mods, random_color)
	bind_key(leader_color_keys, "x", mods, clear_color)
end

local rename_tab = act.PromptInputLine({
	description = "Rename tab",
	action = wezterm.action_callback(function(window, _pane, line)
		if line == nil then
			return
		end
		local tab = window:active_tab()
		if not tab then
			return
		end
		local _, spec = decode_title(tab:get_title())
		paint_tab_title(tab, encode_title(line, spec))
	end),
})

-- keys: Ctrl+Shift for splits (avoids Niri Super bindings)
-- Leader is Ctrl+T. Ctrl+T then R renames the tab and keeps its color.
-- Tab color, immediately: Ctrl+T then a digit, n, or x
--   1 red  2 green  3 blue  4 violet
--   5 yellow  6 orange  7 cyan  8 pink  9 white  0 mint
--   n random  x clear
-- By letter: Ctrl+T then C, then r g b v y o c p w m (same digits work too).
-- Ctrl+Shift+T opens a tab (random wallpaper), then C enters that color mode.
config.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = "H",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "J",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "K",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "L",
		mods = "CTRL|SHIFT",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ShowLauncher,
	},
	{
		key = "D",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "S",
		mods = "CTRL|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- Ctrl+Shift+X is WezTerm copy mode, so close stays on Q.
	{
		key = "Q",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "A",
		mods = "CTRL|SHIFT",
		action = act.SendString("rai\r"),
	},
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
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action_callback(enter_tab_color),
	},
	{
		key = "c",
		mods = "LEADER|CTRL",
		action = wezterm.action_callback(enter_tab_color),
	},
	{
		key = "r",
		mods = "LEADER",
		action = rename_tab,
	},
	{
		key = "r",
		mods = "LEADER|CTRL",
		action = rename_tab,
	},
}

for _, entry in ipairs(leader_color_keys) do
	table.insert(config.keys, entry)
end

config.key_tables = {
	after_new_tab = {
		{
			key = "c",
			action = wezterm.action_callback(enter_tab_color),
		},
		{
			key = "c",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(enter_tab_color),
		},
		{
			key = "C",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(enter_tab_color),
		},
	},
	tab_color = color_letter_keys,
}

config.launch_menu = {
	{
		label = "dev-ai shell (rai)",
		args = { "bash", "-ic", "rai" },
	},
}

return config
