local wezterm = require("wezterm")
local config = {}

config.default_prog = { "wsl", "--cd", "~" }

-- Options
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
-- config.font = wezterm.font("UbuntuSansMono Nerd Font Mono")

-- config.use_ime=true
-- config.send_composed_key_when_left_alt_is_pressed = true
-- config.send_composed_key_when_right_alt_is_pressed = false

config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.font_size = 12
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.check_for_updates = false
-- config.show_update_window = false
config.hide_mouse_cursor_when_typing = true

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 100

-- Colors
-- config.color_scheme = "tokyonight_night"
config.color_scheme = "Catppuccin Mocha"
-- config.color_scheme = "rose-pine"

-- config.window_background_opacity = 0.9
-- config.macos_window_background_blur = 20

config.colors = {
	-- background = "rgba(0 0 0 40%)",

	-- Ayu mirage theme
	-- cursor_bg = "#FFCC66",
	-- selection_bg = "#FFCC66",
	-- selection_fg = "#000000",

	-- Blanc
	-- cursor_bg = "#FFFFFF",
	-- selection_fg = "#000000",
	-- selection_bg = "#FFFFFF",

	tab_bar = {
		background = "transparent",
	},
}

-- Keymaps
config.leader = { key = "\\", mods = "CTRL", timeout_milliseconds = 500 }
config.keys = {
	{
		key = "1",
		mods = "ALT",
		action = wezterm.action.ActivateTab(0),
	},
	{
		key = "2",
		mods = "ALT",
		action = wezterm.action.ActivateTab(1),
	},
	{
		key = "3",
		mods = "ALT",
		action = wezterm.action.ActivateTab(2),
	},
	{
		key = "4",
		mods = "ALT",
		action = wezterm.action.ActivateTab(3),
	},
	{
		key = "5",
		mods = "ALT",
		action = wezterm.action.ActivateTab(4),
	},
	{
		key = "6",
		mods = "ALT",
		action = wezterm.action.ActivateTab(5),
	},
	{
		key = "7",
		mods = "ALT",
		action = wezterm.action.ActivateTab(6),
	},
	{
		key = "8",
		mods = "ALT",
		action = wezterm.action.ActivateTab(7),
	},
	{
		key = "9",
		mods = "ALT",
		action = wezterm.action.ActivateTab(8),
	},
	{
		key = "0",
		mods = "ALT",
		action = wezterm.action.ActivateTab(9),
	},
	{ key = "H", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "L", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "K", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "J", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "q",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentPane({ confirm = false }),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "S",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "y",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
}

-- Copy Mode (visual mode)
local keys_copymode = {
	{ key = "Escape", mods = "NONE", action = wezterm.action.CopyMode("Close") },
	{ key = "q", mods = "NONE", action = wezterm.action.CopyMode("Close") },
	{ key = "j", mods = "NONE", action = wezterm.action.CopyMode("MoveDown") },
	{ key = "k", mods = "NONE", action = wezterm.action.CopyMode("MoveUp") },
	{ key = "DownArrow", mods = "NONE", action = wezterm.action.CopyMode("MoveDown") },
	{ key = "UpArrow", mods = "NONE", action = wezterm.action.CopyMode("MoveUp") },
	{ key = "LeftArrow", action = wezterm.action.CopyMode("MoveLeft") },
	{ key = "RightArrow", action = wezterm.action.CopyMode("MoveRight") },
	{ key = "h", action = wezterm.action.CopyMode("MoveLeft") },
	{ key = "l", action = wezterm.action.CopyMode("MoveRight") },
	{ key = "b", mods = "NONE", action = wezterm.action.CopyMode("MoveBackwardWord") },
	{ key = "e", mods = "NONE", action = wezterm.action.CopyMode("MoveForwardWordEnd") },
	{ key = "Home", mods = "NONE", action = wezterm.action.CopyMode("MoveToStartOfLineContent") },
	{ key = "End", mods = "NONE", action = wezterm.action.CopyMode("MoveToEndOfLineContent") },
	{ key = "v", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Cell" }) },
	{ key = "V", mods = "NONE", action = wezterm.action.CopyMode({ SetSelectionMode = "Line" }) },
	{ key = "y", mods = "NONE", action = wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }) },
	{
		key = "f",
		mods = "NONE",
		action = wezterm.action.CopyMode({ JumpForward = { prev_char = false } }),
	},
	{
		key = "F",
		mods = "NONE",
		action = wezterm.action.CopyMode({ JumpBackward = { prev_char = false } }),
	},
	{
		key = "g",
		mods = "NONE",
		action = wezterm.action.CopyMode("MoveToScrollbackTop"),
	},
	{
		key = "G",
		mods = "SHIFT",
		action = wezterm.action.CopyMode("MoveToScrollbackBottom"),
	},
}

local function concat(table1, table2)
	for _, v in pairs(table2) do
		table.insert(table1, v)
	end
	return table1
end

local default_keys_copymode = wezterm.gui.default_key_tables().copy_mode

config.key_tables = {
	copy_mode = concat(default_keys_copymode, keys_copymode),
}

return config
