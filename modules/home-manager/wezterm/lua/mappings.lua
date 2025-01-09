local wez = require("wezterm")
local act = wez.action
local callback = wez.action_callback

local mod = {
	c = "CTRL",
	s = "SHIFT",
	a = "ALT",
	l = "LEADER",
	n = "NONE",
}

local keybind = function(mods, key, action)
	return { mods = table.concat(mods, "|"), key = key, action = action }
end

local M = {}

local leader = { mods = mod.c, key = " ", timeout_miliseconds = 1000 }

local keys = function()
	local keys = {
		-- motion
		keybind({ mod.c }, "Backspace", act.SendKey({ mods = "ALT", key = "Backspace" })),

		-- screen
		keybind({ mod.n }, "F11", act.ToggleFullScreen),

		-- pane
		keybind({ mod.a }, "_", act.SplitVertical({ domain = "CurrentPaneDomain" })),
		keybind({ mod.a }, "9", act.SplitHorizontal({ domain = "CurrentPaneDomain" })),
		keybind({ mod.a }, "z", act.TogglePaneZoomState),
		keybind({ mod.c }, "w", act.CloseCurrentPane({ confirm = true })),
		keybind({ mod.a }, "h", act.ActivatePaneDirection("Left")),
		keybind({ mod.a }, "j", act.ActivatePaneDirection("Down")),
		keybind({ mod.a }, "k", act.ActivatePaneDirection("Up")),
		keybind({ mod.a }, "l", act.ActivatePaneDirection("Right")),
		keybind({ mod.a, mod.s }, "H", act.AdjustPaneSize({ "Left", 5 })),
		keybind({ mod.a, mod.s }, "J", act.AdjustPaneSize({ "Down", 5 })),
		keybind({ mod.a, mod.s }, "K", act.AdjustPaneSize({ "Up", 5 })),
		keybind({ mod.a, mod.s }, "L", act.AdjustPaneSize({ "Right", 5 })),

		-- tab
		keybind({ mod.c }, "t", act.SpawnTab("CurrentPaneDomain")),
		keybind({ mod.c, mod.s }, "W", act.CloseCurrentTab({ confirm = true })),
		keybind(
			{ mod.l },
			"e",
			act.PromptInputLine({
				description = wez.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Renaming Tab Title...:" },
				}),
				action = callback(function(win, _, line)
					if line == "" then
						return
					end
					win:active_tab():set_title(line)
				end),
			})
		),

		-- workspaces
		keybind({ mod.l }, "w", act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" })),

		-- copy and paste
		keybind({ mod.c, mod.s }, "c", act.CopyTo("Clipboard")),
		keybind({ mod.c, mod.s }, "v", act.PasteFrom("Clipboard")),

		-- update all plugins
		keybind(
			{ mod.l },
			"u",
			callback(function(win)
				wez.plugin.update_all()
				win:toast_notification("wezterm", "plugins updated!", nil, 4000)
			end)
		),
	}

	-- tab navigation
	for i = 1, 9 do
		table.insert(keys, keybind({ mod.l }, tostring(i), act.ActivateTab(i - 1)))
	end
	return keys
end

M.apply_to_config = function(c)
	c.treat_left_ctrlalt_as_altgr = true
	c.leader = leader
	c.keys = keys()
end

return M
