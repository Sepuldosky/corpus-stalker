-- corpus_stalker_playermodels.lua — registro de playermodels del pack ZONA StalkerRP
-- Reciclado de "zona stalkerrp content" (Workshop 300746843, pack de Neon; lua
-- original de Cluelesshobo). Modelos/texturas: ports de S.T.A.L.K.E.R. (GSC Game
-- World) compilados por la escena SRP (HGN y otros). Crédito y retiro a pedido —
-- ver README.md del addon y dev/zona_stalkerrp_contenido.md §1.
-- Cambios sobre el original: nombres con prefijo "ZONA" para agruparlos en el
-- selector, fix del path de Seva Cadpat (apuntaba fuera de seva/) y del typo
-- "Heayv" en las manos de Seva Monolith Heavy.

local ARMS = "models/arms/c_arms_stalker.mdl"

local MODELS = {
    -- bandits (zona stalkerrp content/models/player/bandit/)
    { "ZONA Bandit 1",             "models/player/bandit/bandit1.mdl" },
    { "ZONA Bandit 2",             "models/player/bandit/bandit2.mdl" },
    { "ZONA Bandit 3",             "models/player/bandit/bandit3.mdl" },
    { "ZONA Bandit 4",             "models/player/bandit/bandit4.mdl" },
    { "ZONA Bandit 5",             "models/player/bandit/bandit5.mdl" },
    { "ZONA Bandit Boss 1",        "models/player/bandit/banditboss1.mdl" },
    { "ZONA Bandit Boss 2",        "models/player/bandit/banditboss2.mdl" },
    -- sevas / exos (zona stalkerrp content/models/player/seva/)
    { "ZONA Seva Loner",           "models/player/seva/seva_lone.mdl" },
    { "ZONA Seva Sunrise",         "models/player/seva/seva_sunrise.mdl" },
    { "ZONA Seva Freedom",         "models/player/seva/seva_free.mdl" },
    { "ZONA Seva Freedom Heavy",   "models/player/seva/seva_freedom_heavy.mdl" },
    { "ZONA Seva Merc",            "models/player/seva/seva_merc.mdl" },
    { "ZONA Seva Clear Sky",       "models/player/seva/seva_clearsky.mdl" },
    { "ZONA Seva Monolith",        "models/player/seva/seva_mono.mdl" },
    { "ZONA Seva Monolith CS2",    "models/player/seva/seva_monolith_cs2.mdl" },
    { "ZONA Seva Monolith Heavy",  "models/player/seva/seva_monolith_heavy.mdl" },
    { "ZONA Seva Exo Heavy",       "models/player/seva/exo_seva_heavy.mdl" },
    { "ZONA Seva Heavy",           "models/player/seva/seva_heavy.mdl" },
    { "ZONA Seva Black",           "models/player/seva/seva_black.mdl" },
    { "ZONA Seva Camo",            "models/player/seva/seva_camo.mdl" },
    { "ZONA Seva Cadpat",          "models/player/seva/seva_cadpat.mdl" },
    { "ZONA Seva Urban",           "models/player/seva/seva_urban.mdl" },
    { "ZONA Seva Winter",          "models/player/seva/seva_winter.mdl" },
    { "ZONA Seva Woodland",        "models/player/seva/seva_woodland.mdl" },
    { "ZONA Seva Helios",          "models/player/seva/seva_helios.mdl" },
    { "ZONA Seva Reich",           "models/player/seva/seva_reich.mdl" },
    { "ZONA Seva Vigilance",       "models/player/seva/seva_vigilance.mdl" },
    { "ZONA Seva Mad Scientist",   "models/player/seva/seva_madscientist.mdl" },
}

for _, m in ipairs(MODELS) do
    player_manager.AddValidModel(m[1], m[2])
    list.Set("PlayerOptionsModel", m[1], m[2])
    player_manager.AddValidHands(m[1], ARMS, 0, "00000000")
end
