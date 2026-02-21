return {
	descriptions  = {
		Joker = {
			j_eb_bitter = {
				 name = "Bitter", text  = {
					'This Joker gains {C:red}+#1#{} Mult',
					'per bit since purchase',
					'{C:inactive}(Currently {C:red}+#2#{} {C:inactive}Mult){}'
				}
			},
			j_eb_chatter = {
				 name = "Chatter", text  = {
					'This Joker gains {C:blue}+#1#{} Chips',
					'per chat message since purchase',
					'{C:inactive}(Currently {C:blue}+#2#{} {C:inactive}Chips){}'
				}
			},
			j_eb_dead_chat = {
				name = "DeadChat",
				text  = {
					'{X:mult,C:white} X#1# {} Mult',
					'lose {X:mult,C:white}X#2#{}  Mult every {C:attention}#3#{} seconds',
					'without a chat message',
					'{C:inactive}(Currently {X:mult,C:white}X#4# {C:inactive} Mult){}'
				}
			},
			-- j_eb_follower = { name = "Follower", text  = {''} },
			-- j_eb_gifter = { name = "Gifter", text  = {''} },
			j_eb_loooooog_stream = {
				 name = "Loooooog Stream",
				 text  = {
					'This Joker gains {C:blue}+#1#{} Chips',
					'per min of stream duration',
					'{C:inactive}(Currently {C:blue}+#2#{} {C:inactive}Chips){}'
				}
			},
			-- j_eb_primer = { name = "Primeer", text  = {''} },
			-- j_eb_subathon = { name = "Subathon", text  = {''} },
			-- j_eb_subber = { name = "Subber", text  = {''} },
			-- j_eb_the_great_vote = { name = "The Great Vote", text  = {''} },
			j_eb_the_secret = {
				name = "The Secret", text  = {
					'{X:mult,C:white} X#1# {} Mult',
					'If a chat message matches the secret word',
					'it becomes {X:mult,C:white}X#2# {} Mult',
					'{C:inactive}(Currently {X:mult,C:white}X#3# {C:inactive} Mult){}'
				}
			},
			j_eb_view_botting = {
				 name = "View Botting",
				 text  = {
					'This Joker gains',
					'{C:red}+#1#{} mult per viewer',
					'{C:inactive}(Currently {C:red}+#2#{} {C:inactive}mult){}'
				} 
			},
		},
	},
	misc = {
        dictionary = {
			eb_config_header = "Engagement Bait: Configuration",
			eb_config_link_account = "Link Twitch",
			eb_config_open_dashboard = "Open Dashboard",
			eb_config_linked_account = "Linked Twitch Account:",
			eb_config_restart_server = "Restart Server",
			eb_config_poll_duration = "Poll Duration (seconds)",
			eb_config_link_account_tooltip = "Links your Twitch account to the mod.",
			eb_config_linked_account_tooltip = "Shows the name of the currently linked Twitch account.",
			eb_config_restart_server_tooltip = "Restarts the local server. Use this if the mod isn't responding to Twitch or if you changed your Twitch account.",
			eb_config_poll_duration_tooltip = "Sets the duration for polls created by jokers like The Great Vote.",
			
		
		}
	}

}
