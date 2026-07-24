-- corpus_stalker_sidorovich.lua — la voz y la piel de Sidorovich para el trader
-- El trader demo de Cargo es genérico (un citizen mudo en idles de plaza); este
-- archivo le cuelga la persona de Sidorovich vía Cargo.Trade.SetDefaultPersona —
-- el punto de sustitución cosmético del trade, mismo espíritu que Items.SetModel
-- (STK-1: consumidor, nunca proveedor — Cargo no nombra a Sidorovich en ninguna
-- parte). El mapa de líneas sigue el about.txt del autor en
-- sound/npc/sidorovich/ ("Habar": robo de loot en ruso):
--   greet_first      primera vez que el jugador se acerca  (greet_first)
--   greet            saludos siguientes                    (greet_1..4)
--   wait             parado 1 min sin iniciar trading      (wait_1..4)
--   bye              se va del área cercana (del búnker)   (bye_1..3)
--   trade_open_first primera vez que abre la pantalla      (greet_habar)
--   trade_open       aperturas siguientes                  (habar_greet_1..3)
--   trade_done       transacción concluida con éxito       (bye_habar_1..3)
-- Sin consumidor todavía (anotados para futuro): esc_trader_call (llamado),
-- esc_trader_habar_request, esc_trader_bye_give_habar, esc_trader_start_pda.
--
-- Sonidos: voces de Sidorovich portadas de S.T.A.L.K.E.R. GAMMA (GSC Game
-- World) — crédito completo y retiro a pedido (STK-8), assets no versionados
-- (STK-2): cada ruta se filtra con file.Exists antes de registrarse, y un set
-- que quedó vacío no se registra (el trader calla esa línea, nada crashea).
--
-- Corre en AMBOS realms sin daño (SetDefaultPersona es shared); solo el server
-- la lee — la entity del trader emite con EmitSound de mundo.

local DIR = "npc/sidorovich/"

local LINEAS = {
    greet_first      = { "esc_trader_greet_first.ogg" },
    greet            = { "esc_trader_greet_1.ogg", "esc_trader_greet_2.ogg",
                         "esc_trader_greet_3.ogg", "esc_trader_greet_4.ogg" },
    wait             = { "esc_trader_wait_1.ogg", "esc_trader_wait_2.ogg",
                         "esc_trader_wait_3.ogg", "esc_trader_wait_4.ogg" },
    bye              = { "esc_trader_bye_1.ogg", "esc_trader_bye_2.ogg",
                         "esc_trader_bye_3.ogg" },
    trade_open_first = { "esc_trader_greet_habar.ogg" },
    trade_open       = { "esc_trader_habar_greet_1.ogg", "esc_trader_habar_greet_2.ogg",
                         "esc_trader_habar_greet_3.ogg" },
    trade_done       = { "esc_trader_bye_habar_1.ogg", "esc_trader_bye_habar_2.ogg",
                         "esc_trader_bye_habar_3.ogg" },
}

local function RegistrarPersona()
    local cargo = Corpus.GetModule("cargo")
    if cargo == nil or cargo.Trade == nil
        or not isfunction(cargo.Trade.SetDefaultPersona) then
        -- sin Cargo (o un Cargo viejo sin la superficie) no hay trader que
        -- vestir: degradación honesta, nada crashea
        return
    end

    -- assets no versionados (STK-2): solo entran las líneas cuyo .ogg montó
    local sonidos, presentes, total = {}, 0, 0
    for key, lista in pairs(LINEAS) do
        local set = {}
        for _, nombre in ipairs(lista) do
            total = total + 1
            if file.Exists("sound/" .. DIR .. nombre, "GAME") then
                set[#set + 1] = DIR .. nombre
                presentes = presentes + 1
            end
        end
        if #set > 0 then sonidos[key] = set end
    end

    local modelo = "models/rashkinsk/sidor.mdl"
    local tieneModelo = file.Exists(modelo, "GAME")

    if presentes == 0 and not tieneModelo then
        Corpus.Log("stalker", "Sidorovich: sin assets montados, persona no registrada")
        return
    end

    cargo.Trade.SetDefaultPersona({
        name = "Sidorovich",
        model = tieneModelo and modelo or nil,
        -- idles de plaza del citizen HL2 (el rig de sidor.mdl incluye
        -- male_shared): la entity descarta por LookupSequence las que falten
        idles = { "plazaidle1", "plazaidle2", "plazaidle3", "plazaidle4",
                  "lineidle01", "idle_subtle" },
        radius = 220,        -- "unos metros": el búnker de Sidorovich es chico
        wait_interval = 60,  -- 1 min entre líneas de espera (pedido del autor)
        sounds = sonidos,
    })
    Corpus.Log("stalker", "persona de Sidorovich registrada: " .. presentes .. "/"
        .. total .. " líneas (" .. (SERVER and "server" or "client") .. ")")
end

-- Detección, nunca asunción (COR-5): lua/autorun se mergea alfabético ENTRE
-- addons, así que Corpus puede no existir todavía en file-scope. Mismo patrón
-- de sonda + boot diferido a Initialize que usa corpus_stalker_itemmodels.lua.
local function CorpusListo()
    return Corpus ~= nil and Corpus.OnReady ~= nil and Corpus.GetModule ~= nil
end

if CorpusListo() then
    Corpus.OnReady(RegistrarPersona)
else
    hook.Add("Initialize", "corpus_stalker_sidorovich", function()
        hook.Remove("Initialize", "corpus_stalker_sidorovich")
        -- sin framework no hay ecosistema que consumir: silencio deliberado —
        -- este addon también sirve assets sueltos (playermodels) sin Corpus
        if CorpusListo() then Corpus.OnReady(RegistrarPersona) end
    end)
end
