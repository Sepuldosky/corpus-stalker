-- corpus_stalker_sidorovich.lua — la voz y la piel de Sidorovich para el trader
-- El trader demo de Cargo es genérico (un citizen mudo en idles de plaza); este
-- archivo le cuelga la persona de Sidorovich vía Cargo.Trade.SetDefaultPersona —
-- el punto de sustitución cosmético del trade, mismo espíritu que Items.SetModel
-- (STK-1: consumidor, nunca proveedor — Cargo no nombra a Sidorovich en ninguna
-- parte). ESTÁNDAR DE VOZ POR ACCIÓN (pedido del autor 2026-07-24): cada
-- acción del trader es una CARPETA bajo sound/npc/sidorovich/ y cualquier
-- sonido dentro entra a su pool (mapa en el about.txt de la carpeta, "Habar":
-- robo de loot en ruso). Acá se registran solo las acciones que consume el
-- trader DEMO de Cargo; pain/death/trade_fail son del NextBot
-- (lua/entities/corpus_stalker_sidorovich.lua), que escanea las mismas
-- carpetas por su cuenta con el mismo contrato.
--
-- Sonidos: voces de Sidorovich portadas de S.T.A.L.K.E.R. GAMMA (GSC Game
-- World) — crédito completo y retiro a pedido (STK-8), assets no versionados
-- (STK-2): se registra lo que file.Find encuentra montado, y una acción sin
-- sonidos no se registra (el trader calla esa línea, nada crashea).
--
-- Corre en AMBOS realms sin daño (SetDefaultPersona es shared); solo el server
-- la lee — la entity del trader emite con EmitSound de mundo.

local DIR = "npc/sidorovich/"

-- acciones que el trader demo de Cargo sabe disparar (sus callbacks); las
-- carpetas restantes del estándar (pain/death/trade_fail) las usa el NextBot
local ACCIONES = { "greet_first", "greet", "wait", "bye",
                   "trade_open_first", "trade_open", "trade_done" }
local EXT_OK = { ogg = true, wav = true, mp3 = true }

local function RegistrarPersona()
    local cargo = Corpus.GetModule("cargo")
    if cargo == nil or cargo.Trade == nil
        or not isfunction(cargo.Trade.SetDefaultPersona) then
        -- sin Cargo (o un Cargo viejo sin la superficie) no hay trader que
        -- vestir: degradación honesta, nada crashea
        return
    end

    -- assets no versionados (STK-2): entra lo que file.Find encuentre montado
    -- en cada carpeta de acción (estándar del header)
    local sonidos, presentes = {}, 0
    for _, accion in ipairs(ACCIONES) do
        local set = {}
        local archivos = file.Find("sound/" .. DIR .. accion .. "/*", "GAME") or {}
        for _, f in ipairs(archivos) do
            local ext = string.lower(string.GetExtensionFromFilename(f) or "")
            if EXT_OK[ext] then set[#set + 1] = DIR .. accion .. "/" .. f end
        end
        if #set > 0 then
            sonidos[accion] = set
            presentes = presentes + #set
        end
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
        -- idles del citizen HL2 SOLO DE PIE (ajuste post-pasada 2026-07-24:
        -- las plazaidle ladeaban a la pared o sentaban al NPC — fuera); la
        -- entity descarta por LookupSequence las que el modelo no tenga
        idles = { "idle_subtle", "idle01", "lineidle01", "lineidle02", "lineidle03" },
        radius = 220,        -- "unos metros": el búnker de Sidorovich es chico
        wait_interval = 60,  -- 1 min entre líneas de espera (pedido del autor)
        sounds = sonidos,
    })
    Corpus.Log("stalker", "persona de Sidorovich registrada: " .. presentes
        .. " líneas por carpetas de acción ("
        .. (SERVER and "server" or "client") .. ")")
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
