local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- appearance: minimal chrome, cool dark palette
config.color_scheme = "Dracula (Official)"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.window_padding = {
	left = 15,
	right = 15,
	top = 15,
	bottom = 15,
}

-- text
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- cursor
config.default_cursor_style = "SteadyBar"
config.cursor_blink_rate = 0

-- keys: Ctrl+Shift for splits (avoids Niri Super bindings)
config.leader = { key = "t", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
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
	{
		key = "Q",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "r",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename tab",
			action = wezterm.action_callback(function(window, _pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

return config
