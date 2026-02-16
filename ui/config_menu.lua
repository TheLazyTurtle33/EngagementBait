local config_toggles = {
	-- Mod Mechanics
}

local config_sliders = {
    -- Mod Mechanics
}

local config_text_boxes = {
    -- Mod Mechanics
    {ref_value = "username", label = "eb_config_linked_account", tooltip = "eb_config_linked_account_tooltip"},
}

local config_text_inputs = {
    -- Mod Mechanics
}

local config_buttons = {
    {ref_value = "link_account", label = "eb_config_link_account" }, --, tooltip = "eb_config_link_account_tooltip"},
}


local create_menu_toggles = function (parent, toggles)
	for k, v in ipairs(toggles) do
		parent.nodes[#parent.nodes + 1] = create_toggle({
				label = localize(v.label),
				ref_table = EngagementBait.mod.config,
				ref_value = v.ref_value,
				callback = function(_set_toggle)
				NFS.write(EngagementBait.mod.path.."/config.lua", STR_PACK(EngagementBait.mod.config))
				end,
		})
		if v.tooltip then
			parent.nodes[#parent.nodes].config.detailed_tooltip = v.tooltip
		end
	end
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

-- local create_menu_slider = function (parent, config_slider)
--     parent.nodes[#parent.nodes + 1] = create_slider({
--         label = localize(config_slider.label),
--         ref_table = EngagementBait.config,
--         ref_value = config_slider.ref_value,
--         min = config_slider.min,
--         max = config_slider.max,
--         step = config_slider.step,
--         callback = function(_set_slider)
--             NFS.write(EngagementBait.mod_dir.."/config.lua", STR_PACK(EngagementBait.config))
--         end,
--     })
--     -- if config_slider.tooltip then
--     --     parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_slider.tooltip)
--     -- end
-- end

-- local create_menu_text_input = function (parent, config_text_input)
--     parent.nodes[#parent.nodes + 1] = create_text_input({
--         label = localize(config_text_input.label),
--         ref_table = EngagementBait.config,
--         ref_value = config_text_input.ref_value,
--         callback = function(_set_text_input)
--             NFS.write(EngagementBait.mod_dir.."/config.lua", STR_PACK(EngagementBait.config))
--         end,
--     })
--     -- if config_text_input.tooltip then
--     --     parent.nodes[#parent.nodes].config.detailed_tooltip = localize(config_text_input.tooltip)
--     -- end
-- end

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
	-- local config_toggle_nodes = {n = G.UIT.R, config = {align = "tm", padding = 0.05, scale = 0.75, colour = G.C.CLEAR,}, nodes = {}}
	-- create_menu_toggles(config_toggle_nodes, config_toggles)
    create_menu_text_box(config_text_box_nodes, config_text_boxes[1])
    create_menu_button(config_button_nodes, config_buttons[1], "EngagementBaitLinkAccount")
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
						-- HEADER (ENHANCEMENT TYPES)
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
										text = localize("eb_config_header"),
										shadow = true,
										scale = 0.75 * 0.8,
										colour = HEX("5E40E2")
									}
								},
							},
						},
						config_button_nodes,
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
						-- config_toggle_nodes,
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

