-- corpus_stalker_itemmodels.lua — re-vestido de ítems genéricos con modelos de la Zona
-- Los módulos del ecosistema registran sus ítems setting-agnostic SIN modelo a
-- propósito (Cargo #34, decisión del autor 2026-07-23): caen a la cajita de cartón
-- del drop y al ícono de letra. Este addon los re-viste vía Cargo.Items.SetModel —
-- el punto de sustitución de Cargo, orden-independiente: se puede llamar antes o
-- después de que el def registre. Los defs siguen siendo del módulo dueño; acá
-- solo cambia la piel (STK-1: consumidor, nunca proveedor).
--
-- Modelos: ports de S.T.A.L.K.E.R. (GSC Game World) — medkits de spec45as
-- (`stalker rp  content #4`), venda de wick (`stalker rp  content #1`), mochilas
-- del pack ZONA (`zona stalker props`). Crédito completo y retiro a pedido
-- (STK-8); rutas verbatim del pack de origen (STK-3). Manifiesto: docs/ASSETS.md.
--
-- Corre en AMBOS realms: las defs de Cargo viven por realm (COR-12), así que la
-- sustitución también tiene que aplicarse en los dos.

local SUSTITUCIONES = {
    -- Coagulant — set médico. El medkit_low es el botiquín básico de STALKER;
    -- medkit_med/high (army/científico) quedan copiados en el addon para los
    -- futuros defs de ítem de la Zona, no para el medkit genérico.
    corpus_coagulant_bandage = "models/wick/wrbstalker/cop/newmodels/items/wick_bandage.mdl",
    corpus_coagulant_medkit  = "models/spec45as/stalker/items/medkit_low.mdl",
    -- Tourniquet y Blood Bag: sin modelo coherente identificado en los packs
    -- (autor, 2026-07-23) — se quedan en la cajita.

    -- Cargo — mochilas genéricas (#34). Mapeo chica→1 / grande→2 confirmado
    -- en juego por el autor (2026-07-23).
    cargo_backpack_small = "models/hgn/srp/items/backpack-1.mdl",
    cargo_backpack_large = "models/hgn/srp/items/backpack-2.mdl",
}

local function Revestir()
    local cargo = Corpus.GetModule("cargo")
    if cargo == nil or cargo.Items == nil
        or not isfunction(cargo.Items.SetModel) then
        -- sin Cargo (o un Cargo viejo sin la superficie) no hay defs que
        -- re-vestir: degradación honesta, nada crashea
        return
    end

    local puestos, total = 0, 0
    for id, mdl in pairs(SUSTITUCIONES) do
        total = total + 1
        -- assets no versionados (STK-2): si el árbol vino sin el .mdl, el def
        -- conserva su default (la cajita) en vez de apuntar al vacío
        if file.Exists(mdl, "GAME") then
            cargo.Items.SetModel(id, mdl)
            puestos = puestos + 1
        end
    end
    Corpus.Log("stalker", "modelos de ítem sustituidos: " .. puestos .. "/"
        .. total .. " (" .. (SERVER and "server" or "client") .. ")")
end

-- Detección, nunca asunción (COR-5): lua/autorun se mergea alfabético ENTRE
-- addons, así que Corpus puede no existir todavía en file-scope. Mismo patrón
-- de sonda + boot diferido a Initialize que usan los inits de los módulos.
local function CorpusListo()
    return Corpus ~= nil and Corpus.OnReady ~= nil and Corpus.GetModule ~= nil
end

if CorpusListo() then
    Corpus.OnReady(Revestir)
else
    hook.Add("Initialize", "corpus_stalker_itemmodels", function()
        hook.Remove("Initialize", "corpus_stalker_itemmodels")
        -- sin framework no hay ecosistema que consumir: silencio deliberado —
        -- este addon también sirve assets sueltos (playermodels) sin Corpus
        if CorpusListo() then Corpus.OnReady(Revestir) end
    end)
end
