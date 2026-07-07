local wezterm = require("wezterm")
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

return config
