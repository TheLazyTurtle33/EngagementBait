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
			j_eb_anty_clanker_measures = {
				name = "Anty Clanker Measures",
				text  = {
					'This Joker gains {C:red}+#1#{} Mult',
					'per chat message since purchase',
					'If a bot sends a message, {X:mult,C:white}X#2#{} this value',
					'{C:inactive}(Currently {C:red}+#3#{} {C:inactive}Mult){}'
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
			j_eb_the_great_vote = {
				name = "The Great Vote",
				text  = {
					'At the {C:attention}START{} of every round',
					'create a poll and chat choise',
					'what new {C:attention}POWER{} this joker gets',
					'{C:inactive}(max 20. new powers override the old ones)'
				}
			},
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
		Enhanced = {
			m_eb_emote = {
				name = "Emote Mode",
				text = {
					'When scored, {X:mult,C:white} X#1# {} Mult',
					'if in {C:attention}EmoteOnly{} mode',
					'else {X:mult,C:white} X#2# {} Mult',
					'{C:inactive}(Currently {X:mult,C:white}X#3# {C:inactive} Mult){}'
				}
			}
		},
		Other = {
			eb_the_great_vote_effects = {
				name = "Effects:",
				text = {
					   '{B:1,V:2}#1#{} | {B:3,V:4}#2#{}',
					   '{B:5,V:6}#3#{} | {B:7,V:8}#4#{}',
					  '{B:9,V:10}#5#{} | {B:11,V:12}#6#{}',
					 '{B:13,V:14}#7#{} | {B:15,V:16}#8#{}',
					 '{B:17,V:18}#9#{} | {B:19,V:20}#10#{}',
					'{B:21,V:22}#11#{} | {B:23,V:24}#12#{}',
					'{B:25,V:26}#13#{} | {B:27,V:28}#14#{}',
					'{B:29,V:30}#15#{} | {B:31,V:32}#16#{}',
					'{B:33,V:34}#17#{} | {B:35,V:36}#18#{}',
					'{B:37,V:38}#19#{} | {B:39,V:40}#20#{}',
				}
			}
		}

	},
	misc = {
        challenge_names = {
            c_eb_the_great_vote = "The Great Vote",
		},
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
		},
		labels = {
			eb_emote = "Emote Mode"
		},
		v_text = {
            ch_c_the_great_vote = { "You start with The Great Vote. thats it." },
		},

	
	}

}
