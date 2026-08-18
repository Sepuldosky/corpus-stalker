-- corpus_stalker_hawaiian.lua — el Hawaiano, trader de comestibles (NextBot)
-- Segunda entidad del repo (clase prefijada, STK-5) y PRIMERA SUBCLASE del
-- trader: `ENT.Base = "corpus_stalker_sidorovich"`. Roadmap [1] de este repo.
--
-- LO QUE ESTE ARCHIVO NO TIENE, y es el punto: ni una función. Mirada, flexes,
-- respawn, voz por carpetas de acción, el +USE, el `AttachTrader` y el
-- re-sorteo de stock son de la base. Acá sólo se pisan campos. Si algún día
-- hiciera falta escribir comportamiento acá, eso es un hallazgo sobre el
-- diseño de la base y va anotado — no se resuelve copiando el archivo.
--
-- DE DÓNDE SALE. De la pasada en juego de los nutrientes de Craving
-- (2026-08-17, 14/14): los 15 consumibles sólo se conseguían spawneándolos de
-- a uno por consola. El problema era de DISPONIBILIDAD, no de comida.
--
-- EL NOMBRE, y lo que costó llegar a él (§7 del handoff): el modelo es
-- `hawaiian.mdl` y el personaje es el HAWAIANO. Se lo había buscado como otro
-- NPC, el censo de texturas midió que viste traje neutral con máscara antigás
-- —ni camisa hawaiana ni camuflaje de Freedom— y eso se reportó como «el
-- nombre miente». No mentía: lo que no coincidía era el nombre con el que se
-- lo estaba buscando. **El archivo, el personaje, la clase y la carpeta de voz
-- llevan EL MISMO nombre**, y conviene que siga así — un cuarto nombre
-- distinto es un lugar más donde equivocarse sin que nada falle.
--
-- DOS COSAS MEDIDAS DEL `.mdl`, leídas del header y no del nombre, porque
-- cambian qué se puede marcar verde en una pasada:
--   · **NO TIENE FLEXES** (`numflexdesc = 0`, contra los 4 del sidor.mdl). El
--     parpadeo y el aleteo de boca de la base detectan por nombre y no
--     encuentran nada, así que el Hawaiano **no parpadea ni mueve la boca**.
--     Es del modelo, no un defecto: la base degrada en silencio, como debe.
--   · Sí incluye `models/humans/male_shared.mdl` y `models/m_anm.mdl`, que es
--     de donde salen `head_yaw`/`head_pitch` y los idles de pie del ciudadano.
--     La mirada y la rotación de idles tienen que funcionar igual que en
--     Sidorovich (que trae los mismos dos includes, más gestures/postures).
--
-- LA VOZ ARRANCA MUDA A PROPÓSITO: `sound/npc/hawaiian/` ya tiene las diez
-- carpetas del estándar de acción, vacías, con su about.txt. El autor suelta
-- los .ogg ahí y esto no se toca. Carpeta vacía = calla esa acción, JAMÁS un
-- error — y **no hay fallback a las voces de Sidorovich**: que el trader nuevo
-- hable con la voz del viejo es peor que el silencio. Ojo, `sound/` está en el
-- .gitignore (STK-2): esas carpetas son locales y no viajan en un commit.

AddCSLuaFile()

ENT.Base      = "corpus_stalker_sidorovich"
ENT.Type      = "nextbot"
ENT.PrintName = "Hawaiian"
ENT.Author    = "Corpus"
ENT.Category  = "Corpus"
ENT.Spawnable = true

ENT.TraderName  = "Hawaiian"
-- Ruta del pack `stalker rp  content #1`, verbatim (STK-3: los .mdl
-- referencian sus materiales por ruta compilada). Si el modelo no está
-- montado, `Initialize` de la base cae al ciudadano de HL2 sin error — así que
-- el trader se puede verificar antes de que llegue su fachada, pero eso se
-- DECLARA en la planilla, no se marca verde como si se hubiera probado con su
-- cara real.
ENT.TraderModel = "models/npc/stalker/hawaiian.mdl"
-- La mitad de Sidorovich (50.000). Billetera finita: se lo puede drenar.
ENT.TraderMoney = 25000
-- Contrato silencioso con el nombre de la carpeta: si no coinciden, el trader
-- queda MUDO sin dar error, que se ve exactamente igual que «todavía no le
-- pusieron audios».
ENT.VoiceDir    = "npc/hawaiian"

-- Vende TODO lo que declare `category = "food"` en Cargo. Es una REGLA y no
-- una lista (voto del autor, y el motivo es de método: *«así me hace más fácil
-- el debug y me permite comer lo que quiera, mientras lo compre»*), así que
-- una comida que registre mañana cualquier addon entra sola.
--
-- ES UN MÉTODO Y NO UN CAMPO, y no es una elección de estilo: la razón entera
-- —`scripted_ents.TableInherit` mergea las tablas del padre en vez de dejar
-- que el hijo las pise— está escrita arriba del método homónimo en la base. Si
-- esto fuera un campo, este trader vendería además la munición y la medicina
-- de Sidorovich y serviría el pan en stacks de 120, sin un solo error.
function ENT:TraderStockPlan()
    return {
        categorias = {
            -- 1 a 6 por ítem (voto del autor, 2026-08-17)
            { cat = "food", min = 1, max = 6 },
        },
        -- sin armas: el bloque simplemente no está
    }
end
