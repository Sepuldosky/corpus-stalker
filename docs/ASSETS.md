# Assets — qué hay, de dónde sale, cómo reconstruirlo

> Los assets de este addon **no están en el repo** (ver [`.gitignore`](../.gitignore)): son ports de
> S.T.A.L.K.E.R. propiedad de **GSC Game World**, la MIT cubre solo el código, y git guarda binarios
> de pena. Este doc es el manifiesto que permite **reconstruir el árbol** desde los packs de origen.
>
> Los packs viven en `dev/other/` (fuera de todo repo git, no publicado). Su inventario completo, con
> conteos y trampas, está en **`dev/stalker_rp_packs_mapa.md`** y **`dev/zona_stalkerrp_contenido.md`**.

## STK-3 — Regla de oro: rutas verbatim

Las rutas de los modelos se conservan **exactamente como vienen del pack de origen**. Un `.mdl`
referencia sus materiales por la ruta que tenía al compilarse (`cdmaterials`): re-namespacear
`models/stalker/…` a `models/corpus_stalker/…` exigiría **recompilar los 156 modelos**. No se toca.

Consecuencia: si un pack de origen está montado a la vez que este addon, los archivos coinciden en
ruta. Cuando son byte-idénticos no hay conflicto real; cuando **no** lo son, gana el último montado
— ver la matriz de colisiones en `dev/stalker_rp_packs_mapa.md` §3.

---

## 1. Lo que el addon tiene hoy (590 MB, 1.738 archivos)

### 1.1 Modelos — 156 `.mdl`

| Ruta en el addon | `.mdl` | Qué es | Pack de origen |
|---|---|---|---|
| `models/stalker/item/medical/` | 10 | `bandage`, `antirad`, `antidote`, `antibotic`, `medkit1-3`, `psy_pills`, `rad_pills`, `booster` | `zona stalker props` (WS `315505698`) |
| `models/stalker/item/food/` | 5 | `bread`, `sausage`, `tuna`, `drink`, `vokda` (*sic*, el typo es del pack) | ídem |
| `models/stalker/item/handhelds/` | 11 | `pda`, `mini_pda`, `radio`, `decoder`, `datachik1-3`, `files1-4` | ídem |
| `models/stalker/ammo/` | 16 | cajas por calibre (`545x39`, `762x54`, `9x39`, `12x70`, `gauss`…) | ídem |
| `models/stalker/outfit/` | 32 | trajes por facción, como prop | ídem |
| `models/hgn/srp/items/` (6), `models/zavod_yantar/` (3), `models/flyboi/hind/` (3), `models/raviool/` (1), `models/jerry/mutants/` (1), `models/` (raíz, 34) | 48 | props varios de la Zona | ídem |
| `models/player/seva/` (21), `models/player/bandit/` (7) | 28 | playermodels | `zona stalkerrp content` (WS `300746843`) |
| `models/arms/` | 1 | `c_arms_stalker` (brazos first-person) | ídem |
| `models/rashkinsk/` | 1 | `sidor` — **Sidorovich**, el trader. Rig **ValveBiped con los includes de animación del ciudadano HL2** (`male_shared`/`gestures`/`postures`): un `anim` entity le corre las secuencias de siempre. Material único: `act_stalker_trader_1` | `stalker rp  content #2` |
| `models/npc/stalker/` | 1 | `hawaiian` — **el Hawaiano**, el trader de comestibles (`lua/entities/corpus_stalker_hawaiian.lua`, roadmap [1]). Rig ValveBiped de 56 huesos con los includes del ciudadano HL2 (`m_anm`, `humans/male_shared` — de ahí salen `head_yaw`/`head_pitch` y los idles de pie), más `Police_Animations`/`Police_ss`/`combine_soldier_anims`. **`numflexdesc = 0`: NO tiene flexes**, así que este trader no parpadea ni mueve la boca — es del modelo, no un defecto, y la base degrada en silencio. Dos materiales, y viven bajo `materials/models/player/stalker/` (el `cdmaterials` del `.mdl` dice `models\\player\\stalker\\`, **no** `npc/`): `act_faces_1_06` (cara) y `act_stalker_neutral_2` (+ su `_n`, traje neutral con máscara antigás; ojo: **el `_n` es huérfano** — ningún `.vmt` lo cita). Todo leído del header del `.mdl` y de los `.vmt`, no del nombre. **TEXTURAS CAMBIADAS EL 2026-08-18** (ronda 2): las dos vivas salen ahora del pack de Workshop `902242849`, medidas del header del `.vtf` — cara `act_faces_1_06` **1024×512** (era 256×128 DXT5) y cuerpo `act_stalker_neutral_2` **1024×1024 DXT1** (era 256×256). **El `.mdl` y el `.vvd` de ese pack son IDÉNTICOS BYTE A BYTE a los de `stalker rp  content #1`** (mismo md5; 28.212 y 218.112 bytes), así que el modelo NO cambió: misma malla, mismo rig, mismas animaciones y **`numflexdesc` sigue en 0**. Lo que subió de calidad son los píxeles, y nada más | `.mdl`: `stalker rp  content #1` · `.vtf` vivas: `s.t.a.l.k.e.r. hawaiian (pm & npc)` (WS `902242849`) |
| `models/spec45as/stalker/items/` | 3 | `medkit_low/med/high` — los botiquines normal/army/scientific de STALKER. **Los tres esperan defs de ítem PROPIAS de la Zona.** El `low` re-vistió al Medkit de Coagulant hasta el 2026-08-06; se retiró — ver §1.4 | `stalker rp  content #4` |
| `models/wick/wrbstalker/cop/newmodels/items/` | 1 | `wick_bandage` — la venda (modelos COP de wick). **Espera un def propio.** Re-vistió a la Bandage de Coagulant hasta el 2026-08-06 — ver §1.4 | `stalker rp  content #1` |

> **Importante:** los 43 modelos de `models/stalker/item/*` + `ammo/` + `raviool/flashlight`
> **también los trae `stalker rp  content #1`, byte-idénticos**. Si ese pack está montado, los
> consumidores resuelven igual sin este addon.

### 1.2 Materiales — 544 archivos

`materials/models/stalkertnb/{humans,mutants,zomb}`, `materials/models/stalkertextures/{item,loner,
freedom,bandit,dolg,clearsky}`, `materials/models/hgn/srp/items`, `materials/models/zavod_yantar` y
70 sueltos en `materials/models/`. Todos son las texturas de los modelos de §1.1 — misma procedencia.
Los medkits y la venda referencian sus texturas **fuera** de `materials/models/` (cdmaterials sin el
prefijo `models/`): `materials/spec45as/stalker/items/item_medkit{,_2,_3}.{vmt,vtf}` y
`materials/wick/wrbstalker/cop/newmodels/items/item_m_bandage.{vmt,vtf}` — rutas verbatim (STK-3).

### 1.3 Sonidos — 193 (343 MB)

| Ruta | Consumidor | Origen |
|---|---|---|
| `sound/zona/stalkerrp/actions/interface/inv_food.ogg` | **RESERVADO** a la comida propia de la Zona (ítems futuros de este addon) | `zona stalker actionsounds` (WS `324236009`) |
| `sound/zona/stalkerrp/actions/interface/inv_vodka.ogg` | ídem (vodka de la Zona) | ídem |
| `sound/zona/stalkerrp/actions/interface/inv_softdrink.ogg` | ídem (lata de la Zona) | ídem |
| `sound/zona/stalkerrp/hunger.mp3` | Craving (`STOMACH`, sin fallback — excepción CRV-7) | ídem |
| `sound/npc/sidorovich/<accion>/*.ogg` (31: 27 en 9 carpetas de acción + 4 sueltos) | **Estándar de voz por ACCIÓN** (2026-07-24, `about.txt` de la carpeta): cada carpeta es una acción y cualquier sonido dentro entra a su pool — `greet_first`/`greet`/`wait`/`bye`/`trade_open_first`/`trade_open`/`trade_done`/`trade_fail` (vacía: faltan líneas en ruso)/`pain`/`death`. Consumen: el NextBot (`lua/entities/corpus_stalker_sidorovich.lua`, todas) y la persona del trader demo de Cargo (`lua/autorun/`, solo saludo/trade). Los 4 sueltos de la raíz no se escanean (`call`, `habar_request`, `bye_give_habar`, `start_pda`) | voces de Sidorovich, S.T.A.L.K.E.R. vía GAMMA (extraídas por el autor de su instalación; `pain`/`death` añadidas por el autor 2026-07-24) |
| `sound/npc/hawaiian/<accion>/*.ogg` (**pobladas por el autor el 2026-08-18 y confirmadas en juego**; nacieron vacías el 2026-08-17) | Voz del **trader de comida**, **ya con consumidor desde el 2026-08-18**: `lua/entities/corpus_stalker_hawaiian.lua` declara `ENT.VoiceDir = "npc/hawaiian"`. Mismo estándar por acción que Sidorovich y las mismas diez carpetas, con su `about.txt`. Nacieron **vacías a propósito** —una carpeta sin sonidos hace que el trader calle esa acción sin error, así que el tramo se pudo cerrar antes de que existiera un audio— y el autor las llenó durante la pasada de la ronda 1: *«el Hawaiano sí tiene voz, se la integré, todo eso funciona perfecto»*. **La ausencia de fallback sigue siendo lo que se verificó** (fila 09): que hable con SU voz y no con la de Sidorovich. El nombre de la carpeta es contrato con `ENT.VoiceDir = "npc/hawaiian"` — si se renombra una sin la otra, el trader queda **mudo sin dar error**. El personaje es el **Hawaiano** y su modelo es `hawaiian.mdl` — el nombre del archivo estuvo bien desde el principio; la carpeta se llamó `librarian/` medio día porque el autor se había equivocado de NPC | **las aporta el autor**; todavía no hay ninguna |
| `sound/radio/*.ogg` (158) | **sin consumidor todavía** (futuro sistema de radio de la Zona) | música del ambiente GAMMA (Kino, Nautilus Pompilius, Molchat Doma, etc. — extraída por el autor) |

> **STK-7 — Trampa de selección ya pagada:** los `actions/eat1-5.mp3` del pack son **tragos**, no
> masticado. El sonido de comer es `interface/inv_food.ogg`. El nombre del archivo miente: validar
> por oído.
>
> **Separación sonidos/ítems (decisión del autor 2026-07-24):** los consumibles GENÉRICOS de
> Craving pasaron al banco general del framework (`corpus/sound/corpus/craving/`, COR-17); los
> `zona/stalkerrp/*` de acá quedan reservados para la comida que este addon registre. Hoy la razón
> dura por la que Craving quiere este addon montado es `hunger.mp3` (más los modelos, que también
> vienen en `content #1`).
>
> **⚠ Radio: riesgo de licencia distinto al resto.** No son ports de juego sino **música comercial**
> (Kino, Molchat Doma, DDT…). STK-8 (retiro a pedido) aplica igual, pero el riesgo de takedown en
> Workshop/GitHub es real — evaluar antes de publicar cualquier bundle con `sound/radio/`. No se
> versionan (STK-2), como todo el árbol.

### 1.4 Los cuatro modelos médicos: esperan un def propio, no una sustitución

`medkit_low/med/high` (spec45as) y `wick_bandage` (wick) están en el árbol **sin consumidor**.

Hasta el **2026-08-06** el `low` y la venda re-vestían al Medkit y a la Bandage de Coagulant vía
`Cargo.Items.SetModel`. **Se retiró** (decisión del autor). Dos motivos, y el segundo es el que
manda:

1. Coagulant trae **sus propios modelos** desde el 2026-08-05 — 19 `.mdl` CC BY 4.0 en
   `models/corpus_coagulant/`. La sustitución dejó de tapar una cajita de cartón y pasó a tapar
   un modelo bueno.
2. Y sobre todo: **un botiquín de la Zona no es una piel del Medkit genérico, es otro ítem.** Un
   `medkit_army` tiene otro peso, otro precio y otra curación que el Medkit de Coagulant. Vestir
   al genérico con su modelo miente sobre lo que es: el jugador ve un botiquín militar de STALKER
   y recibe los números del genérico.

Lo que corresponde es que la Zona registre **sus** defs contra Cargo, con `onUse` delegando en el
contrato de Coagulant (`ApplyTreatment`) — el módulo sigue siendo dueño de la medicina (COR-1/CRG-1),
y este addon del contenido. El alcance de commit `items` sigue **RESERVADO** hasta que se escriban,
y **STK-1 + COA-28 mandan: que el modelo exista no crea el ítem.** El diseño se acuerda antes.

> **Dónde SÍ sigue habiendo sustitución, y por qué es distinto.** Las dos mochilas de Cargo se
> registran **sin modelo a propósito** (`corpus_cargo_supplies.lua`: *"The backpacks declare NO
> model on purpose: HL2 has no backpack prop"*). Ahí no se tapa nada: se llena un hueco que el
> módulo dueño dejó abierto para un addon de contenido. **Llenar un hueco no es pisar un modelo.**

---

## 2. Reconstruir el árbol

Los packs de origen están en `dev/other/`. Copiar **preservando la ruta relativa**:

```bash
DEV="d:/Documentos/Materia universidad/Personal/Corpus/VSCode/dev/other"
ADDON="d:/Documentos/Materia universidad/Personal/Corpus/VSCode/corpus-stalker"

# Modelos + materiales de ítem, outfits, props
cp -r "$DEV/zona stalker props/models"/*      "$ADDON/models/"
cp -r "$DEV/zona stalker props/materials"/*   "$ADDON/materials/"

# Playermodels + brazos
cp -r "$DEV/zona stalkerrp content/models"/*    "$ADDON/models/"
cp -r "$DEV/zona stalkerrp content/materials"/* "$ADDON/materials/"

# Sidorovich (el trader demo de Cargo lo usa si está montado; si no, cae al ciudadano de HL2)
mkdir -p "$ADDON/models/rashkinsk" "$ADDON/materials/models/rashkinsk/sidor"
cp "$DEV/stalker rp  content #2/models/rashkinsk/sidor."*             "$ADDON/models/rashkinsk/"
cp "$DEV/stalker rp  content #2/materials/models/rashkinsk/sidor/"*   "$ADDON/materials/models/rashkinsk/sidor/"

# Medkits (normal/army/scientific) + venda — a la espera de defs de item PROPIAS
# de la Zona (ver §1.4). Ojo: sus materiales van FUERA de materials/models/
# (cdmaterials sin prefijo "models/")
mkdir -p "$ADDON/models/spec45as/stalker/items" "$ADDON/materials/spec45as/stalker/items"
mkdir -p "$ADDON/models/wick/wrbstalker/cop/newmodels/items" "$ADDON/materials/wick/wrbstalker/cop/newmodels/items"
for m in medkit_low medkit_med medkit_high; do
  cp "$DEV/stalker rp  content #4/models/spec45as/stalker/items/$m."* "$ADDON/models/spec45as/stalker/items/"
done
for t in item_medkit item_medkit_2 item_medkit_3; do
  cp "$DEV/stalker rp  content #4/materials/spec45as/stalker/items/$t."* "$ADDON/materials/spec45as/stalker/items/"
done
cp "$DEV/stalker rp  content #1/models/wick/wrbstalker/cop/newmodels/items/wick_bandage."* "$ADDON/models/wick/wrbstalker/cop/newmodels/items/"

# El Hawaiano (trader de comestibles). El .mdl vive en models/npc/stalker/ pero
# su cdmaterials apunta a models/player/stalker/ — la ruta del archivo y la del
# material NO coinciden, y las dos son verbatim (STK-3).
# DOS PACKS, y el orden importa: el .mdl sale del #1 y las dos texturas VIVAS
# del pack de Workshop 902242849, que las trae a 1024 en vez de 256. El .mdl de
# los dos packs es el MISMO archivo byte a byte (md5 verificado), así que da
# igual de cuál se copie; lo que no da igual son los .vtf.
mkdir -p "$ADDON/models/npc/stalker" "$ADDON/materials/models/player/stalker"
cp "$DEV/stalker rp  content #1/models/npc/stalker/hawaiian."* "$ADDON/models/npc/stalker/"
cp "$DEV/stalker rp  content #1/materials/models/player/stalker/act_stalker_neutral_2_n.vtf" "$ADDON/materials/models/player/stalker/"
for t in act_faces_1_06 act_stalker_neutral_2; do
  cp "$DEV/s.t.a.l.k.e.r. hawaiian (pm & npc)/materials/models/player/stalker/$t."* "$ADDON/materials/models/player/stalker/"
done
cp "$DEV/stalker rp  content #1/materials/wick/wrbstalker/cop/newmodels/items/item_m_bandage."* "$ADDON/materials/wick/wrbstalker/cop/newmodels/items/"

# Los 4 sonidos de Craving (rutas verbatim, no renombrar)
mkdir -p "$ADDON/sound/zona/stalkerrp/actions/interface"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_food.ogg"      "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_vodka.ogg"     "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_softdrink.ogg" "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/hunger.mp3"                          "$ADDON/sound/zona/stalkerrp/"
```

**STK-6 — Al referenciar un sonido ZONA nuevo desde cualquier módulo, copiarlo también aquí** — el addon
nació sin `sound/` y los `zona/stalkerrp/*` sonaban solo porque el pack de Workshop estaba montado aparte.

---

## 3. Lo que hará falta cuando lleguen las entidades

Todavía **no copiado**. Sale del set de 6 packs `stalker rp *` (ver `dev/stalker_rp_packs_mapa.md`):

| Para | Qué copiar | De |
|---|---|---|
| **Artefactos** | `models/predatorcz/stalker/artifacts/` (29 `.mdl`) + `materials/models/predatorcz/` + `materials/vgui/entities/` (iconos) | `content #4` (es su único aporte real) |
| **Artefactos (set alternativo)** | `models/srp/items/` (34, nomenclatura canónica `art_*`) | `content #1` (modelos) + `materials #2` (texturas) |
| **Anomalías** | `particles/stalker_anomaly.pcf` (**53 sistemas**, monolítico) + `materials/particles/` (31 vmt) + `models/anomaly/anomaly_fix.mdl` (la bbox invisible) + `sound/anomaly/` (20) | `content #2` |
| Distorsión de Gravi | `pincher.vmt`, `refract_ring.vmt` (shader `Refract`) | `materials #2` |
| **PDA / detectores** | `models/kali/miscstuff/stalker/` (`pda`, `radio`, `detector_bear/echo/veles`) + `sound/stalkerdetectors/` + `sound/jessev92/stalker/soc/pda/geiger_1..8.wav` | `content #2` + `materials #1` |
| **Mutantes (CortexBase)** | `models/tnb/stalker/` (~38 mutantes) + `sound/npc/<criatura>/` (50 criaturas, naming X-Ray) | `content #2` + `materials #1` |
| **UI** | atlas `ui_icon_equipment.1.png` (2048², recortar por grilla) · `materials/icons/` (60×60) · `faction_icons/` (256²) · `srpimages/` (`inventory_grid`, `pda_frame`) | `content #3` + `materials #1` + `materials #2` |

⚠️ **No copiar el CÓDIGO de esos packs.** Está envenenado (monkeypatch global de `engine.IsMounted`,
un hook que anula las explosiones de todo el servidor, `net.ReadTable()` sin validar) y los artefactos
literalmente no hacen nada. Se reescribe. Detalle en `dev/stalker_rp_packs_mapa.md` §5.
