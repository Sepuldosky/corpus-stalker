-- corpus_stalker_sidorovich.lua — Sidorovich de cuerpo presente (NextBot)
-- Primera entidad del repo (clase prefijada, STK-5). El trader demo de Cargo es
-- deliberadamente una entity `anim` sin IA — su header dice que un trader real
-- con comportamiento vive FUERA de Cargo y llama al mismo `Trade.AttachTrader`;
-- este archivo es exactamente eso. Cargo no se tocó (STK-1: consumidor, nunca
-- proveedor). Confirmado en juego 2026-07-24 (checklist a-f, +USE nativo ✓);
-- esta versión aplica los ajustes post-pasada del autor.
--
-- Qué hace sobre el demo:
--   · NextBot con salud (100, estándar NPC/jugador): puede morir. Al morir NO
--     derrama el stock — el contenedor de sesión de Cargo eyecta al mundo en
--     el remove (corpus_cargo_containers.lua), así que acá se BORRA antes del
--     ragdoll. Respawnea según `corpus_stalker_trader_respawn` (segundos,
--     0 = no respawnea). Cuando exista el loot de cadáveres (cruce Cortex §9)
--     el trader SIGUE sin ser looteable: solo matable.
--   · Mirada: gira la cabeza (pose params head_yaw/head_pitch de male_shared)
--     hacia el jugador vivo más cercano dentro de VoiceRadius.
--   · Expresiones: el sidor.mdl trae exactamente dos flexes (blink / mouth).
--     blink parpadea de verdad; mouth aletea 0→1 mientras dura el audio —
--     duración EXACTA leída del contenedor Ogg (SoundDuration miente en
--     Windows y el estimado por tamaño se pasaba de largo; ver DuracionOgg).
--   · Al piso: origen NextBot en la planta de los pies + gravedad de la
--     locomoción; con el origen correcto el IK de las ValveBiped apoya.
--   · Animación FLUIDA — dos piezas, ambas verificadas contra DrGBase
--     (dev/other/drgbase, CRG-24) y el base_nextbot de Facepunch:
--     (1) el Think de un nextbot NO SE FRENA (ni NextThink ni return true —
--     DrGBase jamás lo hace): el engine cuelga del think los updates del bot
--     (BodyUpdate → FrameAdvance, UN paso fijo por llamada); el
--     NextThink(+0.5) original dejaba la anim a ~3% de velocidad (el
--     "a 5 fps" del autor). Lo lento va detrás de gates internos.
--     (2) cada secuencia se arranca con la receta del base_nextbot
--     (SetSequence + ResetSequenceInfo + SetCycle(0) + SetPlaybackRate) —
--     DrGBase usa la misma, calcada. Intento fallido anotado: mover la anim
--     al cliente con UseClientSideAnimation (revertido, no hizo nada).
--     Rotación de idles por TIMER (12-25 s).
--
-- ESTÁNDAR DE VOZ POR ACCIÓN (pedido del autor 2026-07-24): cada acción es
-- una CARPETA bajo `sound/<VoiceDir>/` y cualquier sonido dentro entra a su
-- pool — otro usuario arma su trader soltando .ogg en carpetas, sin tocar
-- Lua. Carpeta vacía o faltante = el trader calla esa acción, JAMÁS un error.
-- Acciones: greet_first (cae a greet) / greet / wait / bye / trade_open_first
-- (cae a trade_open) / trade_open / trade_done / trade_fail (cerró sin
-- comprar) / pain / death. El mapa vive en el about.txt de la carpeta.
--
-- OTROS TRADERS SOBRE ESTE NEXTBOT: subclasear y pisar los campos ENT.Trader*
-- y ENT.Voice* de abajo (ENT.Base = "corpus_stalker_sidorovich"). La ruta
-- admin "cualquier entidad como trader" quedó anotada como wanted idea en el
-- roadmap de Cargo (#45). El primero es corpus_stalker_hawaiian.lua, que es
-- una subclase de 40 líneas SIN una sola función propia: eso es el contrato de
-- subclase funcionando, no una casualidad.
--
-- STOCK SORTEADO CON RE-SORTEO (roadmap [1] de este repo, 2026-08-18), y vive
-- ACÁ y no en la subclase porque lo usan los DOS traders: cada uno declara sus
-- categorías y cantidades (ENT.TraderStock* abajo) y el mecanismo es uno solo.
-- Escribirlo en la subclase y copiarlo después es escribirlo dos veces — el
-- mismo argumento por el que la voz es por carpetas y no por tabla.
--
-- Deuda declarada: si alguien tiene la pantalla de trade abierta cuando él
-- muere, la pantalla queda huérfana — Cargo no tiene trade_close server→
-- cliente. Degrada honesto: cualquier acción responde "The trader is out of
-- reach" y el jugador la cierra a mano. **La ventana de cierre del re-sorteo
-- paga la MISMA deuda por la otra punta** (expulsa con ClearViewers y el panel
-- queda dibujado): las dos las salda el `Trade.CloseFor(ply, trader)` pedido
-- como entrada #65 del roadmap de Cargo, y ninguna de las dos la bloquea.

AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Type = "nextbot"
ENT.PrintName = "Sidorovich"
ENT.Author = "Corpus"
ENT.Category = "Corpus"
ENT.Spawnable = true

-- ------------------------------------------------------------------
-- Campos de subclase: un trader de terceros pisa estos y hereda todo el
-- comportamiento (voz por carpetas, mirada, flexes, muerte/respawn, trade).
-- ------------------------------------------------------------------
ENT.TraderName     = "Sidorovich"
ENT.TraderModel    = "models/rashkinsk/sidor.mdl"
ENT.TraderHealth   = 100    -- estándar NPC/jugador (pedido del autor)
ENT.TraderMoney    = 50000  -- billetera finita: se lo puede drenar
ENT.TraderBuyMult  = 0.5    -- paga la mitad del valor
ENT.TraderSellMult = 1.0    -- cobra el valor completo
ENT.VoiceDir       = "npc/sidorovich" -- raíz de las carpetas de acción
ENT.VoiceRadius    = 220    -- radio de saludo/mirada (unidades)
ENT.VoiceWait      = 60     -- segundos entre líneas de espera

-- Idles SOLO DE PIE (ajuste post-pasada: las plazaidle ladeaban a la pared o
-- sentaban al NPC): estándar / brazos cruzados / brazos caídos del set del
-- citizen HL2. Se filtran por LookupSequence — una que el modelo no tenga se
-- descarta sola. Si alguna lineidle resulta apoyarse, se quita de acá.
ENT.TraderIdles = { "idle_subtle", "idle01", "lineidle01", "lineidle02", "lineidle03" }

-- ------------------------------------------------------------------
-- STOCK: DOS RAMAS, Y UN TRADER ELIGE UNA. Que las dos convivan es lo que hay
-- que cuidar (§5.4 del handoff): un trader que persistiera Y re-sorteara
-- tendría dos fuentes de verdad sobre su repisa.
--   · RAMA FIJA — declarar `ENT.TraderStock` y NINGÚN sorteo. Es lo que había
--     hasta hoy: la lista se siembra una vez, sobrevive y nada la re-sortea.
--     Es la rama que convive con la persistencia de stock.
--   · RAMA SORTEADA — definir `ENT:TraderStockPlan()` (categorías y/o armas).
--     La repisa se sortea entera al sembrarse y se vuelve a sortear cada
--     `corpus_stalker_trader_restock` segundos. **`ENT.TraderStock` no se usa**
--     en esta rama: si declarás sorteo, la lista fija se ignora entera.
-- ------------------------------------------------------------------

-- Rama fija. Sidorovich la tuvo (el kit DEV de Cargo, de placeholder) hasta el
-- 2026-08-18: ese stock volvió al trader DEMO de Cargo, de donde había salido.
ENT.TraderStock = nil

-- Prefijos de id que NUNCA entran al sorteo. Es una lista de PREFIJOS y no de
-- ids exactos a propósito (voto del autor, 2026-08-18): así no hay que tocarla
-- el día que Cargo agregue un `cargo_dev_loquesea` — y si se olvidara, el ítem
-- entraría al stock sin que nada falle. Hace falta porque la regla por
-- categoría le devuelve el kit DEV a los dos traders: `cargo_dev_food` es
-- `food`, `cargo_dev_medkit` es `medical` y `cargo_dev_ammo_9mm` es `ammo`.
ENT.TraderStockExcluir = { "cargo_dev_" }

-- ------------------------------------------------------------------
-- EL CATÁLOGO DEL TRADER ES UN MÉTODO Y NO UN CAMPO, y la razón es del ENGINE,
-- no del gusto. `scripted_ents.TableInherit` (leído en la fuente,
-- includes/modules/scripted_ents.lua) copia del padre TODA clave que al hijo le
-- falte **y RECURSE dentro de las tablas**. O sea que una subclase que
-- declarara
--     ENT.TraderStockCategorias = { { cat = "food", min = 1, max = 6 } }
-- NO estaría pisando la lista del padre: estaría MERGEÁNDOSE con ella. Le
-- entraría el `stacks = true` de la munición adentro de su propia spec de
-- comida (por la recursión sobre el índice 1) y la entrada `medical` ENTERA
-- como segundo elemento (porque su índice 2 está vacío). El trader de comida
-- terminaría vendiendo medicinas y sirviendo el pan por stacks de 120, **sin un
-- solo error y sin que nada falle**.
-- Una FUNCIÓN no se mergea: no es una tabla, así que el hijo que la define la
-- pisa entera. Por eso el catálogo entero sale por una sola puerta.
--
-- ⚠ La misma trampa vale para CUALQUIER campo de tabla de esta clase, y
--   `ENT.TraderIdles` es el otro que ya existía: una subclase con dos idles se
--   come los tres restantes del padre. Hoy no muerde (son todas poses de pie
--   parecidas), pero está declarado.
--
-- Forma: { categorias = { ... }, armas = { ... } }, las dos opcionales.
--   categorias  una entrada por categoría de Cargo:
--                 cat      id de la categoría, tal cual la declaran las defs
--                 min/max  cantidad sorteada POR ÍTEM de esa categoría
--                 stacks   si es true la cantidad son STACKS y no unidades —
--                          la trampa entera está en SidorSortearLineas
--   armas       sorteo por CLASE, que NO es una categoría de Cargo: un arma
--               capturada no tiene código propio y su def no existe hasta que
--               alguien tuvo una en la mano, así que el id se pide por
--               `Capture.ItemIdFor` (CRG-70), que la acuña si hace falta. Cada
--               cubo dice cuántas saca y de qué subcategorías ARC9 se
--               alimenta; `resto = true` se queda con lo que ningún otro
--               reclamó. Un cubo vacío NO es un error: se sortea sobre lo que
--               haya montado, y sin el pack no sale ninguna.
--
-- Devolver una tabla vacía (o no definirlo) deja al trader en la rama fija.
-- ------------------------------------------------------------------

function ENT:TraderStockPlan()
    -- Sidorovich (§1.2.f, enmienda del 2026-08-17): munición, medicina y un
    -- puñado de armas EFT.
    return {
        categorias = {
            { cat = "ammo",    min = 1, max = 3, stacks = true },
            { cat = "medical", min = 1, max = 5 },
        },
        armas = {
            prefijo = "arc9_eft_",
            cubos = {
                { n = 2, subcats = { "eft_subcat_melee", "eft_subcat_grenades" } },
                { n = 6, resto = true },
            },
        },
    }
end

if SERVER then

    local MODELO_FALLBACK = "models/humans/group01/male_07.mdl"

    local PAUSA_VOZ   = 2.5  -- gap mínimo entre líneas ambientales
    local PAUSA_DOLOR = 1.1  -- gap mínimo entre quejidos de daño
    local ALCANCE_USO = 100  -- alcance del +USE por eyetrace (fallback)

    -- topes y ritmos de la cara
    local YAW_MAX, PITCH_MAX = 60, 25  -- tope del cuello (grados)
    local GIRO_VEL           = 240     -- velocidad de giro de cabeza (°/s)
    local PARPADEO_T         = 0.18    -- duración de un parpadeo (s)

    -- Respawn de traders (pedido del autor: sin UI, solo el cvar).
    local cvarRespawn = CreateConVar("corpus_stalker_trader_respawn", "60",
        FCVAR_ARCHIVE, "Seconds before a killed Corpus trader respawns. 0 disables the respawn.", 0)

    -- Re-sorteo de stock. Mismo patrón que el respawn, y por el mismo motivo:
    -- sin la perilla no hay forma de verificar el re-sorteo en una pasada sin
    -- esperar veinte minutos de reloj. **0 = sin re-sorteo** ⇒ el trader cae en
    -- la rama de stock fijo, que es la que convive con la persistencia.
    local cvarRestock = CreateConVar("corpus_stalker_trader_restock", "1200",
        FCVAR_ARCHIVE, "Seconds between stock re-rolls of a Corpus trader. 0 disables the re-roll.", 0)

    -- Los últimos N segundos antes del re-sorteo: el trader expulsa a quien
    -- esté mirando y se niega a comerciar. Ver el bloque de re-sorteo.
    local cvarAviso = CreateConVar("corpus_stalker_trader_restock_warn", "30",
        FCVAR_ARCHIVE, "Seconds before a re-roll during which the trader refuses to trade. Capped at half the interval.", 0)

    local function Log(msg)
        if Corpus and isfunction(Corpus.Log) then Corpus.Log("stalker", msg) end
    end

    local function CargoMod()
        if Corpus == nil or not isfunction(Corpus.GetModule) then return nil end
        return Corpus.GetModule("cargo")
    end

    -- ------------------------------------------------------------------
    -- Pools de voz por carpeta de acción (estándar del header). Escaneo
    -- perezoso y cacheado por VoiceDir; mismo contrato que escanea la
    -- persona del demo en lua/autorun/corpus_stalker_sidorovich.lua.
    -- ------------------------------------------------------------------

    local ACCIONES = { "greet_first", "greet", "wait", "bye", "trade_open_first",
                       "trade_open", "trade_done", "trade_fail", "pain", "death" }
    local FALLBACK = { greet_first = "greet", trade_open_first = "trade_open" }
    local EXT_OK   = { ogg = true, wav = true, mp3 = true }

    local poolsPorDir = {}
    local function PoolsDe(dir)
        local pools = poolsPorDir[dir]
        if pools then return pools end
        pools = {}
        local n = 0
        for _, accion in ipairs(ACCIONES) do
            local set = {}
            local archivos = file.Find("sound/" .. dir .. "/" .. accion .. "/*", "GAME") or {}
            for _, f in ipairs(archivos) do
                local ext = string.lower(string.GetExtensionFromFilename(f) or "")
                if EXT_OK[ext] then set[#set + 1] = dir .. "/" .. accion .. "/" .. f end
            end
            if #set > 0 then
                pools[accion] = set
                n = n + #set
            end
        end
        if Corpus and Corpus.Log then
            Corpus.Log("stalker", "trader '" .. dir .. "': " .. n
                .. " líneas de voz en carpetas de acción")
        end
        poolsPorDir[dir] = pools
        return pools
    end

    -- ------------------------------------------------------------------
    -- Duración de una línea = lo que dura su audio, para que la boca pare
    -- cuando el audio para. SoundDuration miente con .ogg en Windows y el
    -- estimado por tamaño sobreestimaba un 60-90% (reporte del autor: la
    -- boca no coincidía con el fin del audio). La duración de un .ogg se
    -- lee EXACTA del propio contenedor: granule de la última página Ogg ÷
    -- sample rate del header Vorbis — validado offline contra las 31 voces
    -- (0,52-13,78 s @ 44,1 kHz). Vale para cualquier .ogg que un tercero
    -- suelte en las carpetas del estándar. Fallback (.wav/.mp3 o parse
    -- fallido): SoundDuration → tamaño/7500.
    -- ------------------------------------------------------------------

    local function DuracionOgg(ruta)
        local raw = file.Read("sound/" .. ruta, "GAME")
        if not isstring(raw) or #raw < 58 then return nil end

        -- sample rate: paquete de identificación Vorbis ("\1vorbis"),
        -- u32 little-endian tras version(4) + channels(1)
        local id = raw:find("\1vorbis", 1, true)
        if id == nil then return nil end
        local b1, b2, b3, b4 = raw:byte(id + 12, id + 15)
        if b4 == nil then return nil end
        local rate = b1 + b2 * 256 + b3 * 65536 + b4 * 16777216
        if rate <= 0 then return nil end

        -- granule (samples totales): último "OggS" que parezca página real
        -- (version 0 en el byte +4). Con los 6 bytes bajos del u64 alcanza:
        -- 2^48 samples a 44,1 kHz son dos siglos de audio.
        local pagina, pos = nil, 1
        while true do
            local f = raw:find("OggS", pos, true)
            if f == nil then break end
            if raw:byte(f + 4) == 0 then pagina = f end
            pos = f + 1
        end
        if pagina == nil or pagina + 13 > #raw then return nil end
        local granule = 0
        for i = 5, 0, -1 do
            granule = granule * 256 + raw:byte(pagina + 6 + i)
        end

        local dur = granule / rate
        -- un "OggS" falso en el medio de los datos daría cualquier cosa:
        -- fuera de rango sano, que decida la cadena de fallback
        if dur <= 0 or dur > 600 then return nil end
        return dur
    end

    local duracionCache = {}
    local function DuracionDe(snd)
        local dur = duracionCache[snd]
        if dur then return dur end
        if snd:sub(-4):lower() == ".ogg" then dur = DuracionOgg(snd) end
        if not isnumber(dur) or dur <= 0 then dur = SoundDuration(snd) end
        if not isnumber(dur) or dur <= 0.05 then
            local bytes = file.Size("sound/" .. snd, "GAME")
            dur = (isnumber(bytes) and bytes > 0)
                and math.Clamp(bytes / 7500, 0.5, 12) or 2
        end
        duracionCache[snd] = dur
        return dur
    end

    -- El trader de Cargo dejó de llevar encima sus referencias vivas (la tabla
    -- del contenedor, el set de viewers): eran basura que el duplicator copiaba
    -- en cada gm_save. Lo que antes se leía del campo ahora se pide por la API
    -- pública del módulo, con el lazy check de siempre (COR-5): sin Cargo
    -- montado esto degrada en silencio, nunca revienta.
    local function TradeAPI(nombre)
        local cargo = Corpus and Corpus.GetModule and Corpus.GetModule("cargo")
        local fn = cargo and cargo.Trade and cargo.Trade[nombre]
        return isfunction(fn) and fn or nil
    end

    local function Comerciando(ent, ply)
        local fn = TradeAPI("HasViewer")
        return fn ~= nil and fn(ent.CargoTrader, ply) == true
    end

    -- Clave de TODO registro por jugador que viva encima de la entidad: el
    -- SteamID64, jamás el Player — el duplicator mergea `ent:GetTable()` entero
    -- (ver el comentario de SidorVozThink). Vale para SidorVoz, SidorSaludados,
    -- SidorTradeSaludados y SidorTradeHubo, que son las cuatro que hay.
    local function ClaveDe(ply)
        return IsValid(ply) and (ply:SteamID64() or tostring(ply)) or nil
    end

    -- Sello de sesión: una tabla NUEVA por carga de mapa, porque este archivo
    -- se re-ejecuta en cada arranque. Sirve para reconocer estado que llegó de
    -- un savegame — ver ENT:SidorIniciarSesion más abajo.
    local SESION = {}

    -- Segundo candado, y este NO depende de nada externo: mira los valores.
    -- Cada cota sale de la línea exacta que escribe ese plazo —no de una
    -- estimación— y ninguno puede caer más adelante que su cota dentro de UNA
    -- sesión, porque el tiempo solo avanza:
    --   SidorParpadeoDesde = ahora                  (SidorCara)
    --   SidorProxUso       = ahora + 0,4            (SidorUsar)
    --   SidorProxLento     = ahora + 0,25           (Think)
    --   SidorProxParpadeo  = ahora + Rand(2,5 .. 6) (SidorCara)
    --   SidorProxIdle      = ahora + Rand(12 .. 25) (Think)
    --   SidorStockDesde    = ahora                  (SidorSembrarSiVacio / re-sorteo)
    -- Si alguno rompe su cota, el valor vino de otra partida y punto.
    local function PlazoImposible(ent, ahora)
        return (ent.SidorParpadeoDesde or 0) > ahora
            or (ent.SidorProxUso or 0)       > ahora + 0.4
            or (ent.SidorProxLento or 0)     > ahora + 0.25
            or (ent.SidorProxParpadeo or 0)  > ahora + 6
            or (ent.SidorProxIdle or 0)      > ahora + 25
            or (ent.SidorStockDesde or 0)    > ahora
    end

    function ENT:SpawnFunction(ply, tr, clase)
        if not tr.Hit then return end
        local ent = ents.Create(clase)
        if not IsValid(ent) then return end
        -- el origen del NextBot es la planta de los pies: directo al piso,
        -- de frente a quien lo spawnea
        ent:SetPos(tr.HitPos + tr.HitNormal * 2)
        ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
        ent:Spawn()
        ent:Activate()
        return ent
    end

    function ENT:Initialize()
        local modelo = self.TraderModel
        if not isstring(modelo) or not file.Exists(modelo, "GAME") then
            modelo = MODELO_FALLBACK
        end
        -- misma trampa de precache que paga el demo: un modelo que el mapa
        -- nunca usó no está en la tabla (precachear también lo networkea)
        util.PrecacheModel(modelo)
        self:SetModel(modelo)

        self:SetMaxHealth(self.TraderHealth)
        self:SetHealth(self.TraderHealth)
        self:SetBloodColor(BLOOD_COLOR_RED)
        self:SetUseType(SIMPLE_USE)

        -- asiento exacto en el piso: el respawn programático llega con un
        -- SetPos arbitrario; la locomoción (gravedad) lo mantiene después
        local tr = util.TraceLine({
            start = self:GetPos() + Vector(0, 0, 16),
            endpos = self:GetPos() - Vector(0, 0, 512),
            mask = MASK_SOLID, filter = self,
        })
        if tr.Hit then self:SetPos(tr.HitPos) end

        self.SidorSpawnPos = self:GetPos()
        self.SidorSpawnAng = self:GetAngles()

        self:SidorIniciarSesion()
    end

    -- ------------------------------------------------------------------
    -- ESTADO DE SESIÓN, y por qué se verifica AL LEER y no solo al nacer.
    --
    -- Nada de lo de acá abajo vale entre partidas: son índices resueltos
    -- contra el modelo montado y plazos de `CurTime()`, que ARRANCA DE CERO al
    -- cargar un mapa. Un savegame devuelve los campos planos de la entidad, así
    -- que un plazo heredado queda en el futuro para siempre y un índice de flex
    -- heredado puede apuntar a otra cosa.
    --
    -- La 1.ª versión de este arreglo reiniciaba en `Initialize` y **NO alcanzó**
    -- (reporte en juego 2026-07-26, 2.ª corrida del check Q3 de Cargo, con
    -- foto): el trader seguía sordo al USE, con la boca en movimiento y la cara
    -- estirada. Ese fallo ES la evidencia — si el reset de `Initialize`
    -- hubiese quedado en pie, `SidorProxUso = 0` habría destrabado el USE. No
    -- lo hizo, así que los datos del save aterrizan DESPUÉS. Reiniciar al nacer
    -- depende de un orden que no controlamos.
    --
    -- Por eso el sello: `SESION` es una tabla nueva por carga de mapa (este
    -- archivo se re-ejecuta en cada arranque), y todo estado se marca con ella.
    -- Un estado que llega de un savegame trae OTRO sello —o ninguno— y se
    -- descarta en la primera lectura, sin importar cuándo lo escribieron.
    -- Es la misma forma que arregló el contenedor de Cargo (su CHANGELOG,
    -- entry 45, PARCHE 6): no confiar en el campo, validarlo contra lo vivo.
    -- ------------------------------------------------------------------

    function ENT:SidorIniciarSesion()
        self.SidorSesion = SESION

        -- índices contra el modelo montado: se resuelven, jamás se heredan
        self.SidorIdles = {}
        for _, nombre in ipairs(self.TraderIdles or {}) do
            local seq = self:LookupSequence(nombre)
            if seq and seq > 0 then self.SidorIdles[#self.SidorIdles + 1] = seq end
        end
        if #self.SidorIdles == 0 then
            local seq = self:LookupSequence("idle_subtle")
            if seq and seq > 0 then self.SidorIdles = { seq } end
        end
        if #self.SidorIdles > 0 then
            self:SidorTocarIdle(self.SidorIdles[math.random(#self.SidorIdles)])
        end

        -- Un peso de flex escrito con basura NO se limpia solo: este código
        -- solo vuelve a escribir los DOS índices que conoce, así que cualquier
        -- otro morph que haya quedado movido se queda movido para siempre — y
        -- si el nombre no aparece en este modelo, el índice queda nil y ni
        -- siquiera esos dos se reescriben. Por eso se ceran TODOS acá, antes de
        -- volver a resolverlos: es lo único que garantiza una cara neutra sin
        -- importar qué se escribió antes.
        for i = 0, self:GetFlexNum() - 1 do
            self:SetFlexWeight(i, 0)
        end

        -- flexes: detección por nombre, nunca asunción — el sidor.mdl trae
        -- exactamente blink y mouth; el citizen fallback no las tiene y calla.
        -- Heredar el índice es lo que deforma la cara: el mismo número señala
        -- otro morph si el modelo que cargó no es el que guardó la partida.
        self.SidorFlexBlink, self.SidorFlexMouth = nil, nil
        for i = 0, self:GetFlexNum() - 1 do
            local nombre = string.lower(self:GetFlexName(i) or "")
            if nombre:find("blink", 1, true) then
                self.SidorFlexBlink = i
            elseif nombre:find("mouth", 1, true) then
                self.SidorFlexMouth = i
            end
        end

        -- pose params de cabeza (male_shared): -1 si el modelo no las trae
        self.SidorPPYaw = self:LookupPoseParameter("head_yaw")
        self.SidorPPPitch = self:LookupPoseParameter("head_pitch")
        self.SidorYaw, self.SidorPitch = 0, 0

        -- plazos: todos relativos al AHORA de esta sesión
        self.SidorProxIdle = CurTime() + math.Rand(12, 25)
        self.SidorProxParpadeo = CurTime() + math.Rand(1, 4)
        self.SidorParpadeoDesde = 0
        self.SidorProximaLinea = 0
        self.SidorHablaHasta = 0
        self.SidorProxUso = 0
        self.SidorProxLento = 0
        self.SidorProxDolor = 0

        -- Reloj del re-sorteo. nil = todavía no hay repisa sembrada, y es el
        -- estado correcto tras cargar una partida: el reloj vuelve a arrancar
        -- en el primer uso, que es cuando este código sabe que hay stock.
        self.SidorStockDesde = nil
        self.SidorRestockAvisado = false

        -- contabilidad de voz + la marca de muerte, que heredada en true
        -- dejaría un trader muerto de pie, mudo al USE y sordo a OnKilled
        self.SidorVoz = {}
        self.SidorSaludados = {}
        self.SidorTradeSaludados = {}
        self.SidorTradeHubo = {}
        self.SidorMuerto = false
    end

    -- El guard, con DOS candados, y el segundo existe porque el primero falló
    -- en juego. El sello depende de que el duplicator restaure —o no— un campo
    -- concreto, y la 4.ª corrida de Q3 mostró que ahí no se puede confiar: los
    -- plazos volvían heredados y el sello no llegaba a delatarlos (se le podía
    -- hablar, porque SidorUsar sí lo disparaba, pero la boca nacía moviéndose y
    -- el parpadeo nunca ocurría). El candado por VALOR no puede fallar: no
    -- pregunta de dónde vino el dato, pregunta si el dato es posible.
    function ENT:SidorSesionViva()
        if self.SidorSesion ~= SESION then
            self:SidorIniciarSesion()
            return
        end
        if PlazoImposible(self, CurTime()) then self:SidorIniciarSesion() end
    end

    -- Sidorovich no camina: atiende su búnker. Sin navmesh tampoco hay ruta.
    function ENT:RunBehaviour()
        while true do coroutine.wait(1) end
    end

    -- Arranque de secuencia con playback FLUIDO: receta calcada de
    -- PlaySequenceAndWait del base_nextbot (sin el wait — acá la rotación es
    -- por timer). El ResetSequenceInfo() es la pieza clave: re-sincroniza el
    -- playback y el cliente avanza la animación solo; sin él, el render queda
    -- pegado al ciclo networkeado del update decimado (~10 Hz) del server.
    function ENT:SidorTocarIdle(seq)
        self:SetSequence(seq)
        self:ResetSequenceInfo()
        self:SetCycle(0)
        self:SetPlaybackRate(1)
    end

    -- ------------------------------------------------------------------
    -- Voz: una sola boca (CHAN_VOICE reemplaza la línea en curso) + registro
    -- de hasta cuándo dura el audio, que es lo que anima la boca. Acción sin
    -- sonidos (o con fallback vacío): devuelve false en silencio, jamás error.
    -- ------------------------------------------------------------------

    function ENT:SidorSpeak(accion, forzar)
        local pools = PoolsDe(self.VoiceDir)
        local set = pools[accion]
        if set == nil and FALLBACK[accion] then set = pools[FALLBACK[accion]] end
        if not istable(set) or #set == 0 then return false end
        if not forzar and CurTime() < (self.SidorProximaLinea or 0) then return false end
        local snd = set[math.random(#set)]
        self:EmitSound(snd, 75, 100, 1, CHAN_VOICE)
        self.SidorHablaHasta = CurTime() + DuracionDe(snd)
        self.SidorProximaLinea = CurTime() + PAUSA_VOZ
        return true
    end

    -- Proximidad: saludo al entrar al radio (la primera vez con línea propia),
    -- espera cada VoiceWait sin comerciar (nunca con su pantalla abierta),
    -- despedida al irse — histéresis del 15% para que nadie farmee saludos
    -- parado en el borde.
    function ENT:SidorVozThink()
        local radio = self.VoiceRadius
        local r2in, r2out = radio * radio, (radio * 1.15) ^ 2
        local miPos = self:GetPos()

        -- El registro de voz se indexa por SteamID64, NO por el Player: esta
        -- tabla vive ENCIMA de la entidad y duplicator.CopyEntTable mergea
        -- ent:GetTable() entero (solo saca funciones), así que un set con
        -- Players de clave se colaría en cada duplicación y en cada gm_save.
        -- Una clave string es dato plano — SidorSaludados ya usaba esta misma.
        self.SidorVoz = self.SidorVoz or {}
        local conectados = {}
        for _, ply in ipairs(player.GetAll()) do
            local sid = ClaveDe(ply)
            if sid ~= nil then
                conectados[sid] = true
                if ply:Alive() then
                    local st = self.SidorVoz[sid]
                    local d2 = ply:GetPos():DistToSqr(miPos)
                    if st == nil then
                        if d2 <= r2in then
                            if not self.SidorSaludados[sid] and self:SidorSpeak("greet_first") then
                                self.SidorSaludados[sid] = true
                            else
                                self:SidorSpeak("greet")
                            end
                            self.SidorVoz[sid] = { esperaProx = CurTime() + self.VoiceWait }
                        end
                    elseif d2 > r2out then
                        self.SidorVoz[sid] = nil
                        self:SidorSpeak("bye")
                    elseif CurTime() >= st.esperaProx then
                        if not Comerciando(self, ply) then self:SidorSpeak("wait") end
                        st.esperaProx = CurTime() + self.VoiceWait
                    end
                end
            end
        end
        -- el que SE FUE se lleva su estado; el muerto lo conserva, así que
        -- reaparecer frente a Sidorovich no vuelve a disparar el saludo
        for sid in pairs(self.SidorVoz) do
            if not conectados[sid] then self.SidorVoz[sid] = nil end
        end
    end

    -- ------------------------------------------------------------------
    -- Cara: mirada + parpadeo + boca. Corre en BodyUpdate (al ritmo del
    -- update de nextbots); flexes y pose params se networkean solos.
    -- ------------------------------------------------------------------

    function ENT:SidorCara()
        self:SidorSesionViva()
        local dt = FrameTime()
        local ahora = CurTime()

        -- ¿a quién mirar? el jugador vivo más cercano dentro del radio y en
        -- el hemisferio frontal — nada de girar la nuca como búho
        local radio = self.VoiceRadius
        local ojos = self:GetPos() + Vector(0, 0, 60)
        local att = self:LookupAttachment("eyes")
        if att and att > 0 then
            local a = self:GetAttachment(att)
            if a then ojos = a.Pos end
        end

        local objetivo, mejor = nil, radio * radio
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local d2 = ply:GetPos():DistToSqr(self:GetPos())
                if d2 < mejor then
                    local rel = self:WorldToLocalAngles((ply:EyePos() - ojos):Angle())
                    if math.abs(math.NormalizeAngle(rel.y)) <= 85 then
                        objetivo, mejor = ply, d2
                    end
                end
            end
        end

        local quieroYaw, quieroPitch = 0, 0
        if objetivo then
            local rel = self:WorldToLocalAngles((objetivo:EyePos() - ojos):Angle())
            quieroYaw = math.Clamp(math.NormalizeAngle(rel.y), -YAW_MAX, YAW_MAX)
            -- pitch Source: positivo = abajo, misma convención de head_pitch;
            -- si en juego cabecea invertido, se niega este valor
            quieroPitch = math.Clamp(math.NormalizeAngle(rel.p), -PITCH_MAX, PITCH_MAX)
            -- mejor esfuerzo: si el modelo no tiene ojos posables, no-op
            self:SetEyeTarget(objetivo:EyePos())
        end

        self.SidorYaw = math.Approach(self.SidorYaw or 0, quieroYaw, GIRO_VEL * dt)
        self.SidorPitch = math.Approach(self.SidorPitch or 0, quieroPitch, GIRO_VEL * dt)
        if (self.SidorPPYaw or -1) >= 0 then
            self:SetPoseParameter("head_yaw", self.SidorYaw)
        end
        if (self.SidorPPPitch or -1) >= 0 then
            self:SetPoseParameter("head_pitch", self.SidorPitch)
        end

        -- parpadeo real: cierre-apertura triangular de ~0,18 s cada 2,5-6 s
        if self.SidorFlexBlink then
            if ahora >= (self.SidorProxParpadeo or 0) then
                self.SidorParpadeoDesde = ahora
                self.SidorProxParpadeo = ahora + math.Rand(2.5, 6)
            end
            -- La fórmula del triángulo da por sentado que `t` es positivo, y
            -- con un `SidorParpadeoDesde` heredado de otra partida sale
            -- NEGATIVO: entra igual en la rama (porque -495 < 0,18) y el peso
            -- se va a -5500, que dispara los vértices por el lado negativo del
            -- morph. Esa era la cara estirada de la foto (2026-07-26, 3.ª
            -- corrida de Q3).
            -- El rango y el clamp son la RED, no el arreglo: acotar un `t`
            -- imposible dejó de deformar la cara pero también mató el parpadeo,
            -- porque el peso quedaba clavado en 0 mientras el plazo heredado
            -- siguiera ahí (4.ª corrida: «arreglaron los flexes deformes, pero
            -- no parpadea»). Lo que lo arregla de verdad es que ese plazo no
            -- sobreviva: PlazoImposible, arriba.
            local t = ahora - (self.SidorParpadeoDesde or 0)
            local peso = (t >= 0 and t < PARPADEO_T)
                and (1 - math.abs(t / PARPADEO_T * 2 - 1)) or 0
            self:SetFlexWeight(self.SidorFlexBlink, math.Clamp(peso, 0, 1))
        end

        -- boca: aletea 0→1 mientras dura el audio de la línea en curso
        if self.SidorFlexMouth then
            local peso = 0
            if ahora < (self.SidorHablaHasta or 0) then
                peso = math.abs(math.sin(ahora * 15))
            end
            self:SetFlexWeight(self.SidorFlexMouth, peso)
        end
    end

    -- Las cuatro entradas que leen estado de sesión preguntan primero. SidorCara
    -- y Think corren cada frame, así que un estado forastero muere en el primer
    -- fotograma tras cargar la partida; SidorUsar y OnKilled lo hacen porque son
    -- los que quedaban colgados (el candado de USE y la marca de muerte).
    function ENT:BodyUpdate()
        -- quieto: avanza la secuencia a mano, nunca BodyMoveXY. Con animación
        -- client-side esto solo mantiene el ciclo del server como respaldo.
        self:FrameAdvance()
        self:SidorCara()
    end

    function ENT:Think()
        -- REGLA de nextbot (verificada contra DrGBase en dev/other, CRG-24:
        -- su Think jamás llama NextThink ni devuelve true): el Think de un
        -- nextbot NO SE FRENA — el engine cuelga de esa cadena los updates
        -- del bot (BodyUpdate → FrameAdvance, que avanza UN paso fijo por
        -- llamada). El NextThink(CurTime() + 0.5) que vivió acá dejaba la
        -- animación a ~3% de velocidad: el "lentísimo" de las pasadas 1-3.
        -- Lo lento corre detrás de un gate interno, como hace DrGBase.
        self:SidorSesionViva()
        if CurTime() >= (self.SidorProxLento or 0) then
            self.SidorProxLento = CurTime() + 0.25

            -- rotación de idles por TIMER. Todas las poses son de pie y
            -- parecidas: el corte entre una y otra no salta a la vista.
            if CurTime() >= (self.SidorProxIdle or 0) and #(self.SidorIdles or {}) > 0 then
                self:SidorTocarIdle(self.SidorIdles[math.random(#self.SidorIdles)])
                self.SidorProxIdle = CurTime() + math.Rand(12, 25)
            end

            self:SidorVozThink()

            -- el re-sorteo cuelga del MISMO gate lento (4 Hz): un timer por
            -- trader sería un segundo reloj que el sello de sesión no sabe
            -- invalidar, y la resolución de 0,25 s le sobra a una ventana que
            -- se mide en decenas de segundos
            self:SidorRestockThink()
        end
    end

    -- ------------------------------------------------------------------
    -- STOCK SORTEADO (roadmap [1] de este repo, diseño votado 2026-08-18).
    --
    -- LA REGLA ES UNA REGLA Y NO UNA LISTA: el trader vende TODO lo que declare
    -- la categoría que él declara, así que una comida (o una medicina, o una
    -- munición) que registre mañana cualquier addon entra sola. Eso exige
    -- RECORRER el registro de Cargo, cosa que hasta el 2026-08-18 no tenía
    -- puerta pública: `Items.GetAll`/`ByCategory` son CRG-69 y existen para
    -- este consumidor.
    --
    -- UNA LISTA VACÍA ES AMBIGUA Y LA API NO PUEDE DESAMBIGUARLA — categoría
    -- sin registrar, categoría con cero ítems y typo en el nombre son la MISMA
    -- respuesta. Por eso cada sorteo LOGUEA LA CUENTA y no la ausencia: sin
    -- eso, «el addon no está montado» y «mi filtro no matchea nada» se leen
    -- exactamente igual. Es contrato de esa API, no prolijidad.
    -- ------------------------------------------------------------------

    -- ¿este id entra al sorteo? Exclusión por PREFIJO (ENT.TraderStockExcluir).
    local function Excluido(ent, id)
        for _, pre in ipairs(ent.TraderStockExcluir or {}) do
            if isstring(pre) and pre ~= "" and id:sub(1, #pre) == pre then return true end
        end
        return false
    end

    -- Frase de ARC9 por su ID, nunca por su texto. Devuelve nil si ARC9 no está
    -- montado o si la frase no existe — y el caller NO se cae a comparar el
    -- string a mano: una frase que no resuelve deja su cubo vacío, que es
    -- honesto, en vez de matchear cualquier cosa.
    local function FraseARC9(fid)
        if not istable(ARC9) or not isfunction(ARC9.GetPhrase) then return nil end
        local txt = ARC9:GetPhrase(fid)
        return (isstring(txt) and txt ~= "") and txt or nil
    end

    -- Subcategoría declarada de una clase, CAMINANDO LA CADENA `Base`.
    -- `weapons.GetList()` devuelve las tablas CRUDAS (leído en la fuente del
    -- engine, includes/modules/weapons.lua: sólo `Get(name)` corre
    -- TableInherit), así que un arma que HEREDA su SubCategory leería nil y
    -- caería al cubo equivocado sin dar un solo error. Medido sobre los packs
    -- de dev/other: 9 de 99 spawnables no la declaran — `arc9_eft_cr50ds`
    -- hereda de `arc9_eft_cr200ds`, que sí. Y `weapons.Get` no sirve acá:
    -- copia el árbol de attachments ENTERO por arma, y son ~90.
    local function SubCategoriaDe(clase)
        local visto, actual = {}, clase
        for _ = 1, 16 do -- tope duro: una cadena Base circular colgaría el server
            if actual == nil or visto[actual] then return nil end
            visto[actual] = true
            local swep = weapons.GetStored(actual)
            if not istable(swep) then return nil end
            if isstring(swep.SubCategory) and swep.SubCategory ~= "" then
                return swep.SubCategory
            end
            actual = swep.Base
        end
        return nil
    end

    -- Sorteo de CLASES de arma repartido en cubos (el bloque `armas` del plan).
    --
    -- LA TRAMPA, y es un falso verde perfecto: el valor de `SWEP.SubCategory`
    -- es una frase LOCALIZADA con un dígito de orden pegado adelante — en
    -- inglés `eft_subcat_melee` vale "9Melee weapons" y en checo
    -- "9Chladné zbraně". Comparar contra el texto matchea CERO, sin error, y
    -- el cubo queda vacío exactamente igual que si el pack no estuviera
    -- instalado. La clave estable es el ID DE LA FRASE: se resuelve la MISMA
    -- llamada que hizo el SWEP, así que coincide en cualquier idioma.
    -- (`SWEP.Category` no sirve para nada acá: es uniforme en todo el pack.)
    function ENT:SidorArmasSorteadas(cfg)
        if not istable(cfg) then return {} end
        local prefijo = isstring(cfg.prefijo) and cfg.prefijo or ""
        local cubos = cfg.cubos or {}
        local quien = tostring(self.TraderName)

        local duenio, resto = {}, nil
        for i, cubo in ipairs(cubos) do
            if cubo.resto then resto = i end
            for _, fid in ipairs(cubo.subcats or {}) do
                local txt = FraseARC9(fid)
                if txt == nil then
                    Log("trader '" .. quien .. "': la frase ARC9 '" .. tostring(fid)
                        .. "' no resuelve; su cubo pierde esa subcategoría")
                else
                    duenio[txt] = i
                end
            end
        end

        local urnas = {}
        for i = 1, #cubos do urnas[i] = {} end

        local padron = 0
        for _, swep in ipairs(weapons.GetList()) do
            local clase = swep.ClassName
            -- `Spawnable == true` y no `~= false`: las dos bases del pack
            -- (arc9_eft_base, arc9_eft_grenade_base) están en la lista y la
            -- declaran en false, y una tabla que no la declara lee nil
            if isstring(clase) and swep.Spawnable == true
                and clase:sub(1, #prefijo) == prefijo then
                padron = padron + 1
                local sub = SubCategoriaDe(clase)
                local i = (sub ~= nil) and duenio[sub] or nil
                i = i or resto
                if i ~= nil then urnas[i][#urnas[i] + 1] = clase end
            end
        end

        local salida = {}
        for i, cubo in ipairs(cubos) do
            local urna = urnas[i]
            local candidatas = #urna
            local pedidas = math.max(math.floor(cubo.n or 0), 0)
            local n = math.min(pedidas, candidatas)
            for _ = 1, n do
                -- SIN REPOSICIÓN: la misma clase dos veces en la misma repisa se
                -- lee como un bug, y además las armas no son stackeables
                local k = math.random(#urna)
                salida[#salida + 1] = urna[k]
                table.remove(urna, k)
            end
            Log("trader '" .. quien .. "': cubo de armas " .. i .. " -> " .. candidatas
                .. " candidatas, " .. n .. " sorteadas de " .. pedidas .. " pedidas")
        end
        Log("trader '" .. quien .. "': padrón de armas '" .. prefijo .. "*' = "
            .. padron .. " clases spawnables")
        return salida
    end

    -- Arma la lista de LÍNEAS de stock. Una línea tiene la misma forma que come
    -- `opts.stock` de AttachTrader — { id = , count = } — y se usa en los DOS
    -- caminos (la siembra inicial y cada re-sorteo), para que la repisa del
    -- primer día y la del minuto veinte no salgan de dos códigos distintos.
    function ENT:SidorSortearLineas()
        local lineas = {}
        local cargo = CargoMod()
        if cargo == nil or cargo.Items == nil then return lineas end
        local plan = self:SidorPlan()
        local quien = tostring(self.TraderName)
        local esComerciable = cargo.Trade and cargo.Trade.IsTradeable
        local porCategoria = cargo.Items.ByCategory

        for _, spec in ipairs(plan.categorias or {}) do
            if not isfunction(porCategoria) then
                Log("trader '" .. quien .. "': Cargo sin Items.ByCategory (CRG-69): categoría '"
                    .. tostring(spec.cat) .. "' salteada")
            else
                local defs = porCategoria(spec.cat) or {}
                local lo = math.min(spec.min or 1, spec.max or 1)
                local hi = math.max(spec.min or 1, spec.max or 1)
                local puestas, excluidas, sinPrecio = 0, 0, 0
                for _, def in ipairs(defs) do
                    local id = def.id or ""
                    if Excluido(self, id) then
                        excluidas = excluidas + 1
                    elseif isfunction(esComerciable) and not esComerciable(def) then
                        -- sin `value` el server se NIEGA a moverlo (Cargo_Trade §4:
                        -- ausencia de value = "no está a la venta", NO "gratis"), así
                        -- que sembrarlo sería poner en la repisa algo que no se puede
                        -- comprar. Se cuenta y se declara.
                        sinPrecio = sinPrecio + 1
                    else
                        local cant = math.random(lo, hi)
                        local tam = def.max_stack
                        if spec.stacks and def.class == "stackable"
                            and isnumber(tam) and tam >= 1 then
                            -- "1 a 3 STACKS" son N LÍNEAS de `max_stack`, NO una línea
                            -- de max_stack × N: el seed recorre las líneas y crea UNA
                            -- entrada por línea, así que tres líneas de 120 dan tres
                            -- stacks de 120 — que es literalmente lo pedido. La otra
                            -- forma crearía una entrada de 360 por encima del propio
                            -- max_stack del def, y si Cargo la parte o no NO está
                            -- medido. Esta forma no necesita esa respuesta.
                            for _ = 1, cant do
                                lineas[#lineas + 1] = { id = id, count = math.floor(tam) }
                            end
                        else
                            lineas[#lineas + 1] = { id = id, count = cant }
                        end
                        puestas = puestas + 1
                    end
                end
                Log("trader '" .. quien .. "': categoría '" .. tostring(spec.cat) .. "' -> "
                    .. #defs .. " defs registradas, " .. puestas .. " sembradas, "
                    .. excluidas .. " excluidas por prefijo, " .. sinPrecio .. " sin `value`")
            end
        end

        if istable(plan.armas) then
            -- El id de un arma NO se adivina: una capturada no tiene código
            -- propio y su def es autogen, así que no está en el catálogo hasta
            -- que alguien tuvo el arma en la mano. `Capture.ItemIdFor` (CRG-70)
            -- la acuña si hace falta y contesta nil MÁS UN MOTIVO — se loguea el
            -- motivo, no la ausencia: sin eso, "el pack no está montado" y "la
            -- clase se rechazó" se leen igual.
            local idPara = cargo.Capture and cargo.Capture.ItemIdFor
            if not isfunction(idPara) then
                Log("trader '" .. quien .. "': Cargo sin Capture.ItemIdFor (CRG-70): no se sortean armas")
            else
                for _, clase in ipairs(self:SidorArmasSorteadas(plan.armas)) do
                    local id, motivo = idPara(clase)
                    if id == nil then
                        Log("trader '" .. quien .. "': arma '" .. clase .. "' descartada: " .. tostring(motivo))
                    elseif Excluido(self, id) then
                        Log("trader '" .. quien .. "': arma '" .. clase .. "' excluida por prefijo (" .. id .. ")")
                    elseif isfunction(esComerciable) and not esComerciable(cargo.Items.Get(id)) then
                        -- una clase sin entrada en la tabla de precios de Cargo queda
                        -- con `value` nil a propósito (su comentario: mejor un agujero
                        -- honesto que un precio inventado). No se siembra.
                        Log("trader '" .. quien .. "': arma '" .. clase .. "' sin `value` (" .. id .. "): no se siembra")
                    else
                        lineas[#lineas + 1] = { id = id, count = 1 }
                    end
                end
            end
        end

        return lineas
    end

    -- Materializa las líneas DENTRO de la lista de ítems del contenedor, con las
    -- mismas dos reglas del seed de AttachTrader: un stackeable es UNA entrada
    -- con su cuenta; un único es una INSTANCIA por unidad.
    local function Sembrar(stock, lineas, cargo)
        for _, linea in ipairs(lineas) do
            local def = cargo.Items.Get(linea.id or "")
            local cant = math.max(math.floor(linea.count or 1), 1)
            if def == nil then
                Log("stock desconocido '" .. tostring(linea.id) .. "', ignorado")
            elseif def.class == "stackable" then
                stock[#stock + 1] = { id = def.id, count = cant }
            else
                for _ = 1, cant do
                    stock[#stock + 1] = { id = def.id, uid = cargo.Instances.Create(def.id) }
                end
            end
        end
    end

    -- Los blobs recién acuñados hay que RENDERIZARLOS antes de que nada pueda
    -- guardar el mapa: una instancia que nadie comerció todavía viajaría al
    -- savegame como una entrada SIN blob y volvería como el fantasma que la
    -- degradación honesta descarta. `AttachTrader` hace exactamente esto después
    -- de sembrar, y el re-sorteo es la OTRA puerta por la que ahora entra stock
    -- nuevo.
    --
    -- DE DÓNDE SALE EL `cont`, dicho porque es lo único de este archivo que toca
    -- algo que Cargo no publicó para esto: `Containers.Save` es pública y pide
    -- el CONTENEDOR, pero desde afuera sólo hay puerta a su lista de ítems
    -- (`Trade.StockOf`). Se usa el marcador que `Containers.Attach` deja EN ESTA
    -- ENTIDAD, y sólo inmediatamente después de un AttachTrader válido de esta
    -- sesión. La superficie limpia sería un `Trade.ContainerOf(trader)`: queda
    -- PEDIDO en el roadmap de Cargo y no se escribe desde acá (STK-1). Sin él
    -- esto degrada a no renderizar, que es lo que pasaba antes.
    local function Renderizar(ent, cargo)
        local cont = ent.CargoContainer
        if not istable(cont) then return end
        if cargo.Containers and isfunction(cargo.Containers.Save) then
            cargo.Containers.Save(cont)
        end
    end

    -- El plan, normalizado: un trader que no define el método (o lo define
    -- devolviendo cualquier cosa) queda en la rama fija sin reventar.
    function ENT:SidorPlan()
        local plan = isfunction(self.TraderStockPlan) and self:TraderStockPlan() or nil
        return istable(plan) and plan or {}
    end

    function ENT:SidorSortea()
        local plan = self:SidorPlan()
        return (istable(plan.categorias) and #plan.categorias > 0)
            or istable(plan.armas)
    end

    -- Siembra inicial de la rama sorteada. `AttachTrader` sólo siembra un trader
    -- VACÍO —su comentario lo dice: volver a llamarlo con otro stock no
    -- re-abastece nada—, así que la misma condición se pregunta acá: un
    -- contenedor que volvió lleno de un savegame no se pisa.
    function ENT:SidorSembrarSiVacio()
        local cargo = CargoMod()
        local trader = self.CargoTrader
        if cargo == nil or trader == nil then return end
        local stockFn = TradeAPI("StockOf")
        local stock = stockFn and stockFn(trader) or nil
        if not istable(stock) then return end

        -- LA CONDICIÓN ES "TODAVÍA NO SEMBRÓ", NO "ESTÁ VACÍO", y la diferencia
        -- es un agujero de economía: esto corre en CADA +USE, así que preguntar
        -- por `#stock == 0` le regalaría una repisa nueva al que le compre TODO
        -- —bastaría vaciarlo y volver a apretar E— y el reloj de los veinte
        -- minutos no gobernaría nada. El marcador de "ya sembró" es el reloj
        -- mismo: un trader drenado se queda drenado hasta su re-sorteo.
        if self.SidorStockDesde ~= nil then return end

        -- Un contenedor que volvió lleno de un savegame no se pisa: la misma
        -- condición que `AttachTrader` pregunta para su propio seed.
        if #stock == 0 then
            Sembrar(stock, self:SidorSortearLineas(), cargo)
            Renderizar(self, cargo)
        end

        -- EL RELOJ ARRANCA CUANDO HAY REPISA, no en el Initialize: un trader
        -- recién respawneado no puede re-sortear un segundo después. Y si el
        -- stock volvió de un savegame, arranca en el primer uso tras cargar, que
        -- es el primer momento en que este código sabe que hay algo que
        -- re-sortear.
        self.SidorStockDesde = CurTime()
    end

    -- ------------------------------------------------------------------
    -- RE-SORTEO, y el diseño entero cabe en una frase: UN SOLO RELOJ Y NADA LO
    -- REINICIA. Ni vender ni abrir la ventana lo tocan. El voto del 2026-08-17
    -- —«vender reinicia el reloj»— quedó DEROGADO el 2026-08-18 por su propio
    -- motivo: lo que dolía era perder lo vendido a los diez segundos, y eso lo
    -- resuelve el AVISO de la ventana de cierre, no un reset. Un restock que no
    -- se puede diferir no tiene nada que bloquear — el exploit no se acota, no
    -- existe — y de yapa el evento se vuelve VISIBLE.
    --
    -- LA VENTANA DE CIERRE son los últimos N segundos antes del re-sorteo. Al
    -- entrar, UNA sola vez: se expulsa a quien esté mirando, se le avisa en
    -- pantalla y el trader habla. Durante la ventana el +USE no abre.
    --
    -- Y ESTO ES CONSECUENCIA DEL DISEÑO, NO SUERTE: como se expulsa ANTES de
    -- re-sortear, NADIE está mirando cuando el stock cambia, así que no hace
    -- falta ningún re-sync de viewers — que además no existe, porque el
    -- `SyncViewers` de Cargo es local.
    --
    -- COSTO DECLARADO, para que no se descubra en juego: el trader queda
    -- inhabilitado la ventana entera, un 2,5 % del ciclo con los defaults (30 s
    -- sobre 1200). El autor lo eligió sabiéndolo.
    -- ------------------------------------------------------------------

    -- La ventana TIENE que quedar por debajo del intervalo: un valor >= al
    -- intervalo dejaría al trader cerrado PARA SIEMPRE, y eso no puede depender
    -- de que nadie escriba mal una convar. El tope es la mitad. El recorte se
    -- loguea una vez por par de valores — un log por tick sería peor que el
    -- defecto que avisa.
    local avisoUltimo = nil
    local function PlazosRestock()
        local intervalo = cvarRestock:GetFloat()
        if not isnumber(intervalo) or intervalo <= 0 then return nil end
        local pedido = math.max(cvarAviso:GetFloat() or 0, 0)
        local aviso = math.min(pedido, intervalo * 0.5)
        local clave = intervalo .. "/" .. pedido
        if aviso < pedido and avisoUltimo ~= clave then
            avisoUltimo = clave
            Log("corpus_stalker_trader_restock_warn " .. pedido .. " s no cabe en un intervalo de "
                .. intervalo .. " s: se usa " .. aviso .. " s")
        end
        return intervalo, aviso
    end

    -- Segundos que faltan para el re-sorteo, o nil si no hay re-sorteo (convar
    -- en 0, o repisa todavía sin sembrar). Los plazos se calculan contra el
    -- valor VIVO de la convar y no contra uno congelado al sembrar: bajarla para
    -- verificar tiene que surtir efecto en el ciclo en curso.
    function ENT:SidorRestockRestante()
        if self.SidorStockDesde == nil then return nil end
        local intervalo, aviso = PlazosRestock()
        if intervalo == nil then return nil end
        return (self.SidorStockDesde + intervalo) - CurTime(), aviso
    end

    function ENT:SidorRestockCerrado()
        local restante, aviso = self:SidorRestockRestante()
        if restante == nil then return false end
        return restante > 0 and restante <= aviso
    end

    function ENT:SidorAvisarRestock()
        self.SidorRestockAvisado = true

        local trader = self.CargoTrader
        local cargo = CargoMod()

        -- HAY QUE CAPTURAR LA LISTA ANTES DEL ClearViewers: después ya no hay a
        -- quién avisarle. Se pregunta por la API pública (HasViewer) en vez de
        -- leer el set, que es privado.
        local mirando = {}
        local hasFn = TradeAPI("HasViewer")
        if trader ~= nil and hasFn then
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and hasFn(trader, ply) then mirando[#mirando + 1] = ply end
            end
        end

        -- Expulsión FUNCIONAL, hoy, sin tocar Cargo: vaciado el set de viewers,
        -- `ViewedTrader` devuelve nil y el server contesta "The trader is out of
        -- reach." a cualquier intento. Va por el helper perezoso y NUNCA por
        -- `cargo.Trade.ClearViewers` directo: si la entrada #65 de Cargo termina
        -- cambiando esta función, este archivo no toca una línea.
        local clearFn = TradeAPI("ClearViewers")
        if trader ~= nil and clearFn then clearFn(trader) end

        -- DEUDA HEREDADA, y es la misma que el header declara para el trader que
        -- muere con pantallas abiertas: el panel del expulsado queda DIBUJADO
        -- hasta que lo cierre a mano, porque el net `trade_close` es
        -- cliente→server únicamente. Degrada honesto —cualquier acción contesta
        -- "out of reach" y no mueve nada, y la próxima apertura reemplaza el
        -- estado entero y vacía la canasta—, y el aviso explica por qué.
        local noticeFn = cargo and cargo.Inventory and cargo.Inventory.Notice
        if isfunction(noticeFn) then
            for _, ply in ipairs(mirando) do
                noticeFn(ply, self.TraderName .. " is restocking. Come back in a moment.")
            end
        end

        -- Reusa el pool que ya existe (decisión del autor). Hoy `trade_fail`
        -- significa "cerró sin comprar", así que pasa a tener dos sentidos: no
        -- rompe nada y todavía no hay audios. Si algún día se quieren
        -- distinguir, agregar una acción `restock` es UNA línea en ACCIONES más
        -- una carpeta vacía — el estándar es por carpetas justamente para esto.
        self:SidorSpeak("trade_fail", true)
    end

    -- LA TRAMPA AL RE-SORTEAR, y sale del propio OnKilled de más abajo: el stock
    -- se muta por `Trade.StockOf` (público, POR REFERENCIA), pero antes de
    -- vaciarlo hay que borrar las INSTANCIAS de las entradas que tengan `uid`.
    -- Si no, cada re-sorteo filtra blobs en data/ para siempre — y con un
    -- re-sorteo cada veinte minutos eso crece solo. Es el mismo cuidado ya
    -- escrito en este archivo, aplicado a la otra puerta por la que ahora se
    -- borra stock.
    function ENT:SidorReSortear()
        self.SidorStockDesde = CurTime()
        self.SidorRestockAvisado = false

        local cargo = CargoMod()
        local trader = self.CargoTrader
        if cargo == nil or trader == nil then return end
        local stockFn = TradeAPI("StockOf")
        local stock = stockFn and stockFn(trader) or nil
        if not istable(stock) then return end

        if cargo.Instances and isfunction(cargo.Instances.Delete) then
            for _, entry in ipairs(stock) do
                if entry.uid then cargo.Instances.Delete(entry.uid) end
            end
        end
        table.Empty(stock)

        Sembrar(stock, self:SidorSortearLineas(), cargo)
        Renderizar(self, cargo)
        Log("trader '" .. tostring(self.TraderName) .. "': stock re-sorteado, "
            .. #stock .. " entradas en la repisa")
    end

    function ENT:SidorRestockThink()
        local restante, aviso = self:SidorRestockRestante()
        if restante == nil then return end
        if restante <= 0 then
            self:SidorReSortear()
        elseif restante <= aviso then
            if not self.SidorRestockAvisado then self:SidorAvisarRestock() end
        else
            -- el intervalo pudo crecer por convar mientras la ventana corría
            self.SidorRestockAvisado = false
        end
    end

    -- ------------------------------------------------------------------
    -- Comercio: mismo contrato que el demo — AttachTrader perezoso en el
    -- primer uso + OpenFor. Los callbacks de evento los dispara el server
    -- de trade de Cargo sobre CUALQUIER entidad que los defina.
    -- ------------------------------------------------------------------

    function ENT:SidorUsar(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        self:SidorSesionViva()
        if self.SidorMuerto then return end
        -- candado anti doble disparo: ENT.Use y el fallback por KeyPress
        -- pueden llegar el mismo tick
        if CurTime() < (self.SidorProxUso or 0) then return end
        self.SidorProxUso = CurTime() + 0.4

        -- DURANTE LA VENTANA DE CIERRE no abre: habla y sale. SIN `forzar`, o
        -- sea respetando PAUSA_VOZ, para que machacar la E no lo vuelva loco.
        -- Esto es de la entidad y no necesita nada de Cargo.
        if self:SidorRestockCerrado() then
            self:SidorSpeak("trade_fail")
            return
        end

        local cargo = Corpus and Corpus.GetModule and Corpus.GetModule("cargo")
        if cargo == nil or cargo.Trade == nil then return end

        local sortea = self:SidorSortea()
        cargo.Trade.AttachTrader(self, {
            name = self.TraderName,
            buy_mult = self.TraderBuyMult,
            sell_mult = self.TraderSellMult,
            money = self.TraderMoney,
            -- la rama SORTEADA no pasa `opts.stock`: su repisa la siembra
            -- SidorSembrarSiVacio justo abajo, con las mismas líneas que va a
            -- usar cada re-sorteo. La rama fija sigue exactamente como estaba.
            stock = (not sortea) and self.TraderStock or nil,
            -- sesión-only a propósito: al morir el stock se borra y al
            -- respawnear AttachTrader re-siembra un contenedor vacío
        })
        if sortea then self:SidorSembrarSiVacio() end
        cargo.Trade.OpenFor(ply, self)
    end

    function ENT:Use(activator)
        self:SidorUsar(activator)
    end

    -- Los NextBots no siempre reciben el dispatch de +USE del engine:
    -- fallback por KeyPress + eyetrace, con el mismo candado de SidorUsar.
    -- (La pasada 2026-07-24 confirmó que el +USE nativo SÍ llega con este
    -- modelo/hull; el fallback se queda por si otro modelo no lo recibe.)
    hook.Add("KeyPress", "corpus_stalker_sidorovich_use", function(ply, tecla)
        if tecla ~= IN_USE or not IsValid(ply) or not ply:Alive() then return end
        local tr = ply:GetEyeTrace()
        local ent = tr.Entity
        if IsValid(ent) and isfunction(ent.SidorUsar)
            and tr.HitPos:DistToSqr(ply:EyePos()) <= ALCANCE_USO * ALCANCE_USO then
            ent:SidorUsar(ply)
        end
    end)

    function ENT:OnTradeOpened(ply)
        local sid = ClaveDe(ply) or "?"
        self.SidorTradeSaludados = self.SidorTradeSaludados or {}
        if not self.SidorTradeSaludados[sid] and self:SidorSpeak("trade_open_first", true) then
            self.SidorTradeSaludados[sid] = true
        else
            self:SidorSpeak("trade_open", true)
        end
        -- para trade_fail: la sesión abre sin trato concretado todavía
        self.SidorTradeHubo = self.SidorTradeHubo or {}
        self.SidorTradeHubo[sid] = false
        -- sin línea de espera con su pantalla abierta; el reloj vuelve al cerrar
        local st = self.SidorVoz and self.SidorVoz[sid]
        if st then st.esperaProx = math.huge end
    end

    function ENT:OnTradeDealt(ply)
        local sid = ClaveDe(ply) or "?"
        if self.SidorTradeHubo then self.SidorTradeHubo[sid] = true end
        self:SidorSpeak("trade_done", true)
    end

    function ENT:OnTradeClosed(ply)
        local sid = ClaveDe(ply) or "?"
        -- cerró la pantalla sin comprar nada → trade_fail (hoy la carpeta
        -- está vacía a la espera de líneas en ruso: silencio, sin errores)
        if self.SidorTradeHubo and self.SidorTradeHubo[sid] == false then
            self:SidorSpeak("trade_fail", true)
        end
        if self.SidorTradeHubo then self.SidorTradeHubo[sid] = nil end
        local st = self.SidorVoz and self.SidorVoz[sid]
        if st then st.esperaProx = CurTime() + self.VoiceWait end
    end

    -- ------------------------------------------------------------------
    -- Daño y muerte: matable, no looteable. El contenedor de sesión de
    -- Cargo DERRAMA su stock al mundo al removerse (regla de eyección de
    -- corpus_cargo_containers.lua): el stock se BORRA antes del ragdoll —
    -- nada cae al piso y las instancias únicas no quedan huérfanas en
    -- data/. El día que exista el loot de cadáveres (cruce Cortex §9), el
    -- trader sigue sin ser looteable: solo matable para que respawnee.
    -- ------------------------------------------------------------------

    function ENT:OnInjured(dmginfo)
        -- quejido con su propio gap; el golpe letal lo cubre OnKilled
        if self.SidorMuerto or self:Health() <= 0 then return end
        if CurTime() < (self.SidorProxDolor or 0) then return end
        self.SidorProxDolor = CurTime() + PAUSA_DOLOR
        self:SidorSpeak("pain", true)
    end

    function ENT:OnKilled(dmginfo)
        self:SidorSesionViva()
        if self.SidorMuerto then return end
        self.SidorMuerto = true

        local cargo = Corpus and Corpus.GetModule and Corpus.GetModule("cargo")
        local trader = self.CargoTrader
        if trader ~= nil then
            -- el stock ya no se lee de un campo `cont` del trader: es del
            -- CONTENEDOR, y se pide por la API pública (ver TradeAPI arriba)
            local stockFn = TradeAPI("StockOf")
            local stock = stockFn and stockFn(trader) or nil
            if istable(stock) then
                if cargo and cargo.Instances and isfunction(cargo.Instances.Delete) then
                    for _, entry in ipairs(stock) do
                        if entry.uid then cargo.Instances.Delete(entry.uid) end
                    end
                end
                table.Empty(stock)
            end
            -- las pantallas abiertas quedan huérfanas (deuda declarada en el
            -- header): cualquier acción degrada honesto en el server de trade
            local clearFn = TradeAPI("ClearViewers")
            if clearFn then clearFn(trader) end
        end

        -- PROTEGIDO, y no por prolijidad: esta llamada está ANTES del
        -- BecomeRagdoll —tiene que estarlo, los listeners necesitan la entidad
        -- todavía viva— y hook.Run no atrapa errores. Un listener de un tercero
        -- que explote aborta el resto de OnKilled, y como SidorMuerto ya quedó
        -- en true arriba, el trader queda de pie con 0 de vida, mudo al USE y
        -- SIN PODER MORIR NUNCA MÁS: cada golpe posterior vuelve a entrar y
        -- sale por ese mismo return. Pasó en juego (el scavenger de Caliber
        -- llamando GetActiveWeapon sobre este nextbot). ProtectedCall reporta
        -- el error en consola sin frenar la muerte.
        local atacante, inflictor = dmginfo:GetAttacker(), dmginfo:GetInflictor()
        ProtectedCall(function()
            hook.Run("OnNPCKilled", self, atacante, inflictor)
        end)

        -- la línea de muerte sale del cadáver: esta entity se remueve con el
        -- BecomeRagdoll y un EmitSound propio moriría con ella
        local pools = PoolsDe(self.VoiceDir)
        local muertes = pools.death
        local snd = istable(muertes) and #muertes > 0 and muertes[math.random(#muertes)] or nil

        local pos, ang = self.SidorSpawnPos, self.SidorSpawnAng
        local clase = self:GetClass()
        local rag = self:BecomeRagdoll(dmginfo)
        if snd then
            if IsValid(rag) then
                rag:EmitSound(snd, 75, 100, 1, CHAN_VOICE)
            elseif isvector(pos) then
                sound.Play(snd, pos, 75, 100, 1)
            end
        end

        -- respawn según el cvar (0 = no respawnea; el ragdoll queda). La
        -- subclase respawnea como su propia clase. Stock fresco: AttachTrader
        -- re-siembra el contenedor vacío en el primer uso.
        local segundos = cvarRespawn:GetFloat()
        if segundos > 0 then
            timer.Simple(segundos, function()
                if IsValid(rag) then rag:Remove() end
                local nuevo = ents.Create(clase)
                if IsValid(nuevo) and isvector(pos) then
                    nuevo:SetPos(pos)
                    nuevo:SetAngles(ang or angle_zero)
                    nuevo:Spawn()
                    nuevo:Activate()
                end
            end)
        end
    end

end
