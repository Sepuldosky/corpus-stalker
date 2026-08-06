-- corpus_stalker_itemmodels.lua — re-vestido de ítems genéricos con modelos de la Zona
-- Un módulo del ecosistema puede registrar un ítem SIN modelo a propósito (Cargo
-- #34, decisión del autor 2026-07-23): cae a la cajita de cartón del drop y al
-- ícono de letra, esperando que un addon de CONTENIDO le ponga uno de su setting.
-- Este addon llena esos huecos vía Cargo.Items.SetModel — el punto de sustitución
-- de Cargo, orden-independiente: se puede llamar antes o después de que el def
-- registre. Los defs siguen siendo del módulo dueño; acá solo cambia la piel
-- (STK-1: consumidor, nunca proveedor).
--
-- LLENAR UN HUECO NO ES PISAR UN MODELO. Ver el bloque de abajo: la sustitución
-- de los ítems médicos de Coagulant se RETIRÓ el 2026-08-06, porque ese módulo
-- ya trae los suyos y porque los medkits de la Zona son ítems distintos, no una
-- piel del genérico.
--
-- Modelos: ports de S.T.A.L.K.E.R. (GSC Game World) — mochilas del pack ZONA
-- (`zona stalker props`). Crédito completo y retiro a pedido (STK-8); rutas
-- verbatim del pack de origen (STK-3). Manifiesto: docs/ASSETS.md.
--
-- Corre en AMBOS realms: las defs de Cargo viven por realm (COR-12), así que la
-- sustitución también tiene que aplicarse en los dos.

-- COAGULANT YA NO SE SUSTITUYE (decisión del autor, 2026-08-06).
--
-- Hasta hoy este addon le ponía `wick_bandage` a la venda y `medkit_low` al
-- medkit de Coagulant. Se retira por dos motivos, y el segundo es el que manda:
--
--  1. Coagulant trae sus propios modelos desde el 2026-08-05 (19 `.mdl` CC BY
--     4.0 en `models/corpus_coagulant/`). La sustitución dejó de tapar una
--     cajita de cartón y pasó a tapar un modelo bueno.
--  2. Y sobre todo: los botiquines y la venda de STALKER **no son una piel del
--     ítem genérico, son ítems distintos**. Un `medkit_army` de la Zona tiene
--     otro peso, otro precio y otra curación que el Medkit genérico de
--     Coagulant; vestir al genérico con su modelo miente sobre lo que es. El
--     lugar de esos modelos son defs de ítem PROPIAS de la Zona.
--
-- Los tres medkits (`medkit_low/med/high`) y la venda siguen en el árbol de
-- assets esperando esos defs — ver docs/ASSETS.md. El alcance de commit `items`
-- sigue RESERVADO hasta que se escriban, y COA-28/STK-1 mandan: el diseño se
-- acuerda antes de bajarlo a código. Que el modelo exista no crea el ítem.
--
-- Lo que SÍ queda: las mochilas de Cargo. Ésas siguen registrándose sin modelo
-- a propósito (`corpus_cargo_supplies.lua`: "The backpacks declare NO model on
-- purpose: HL2 has no backpack prop"), así que acá no se tapa nada — se llena
-- un hueco que el módulo dueño dejó abierto a propósito. Es la diferencia entre
-- vestir y pisar.
local SUSTITUCIONES = {
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
