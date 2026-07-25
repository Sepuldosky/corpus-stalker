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
-- roadmap de Cargo (#45).
--
-- Deuda declarada: si alguien tiene la pantalla de trade abierta cuando él
-- muere, la pantalla queda huérfana — Cargo no tiene trade_close server→
-- cliente. Degrada honesto: cualquier acción responde "The trader is out of
-- reach" y el jugador la cierra a mano.

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

-- Stock placeholder: el kit dev de Cargo, hasta que exista el catálogo de
-- ítems de la Zona. Un id desconocido lo ignora AttachTrader con log.
ENT.TraderStock = {
    { id = "cargo_dev_pistol",   count = 1 },
    { id = "cargo_dev_smg",      count = 1 },
    { id = "cargo_dev_helmet",   count = 1 },
    { id = "cargo_dev_vest",     count = 1 },
    { id = "cargo_dev_plate",    count = 2 },
    { id = "cargo_dev_backpack", count = 1 },
    { id = "cargo_dev_medkit",   count = 4 },
    { id = "cargo_dev_food",     count = 6 },
    { id = "cargo_dev_ammo_9mm", count = 120 },
}

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

        -- idles: solo entran las secuencias que el modelo montado tiene
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
        self.SidorProxIdle = CurTime() + math.Rand(12, 25)

        -- flexes: detección por nombre, nunca asunción — el sidor.mdl trae
        -- exactamente blink y mouth; el citizen fallback no las tiene y calla
        self.SidorFlexBlink, self.SidorFlexMouth = nil, nil
        for i = 0, self:GetFlexNum() - 1 do
            local nombre = string.lower(self:GetFlexName(i) or "")
            if nombre:find("blink", 1, true) then
                self.SidorFlexBlink = i
            elseif nombre:find("mouth", 1, true) then
                self.SidorFlexMouth = i
            end
        end
        self.SidorProxParpadeo = CurTime() + math.Rand(1, 4)
        self.SidorParpadeoDesde = 0

        -- pose params de cabeza (male_shared): -1 si el modelo no las trae
        self.SidorPPYaw = self:LookupPoseParameter("head_yaw")
        self.SidorPPPitch = self:LookupPoseParameter("head_pitch")
        self.SidorYaw, self.SidorPitch = 0, 0

        -- contabilidad de voz, por sesión de mapa
        self.SidorVoz = {}
        self.SidorSaludados = {}
        self.SidorTradeSaludados = {}
        self.SidorTradeHubo = {}
        self.SidorProximaLinea = 0
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
        local trader = self.CargoTrader
        local miPos = self:GetPos()

        self.SidorVoz = self.SidorVoz or {}
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local st = self.SidorVoz[ply]
                local d2 = ply:GetPos():DistToSqr(miPos)
                if st == nil then
                    if d2 <= r2in then
                        local sid = ply:SteamID64() or tostring(ply)
                        if not self.SidorSaludados[sid] and self:SidorSpeak("greet_first") then
                            self.SidorSaludados[sid] = true
                        else
                            self:SidorSpeak("greet")
                        end
                        self.SidorVoz[ply] = { esperaProx = CurTime() + self.VoiceWait }
                    end
                elseif d2 > r2out then
                    self.SidorVoz[ply] = nil
                    self:SidorSpeak("bye")
                elseif CurTime() >= st.esperaProx then
                    if not (trader and trader.viewers and trader.viewers[ply]) then
                        self:SidorSpeak("wait")
                    end
                    st.esperaProx = CurTime() + self.VoiceWait
                end
            end
        end
        for ply in pairs(self.SidorVoz) do
            if not IsValid(ply) then self.SidorVoz[ply] = nil end
        end
    end

    -- ------------------------------------------------------------------
    -- Cara: mirada + parpadeo + boca. Corre en BodyUpdate (al ritmo del
    -- update de nextbots); flexes y pose params se networkean solos.
    -- ------------------------------------------------------------------

    function ENT:SidorCara()
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
            local t = ahora - (self.SidorParpadeoDesde or 0)
            local peso = t < PARPADEO_T and (1 - math.abs(t / PARPADEO_T * 2 - 1)) or 0
            self:SetFlexWeight(self.SidorFlexBlink, peso)
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
        if CurTime() >= (self.SidorProxLento or 0) then
            self.SidorProxLento = CurTime() + 0.25

            -- rotación de idles por TIMER. Todas las poses son de pie y
            -- parecidas: el corte entre una y otra no salta a la vista.
            if CurTime() >= (self.SidorProxIdle or 0) and #(self.SidorIdles or {}) > 0 then
                self:SidorTocarIdle(self.SidorIdles[math.random(#self.SidorIdles)])
                self.SidorProxIdle = CurTime() + math.Rand(12, 25)
            end

            self:SidorVozThink()
        end
    end

    -- ------------------------------------------------------------------
    -- Comercio: mismo contrato que el demo — AttachTrader perezoso en el
    -- primer uso + OpenFor. Los callbacks de evento los dispara el server
    -- de trade de Cargo sobre CUALQUIER entidad que los defina.
    -- ------------------------------------------------------------------

    function ENT:SidorUsar(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        if self.SidorMuerto then return end
        -- candado anti doble disparo: ENT.Use y el fallback por KeyPress
        -- pueden llegar el mismo tick
        if CurTime() < (self.SidorProxUso or 0) then return end
        self.SidorProxUso = CurTime() + 0.4

        local cargo = Corpus and Corpus.GetModule and Corpus.GetModule("cargo")
        if cargo == nil or cargo.Trade == nil then return end

        cargo.Trade.AttachTrader(self, {
            name = self.TraderName,
            buy_mult = self.TraderBuyMult,
            sell_mult = self.TraderSellMult,
            money = self.TraderMoney,
            stock = self.TraderStock,
            -- sesión-only a propósito: al morir el stock se borra y al
            -- respawnear AttachTrader re-siembra un contenedor vacío
        })
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
        local sid = IsValid(ply) and (ply:SteamID64() or tostring(ply)) or "?"
        self.SidorTradeSaludados = self.SidorTradeSaludados or {}
        if not self.SidorTradeSaludados[sid] and self:SidorSpeak("trade_open_first", true) then
            self.SidorTradeSaludados[sid] = true
        else
            self:SidorSpeak("trade_open", true)
        end
        -- para trade_fail: la sesión abre sin trato concretado todavía
        self.SidorTradeHubo = self.SidorTradeHubo or {}
        self.SidorTradeHubo[ply] = false
        -- sin línea de espera con su pantalla abierta; el reloj vuelve al cerrar
        local st = self.SidorVoz and self.SidorVoz[ply]
        if st then st.esperaProx = math.huge end
    end

    function ENT:OnTradeDealt(ply)
        if self.SidorTradeHubo then self.SidorTradeHubo[ply] = true end
        self:SidorSpeak("trade_done", true)
    end

    function ENT:OnTradeClosed(ply)
        -- cerró la pantalla sin comprar nada → trade_fail (hoy la carpeta
        -- está vacía a la espera de líneas en ruso: silencio, sin errores)
        if self.SidorTradeHubo and self.SidorTradeHubo[ply] == false then
            self:SidorSpeak("trade_fail", true)
        end
        if self.SidorTradeHubo then self.SidorTradeHubo[ply] = nil end
        local st = self.SidorVoz and self.SidorVoz[ply]
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
        if self.SidorMuerto then return end
        self.SidorMuerto = true

        local cargo = Corpus and Corpus.GetModule and Corpus.GetModule("cargo")
        local trader = self.CargoTrader
        if trader ~= nil then
            if cargo and cargo.Instances and isfunction(cargo.Instances.Delete) then
                for _, entry in ipairs(trader.cont.items) do
                    if entry.uid then cargo.Instances.Delete(entry.uid) end
                end
            end
            table.Empty(trader.cont.items)
            -- las pantallas abiertas quedan huérfanas (deuda declarada en el
            -- header): cualquier acción degrada honesto en el server de trade
            table.Empty(trader.viewers)
        end

        hook.Run("OnNPCKilled", self, dmginfo:GetAttacker(), dmginfo:GetInflictor())

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
