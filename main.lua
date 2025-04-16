function Card:resize(mod, force_save)
    self:hard_set_T(self.T.x, self.T.y, self.T.w * mod, self.T.h * mod)
    remove_all(self.children)
    self.children = {}
    self.children.shadow = Moveable(0, 0, 0, 0)
    self:set_sprites(self.config.center, self.base.id and self.config.card)
end

-- Get the mod's config
local perkolator_config = SMODS.current_mod.config
-- Create config if it doesn't exist
if not perkolator_config then
    perkolator_config = {
        title = true
    }
    SMODS.current_mod.config = perkolator_config
    -- Set default value if config exists but title setting doesn't
elseif perkolator_config.title == nil then
    perkolator_config.title = true
end
-- Store initial config state for comparison
local perkolator_enabled = copy_table(perkolator_config)

-- Add restart function to determine if restart is needed
function G.FUNCS.perkolator_restart()
    local config_changed = false
    for k, v in pairs(perkolator_enabled) do
        if v ~= perkolator_config[k] then
            config_changed = true
            break
        end
    end

    if config_changed then
        SMODS.full_restart = 1
    else
        SMODS.full_restart = 0
    end
end

-- Add a configuration menu for the Perkolating mod
SMODS.current_mod.config_tab = function()
    local perkolator_nodes = {{
        n = G.UIT.R,
        config = {
            align = "cm"
        },
        nodes = {{
            n = G.UIT.O,
            config = {
                object = DynaText({
                    string = "Options:",
                    colours = {G.C.WHITE},
                    shadow = true,
                    scale = 0.4
                })
            }
        }}
    }, create_toggle({
        label = "Perkeo Card on Title Screen (Requires Restart)",
        ref_table = perkolator_config,
        ref_value = "title",
        callback = G.FUNCS.perkolator_restart
    })}

    return {
        n = G.UIT.ROOT,
        config = {
            emboss = 0.05,
            minh = 6,
            r = 0.1,
            minw = 10,
            align = "cm",
            padding = 0.2,
            colour = G.C.BLACK
        },
        nodes = perkolator_nodes
    }
end

-- Modify the main menu only if the title screen change is enabled
if config["title"] then
    local mainmenuref2 = Game.main_menu
    Game.main_menu = function(change_context)
        local ret = mainmenuref2(change_context)

        -- Replace j_unik_unik with 'j_perkeo' or any other card
        local newcard = SMODS.create_card({
            key = 'j_perkeo',
            edition = 'e_negative',
            area = G.title_top
        })
        G.title_top.T.w = G.title_top.T.w * 1.7675
        G.title_top.T.x = G.title_top.T.x - 0.8
        G.title_top:emplace(newcard)
        newcard:start_materialize()
        newcard:resize(1.1 * 1.2)
        newcard.no_ui = true
        return ret
    end
end

SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true
    }
end

-- loads mod componets

assert(SMODS.load_file('jokers.lua'))()
assert(SMODS.load_file('rarity.lua'))()
assert(SMODS.load_file('consumeables.lua'))()
