# Assets — qué hay, de dónde sale, cómo reconstruirlo

> Los assets de este addon **no están en el repo** (ver [`.gitignore`](../.gitignore)): son ports de
> S.T.A.L.K.E.R. propiedad de **GSC Game World**, la MIT cubre solo el código, y git guarda binarios
> de pena. Este doc es el manifiesto que permite **reconstruir el árbol** desde los packs de origen.
>
> Los packs viven en `dev/other/` (fuera de todo repo git, no publicado). Su inventario completo, con
> conteos y trampas, está en **`dev/stalker_rp_packs_mapa.md`** y **`dev/zona_stalkerrp_contenido.md`**.

## Regla de oro: rutas verbatim

Las rutas de los modelos se conservan **exactamente como vienen del pack de origen**. Un `.mdl`
referencia sus materiales por la ruta que tenía al compilarse (`cdmaterials`): re-namespacear
`models/stalker/…` a `models/corpus_stalker/…` exigiría **recompilar los 151 modelos**. No se toca.

Consecuencia: si un pack de origen está montado a la vez que este addon, los archivos coinciden en
ruta. Cuando son byte-idénticos no hay conflicto real; cuando **no** lo son, gana el último montado
— ver la matriz de colisiones en `dev/stalker_rp_packs_mapa.md` §3.

---

## 1. Lo que el addon tiene hoy (245 MB, 1.508 archivos)

### 1.1 Modelos — 151 `.mdl`

| Ruta en el addon | `.mdl` | Qué es | Pack de origen |
|---|---|---|---|
| `models/stalker/item/medical/` | 10 | `bandage`, `antirad`, `antidote`, `antibotic`, `medkit1-3`, `psy_pills`, `rad_pills`, `booster` | `zona stalker props` (WS `315505698`) |
| `models/stalker/item/food/` | 5 | `bread`, `sausage`, `tuna`, `drink`, `vokda` (*sic*, el typo es del pack) | ídem |
| `models/stalker/item/handhelds/` | 11 | `pda`, `mini_pda`, `radio`, `decoder`, `datachik1-3`, `files1-4` | ídem |
| `models/stalker/ammo/` | 16 | cajas por calibre (`545x39`, `762x54`, `9x39`, `12x70`, `gauss`…) | ídem |
| `models/stalker/outfit/` | 32 | trajes por facción, como prop | ídem |
| `models/hgn/srp/items/`, `models/zavod_yantar/`, `models/flyboi/hind/`, `models/raviool/`, `models/jerry/mutants/`, `models/` (raíz, 34) | 43 | props varios de la Zona | ídem |
| `models/player/seva/` (21), `models/player/bandit/` (7) | 28 | playermodels | `zona stalkerrp content` (WS `300746843`) |
| `models/arms/` | 1 | `c_arms_stalker` (brazos first-person) | ídem |
| `models/rashkinsk/` | 1 | `sidor` — **Sidorovich**, el trader. Rig **ValveBiped con los includes de animación del ciudadano HL2** (`male_shared`/`gestures`/`postures`): un `anim` entity le corre las secuencias de siempre. Material único: `act_stalker_trader_1` | `stalker rp  content #2` |

> **Importante:** los 43 modelos de `models/stalker/item/*` + `ammo/` + `raviool/flashlight`
> **también los trae `stalker rp  content #1`, byte-idénticos**. Si ese pack está montado, los
> consumidores resuelven igual sin este addon.

### 1.2 Materiales — 532 archivos

`materials/models/stalkertnb/{humans,mutants,zomb}`, `materials/models/stalkertextures/{item,loner,
freedom,bandit,dolg,clearsky}`, `materials/models/hgn/srp/items`, `materials/models/zavod_yantar` y
70 sueltos en `materials/models/`. Todos son las texturas de los modelos de §1.1 — misma procedencia.

### 1.3 Sonidos — 4

| Ruta | Consumidor | Origen |
|---|---|---|
| `sound/zona/stalkerrp/actions/interface/inv_food.ogg` | Craving (`eat`) | `zona stalker actionsounds` (WS `324236009`) |
| `sound/zona/stalkerrp/actions/interface/inv_vodka.ogg` | Craving (`drink`, `vodka`) | ídem |
| `sound/zona/stalkerrp/actions/interface/inv_softdrink.ogg` | Craving (`can`) | ídem |
| `sound/zona/stalkerrp/hunger.mp3` | Craving (`STOMACH`, sin fallback) | ídem |

> **Trampa de selección ya pagada:** los `actions/eat1-5.mp3` del pack son **tragos**, no masticado.
> El sonido de comer es `interface/inv_food.ogg`. El nombre del archivo miente: validar por oído.
>
> **Estos 4 sonidos son la única razón dura por la que Craving necesita este addon montado** — sus
> modelos ya vienen en `content #1`. Sin el addon, Craving cae a sonidos de HL2 (suena a barnacle).

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

# Los 4 sonidos de Craving (rutas verbatim, no renombrar)
mkdir -p "$ADDON/sound/zona/stalkerrp/actions/interface"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_food.ogg"      "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_vodka.ogg"     "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/actions/interface/inv_softdrink.ogg" "$ADDON/sound/zona/stalkerrp/actions/interface/"
cp "$DEV/zona stalker actionsounds/sound/zona/stalkerrp/hunger.mp3"                          "$ADDON/sound/zona/stalkerrp/"
```

**Al referenciar un sonido ZONA nuevo desde cualquier módulo, copiarlo también aquí** — el addon nació
sin `sound/` y los `zona/stalkerrp/*` sonaban solo porque el pack de Workshop estaba montado aparte.

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
