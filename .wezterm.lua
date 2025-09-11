local wezterm = require("wezterm")

local act = wezterm.action
local config = {}

config.check_for_updates = true

config.front_end = "OpenGL"
config.max_fps = 60
--config.default_cursor_style = "BlinkingBlock"
--config.animation_fps = 1
--config.cursor_blink_rate = 500

config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- prompt time & cwd
config.set_environment_variables = {
	prompt = "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ",
}

-- config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "--norc" }

function Basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function cwd_basename_from_pane(pane)
	local cwd = pane and pane.current_working_dir
	if not cwd then
		return ""
	end

	if type(cwd) == "userdata" or type(cwd) == "table" then
		local path = cwd.file_path or ""
		path = path:gsub("[/\\]$", "")
		return (path:match("([^/\\]+)$")) or path
	end

	local ok, parsed = pcall(function()
		return wezterm.url.parse(cwd)
	end)
	local path = (ok and parsed and parsed.file_path) and parsed.file_path or cwd
	path = path:gsub("[/\\]$", "")
	return (path:match("([^/\\]+)$")) or path
end

wezterm.on("format-tab-title", function(tab)
	local pane = tab.active_pane
	local cwd = cwd_basename_from_pane(pane)

	local title = cwd ~= "" and cwd or "(no cwd)"

	return {
		{ Text = " " .. title .. " " },
	}
end)

wezterm.on("update-right-status", function(window, pane)
	local info = pane:get_foreground_process_info()
	local current_time = os.date("%H:%M:%S")

	if info then
		window:set_right_status(wezterm.format({
			{ Text = tostring(info.pid) .. " " .. Basename(info.executable) .. " | " .. current_time .. "  " },
		}))
	else
		window:set_right_status(wezterm.format({
			{ Text = current_time .. "  " },
		}))
	end
end)

wezterm.on("toggle-tabbar", function(window, _)
	local overrides = window:get_config_overrides() or {}
	if overrides.enable_tab_bar == false then
		-- tabbar shown
		overrides.enable_tab_bar = true
		overrides.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	else
		-- tabbar hidden
		overrides.enable_tab_bar = false
		overrides.window_padding = { top = 20, left = 0, right = 0, bottom = 0 }
	end
	window:set_config_overrides(overrides)
end)

config.keys = {
	{ key = "q", mods = "CTRL", action = act.EmitEvent("toggle-tabbar") },
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "w",
		mods = "CTRL",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ ActivatePaneDirection = "Left" }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ ActivatePaneDirection = "Right" }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ ActivatePaneDirection = "Up" }),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ ActivatePaneDirection = "Down" }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }),
	},
	{ key = "m", mods = "SHIFT|CTRL", action = wezterm.action.Hide },
	{ key = "n", mods = "SHIFT|CTRL", action = wezterm.action.ToggleFullScreen },
	{ key = " ", mods = "CTRL|ALT", action = act.SpawnCommandInNewTab({ cwd = "C:/Projects" }) },
	{
		key = "{",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(-1),
	},
	{
		key = "}",
		mods = "CTRL|SHIFT",
		action = wezterm.action.MoveTabRelative(1),
	},
	{
		key = "i",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SpawnCommandInNewWindow({}),
	},
	{
		key = "n",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "!",
		mods = "SHIFT|ALT",
		action = wezterm.action_callback(function(_, pane)
			pane:move_to_new_window()
		end),
	},
}

config.default_cwd = "C:/Projects"

config.font = wezterm.font_with_fallback({
	"UbuntuSansMono NF",
	"FiraCode Nerd Font Mono",
	"Cambria Math",
})
config.font_size = 11.5

config.window_close_confirmation = "NeverPrompt"

config.enable_scroll_bar = false
config.enable_tab_bar = true

config.skip_close_confirmation_for_processes_named = {
	"bash",
	"sh",
	"zsh",
	"fish",
	"tmux",
	"nu",
	"cmd.exe",
	"pwsh.exe",
	"powershell.exe",
	"nvim.exe",
}

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

config.color_scheme = "Dark Pastel"

config.window_decorations = "NONE"

config.window_background_opacity = 0.8

-- wezterm.on("update-status", function(window)
-- 	local backgrounds = {
-- 	}

-- 	for _, item in pairs(window:mux_window():tabs_with_info()) do
-- 		if item.is_active then
-- 			window:set_config_overrides({
-- 				background = {
-- 					{
-- 						source = {
-- 						},
-- 					},
-- 				},
-- 			})
-- 			break
-- 		end
-- 	end
-- end)

return config
