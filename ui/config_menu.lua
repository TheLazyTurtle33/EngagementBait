local config_toggles = {
}

local config_sliders = {
	{ref_value = "poll_duration", label = "eb_config_poll_duration", min = 15, max = 300, step = 5},
}

local config_text_boxes = {
    {ref_value = "username", label = "eb_config_linked_account", tooltip = "eb_config_linked_account_tooltip"},
}

local config_buttons = {
    {ref_value = "link_account", label = "eb_config_link_account" }, --, tooltip = "eb_config_link_account_tooltip"},
    {ref_value = "open_dashboard", label = "eb_config_open_dashboard" }, --, tooltip = "eb_config_link_account_tooltip"},
    {ref_value = "restart_server", label = "eb_config_restart_server" }, --, tooltip = "eb_config_link_account_tooltip"},
	
}


local create_menu_toggles = function (parent, toggle)
		parent.nodes[#parent.nodes + 1] = create_toggle({
				label = localize(toggle.label),
				ref_table = EngagementBait.mod.config,
				ref_value = toggle.ref_value,
		})
		-- if v.tooltip then
		-- 	parent.nodes[#parent.nodes].config.detailed_tooltip = v.tooltip
		-- end

end


local create_menu_button = function (parent, config_button, callback)
    parent.nodes[#parent.nodes + 1] = UIBox_button({
        label = {localize(config_button.label)},
        button = callback,
        colour = HEX("900ACE"),
        ref_table = EngagementBait.mod.config,
        ref_value = config_button.ref_value,

    })
    -- if config_button.tooltip then
	-- 	parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_button.tooltip)
	-- end
end

local create_menu_slider = function (parent, config_slider)
    parent.nodes[#parent.nodes + 1] = create_slider({
        label = localize(config_slider.label),
        ref_table = EngagementBait.mod.config,
        ref_value = config_slider.ref_value,
        min = config_slider.min,
        max = config_slider.max,
        step = config_slider.step,
		w = 3
    })
    -- if config_slider.tooltip then
    --     parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_slider.tooltip)
    -- end
end

local create_menu_option_cycle = function (parent, config_option_cycle)
    parent.nodes[#parent.nodes + 1] = create_option_cycle({
		label = config_option_cycle.label,
		-- scale = 0.8,
		ref_table = EngagementBait.mod.config,
		ref_value = config_option_cycle.ref_value,
		options = {"en-us-4","en-us-4-5","en-us-4+","en-us-full"},
		current_option = EngagementBait.mod.config.wordlistindex,
		opt_callback = "option_cycle_callback"
	})
    -- if config_slider.tooltip then
    --     parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_slider.tooltip)
    -- end
end
function G.FUNCS.option_cycle_callback(arg)
	if not G.OVERLAY_MENU then
		return
	end
	EngagementBait.mod.config.wordlistindex = arg.to_key
	EngagementBait.mod.config.wordlist = arg.to_val
end


local create_menu_text_box = function (parent, config_text_box)
        parent.nodes[#parent.nodes + 1] = {
        n = G.UIT.T,
        config = {
            text = config_text_box.ref_value,
            shadow = true,
            scale = 0.75 * 0.8,
            colour = G.C.PURPLE,
            ref_value = config_text_box.ref_value,
            ref_table = EngagementBait.mod.config,
        },
    }
    -- if config_text_box.tooltip then
    --     parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_text_box.tooltip)
    -- end
end



EngagementBait.config_page = function()
	local config_button_nodes = {n = G.UIT.R, config = {align = "tm", padding = 0.1, scale = 0.75, colour = G.C.CLEAR,}, nodes = {}}
	local config_text_box_nodes = {n = G.UIT.R, config = {align = "tm", padding = 0.05, scale = 0.75, colour = G.C.CLEAR,}, nodes = {}}
	local config_slider_nodes = {n = G.UIT.R, config = {align = "tm", padding = 0.3, scale = 0.75, colour = G.C.CLEAR,}, nodes = {}}
	local config_option_cycle_nodes = {n = G.UIT.R, config = {align = "tm", padding = 0.1, scale = 0.75, colour = G.C.CLEAR,}, nodes = {}}
    create_menu_text_box(config_text_box_nodes, config_text_boxes[1])
    create_menu_option_cycle(config_option_cycle_nodes, {ref_value = "wordlistindex", label = "wordlist" })
	create_menu_slider(config_slider_nodes, config_sliders[1])
    create_menu_button(config_button_nodes, config_buttons[1], "EngagementBaitLinkAccount")
    create_menu_button(config_button_nodes, config_buttons[2], "EngagementBaitLinkOpenDashboard")
	create_menu_button(config_button_nodes, config_buttons[3], "EngagementBaitTwitchRestartServer")
	local config_nodes =
	{
		{
			n = G.UIT.R,
			config = {
				padding = 0,
				align = "tm"
			},
			nodes = {
				-- Column Left
				{
					n = G.UIT.C,
					config = {
						padding = 0,
						align = "tm"
					},
					nodes = {
                        {
							n = G.UIT.R,
							config = {
								padding = 0,
								align = "cm"
							},
							nodes = {
                                {
							        n = G.UIT.T,
							        config = {
							            text = localize(config_text_boxes[1].label),
							            shadow = true,
							            scale = 0.75 * 0.8,
							            colour = HEX("5E40E2")
							        },
							    }
							},
						},
                        config_text_box_nodes,
						config_button_nodes,
						config_slider_nodes,
						config_option_cycle_nodes
					}
				},
			},
		},
	}

	return config_nodes
end

EngagementBait.mod.config_tab = function()
	return {
		n = G.UIT.ROOT, 
		config = {        
			align = "cm",
        	padding = 0.05,
        	colour = G.C.CLEAR,
		}, 
		nodes = EngagementBait.config_page()
	}
end

