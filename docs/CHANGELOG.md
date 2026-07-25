
---

## PARCHES DE sesión Etiquetado de IDs normativos (deuda D-7) — 2026-07-19

Tanda multi-repo del ecosistema, guiada por `dev/PROMPT_d7_etiquetado_ids.txt` (§8 del flujo).
Solo prosa: **ninguna norma cambió**. Este repo fue el **slice piloto** de la tanda — el más
chico, para validar el patrón antes del fanout a los otros cuatro.

- PARCHE 1 — **7 de los 8 IDs `STK` etiquetados en su sede** (`CLAUDE.md` y `docs/ASSETS.md`).
  El restante es `STK-8`, cuya sede es el `README.md`: es la cara pública del repo en GitHub y
  un ID interno ahí ensucia la lectura de un visitante. Su sede probablemente deba mudarse al
  `CLAUDE.md` — decisión del autor. **[APLICADO 2026-07-19]**

- PARCHE 2 — **Los contratos 1-4 no eran normas propias: eran copias del framework.** Ahora
  **citan** `COR-5` (detección), `COR-6` (prefijo), **`COR-12`** (defs en ambos realms, con
  puntero a su sede canónica en `corpus/docs/CORPUS_Architecture.md` §5) y `COR-3`/`COR-4`
  (persistencia y net namespaced). La regla cardinal cita `COR-5` y `COR-10`. Solo los
  contratos 5 y 6 son propios de la Zona: quedaron como `STK-4` y `STK-5`.
  Convertir esas copias en citas es parte de la reparación de la deuda **D-1**.
  **[APLICADO 2026-07-19]**

Verificación: `corpus/.claude/check-ids/corpus_check_ids.ps1` en verde. Sin superficie de
runtime, y **ningún check de planilla nace de esta tanda** (FLU-37).

---

## PARCHES DE sesión Anti-drift: cierre de votos — 2026-07-19

Tanda multi-repo guiada por `dev/PROMPT_cierre_antidrift.txt`: el autor votó las deudas
abiertas del registro y acá se aplica lo que toca a este repo.

- PARCHE 1 — **Voto g: la sede de `STK-8` se muda del README al `CLAUDE.md`** (sección
  Assets). El README sigue enunciando la política de crédito completo + retiro a pedido en
  lenguaje de visitante, **sin etiqueta** — un ID interno ensuciaba la cara pública del
  repo en GitHub. Cierra el pendiente que el PARCHE 1 de la sesión anterior dejó anotado.
  **[APLICADO 2026-07-19]**
- PARCHE 2 — **Voto d (D-6 cerrada): política git estricta.** El §Git pasa de prohibir solo
  el push a «**ni commit ni push** salvo pedido explícito», citando `GIT-7` — este repo era
  el único divergente; los siete dicen ahora lo mismo. **[APLICADO 2026-07-19]**

Verificación: `corpus/.claude/check-ids/corpus_check_ids.ps1` en verde sobre 197 IDs. Sin
superficie de runtime, y **ningún check de planilla nace de esta tanda** (FLU-37).

---

## PARCHES DE sesión Anti-drift: reparación del COMPLETO — 2026-07-19

- PARCHE 1 — **Hallazgo 2.16 del acta `corpus/docs/auditorias/2026-07-19_coherencia_docs.md`:**
  la sección «Idioma» pasa a «**Idioma y commits**»: de las convenciones del framework
  se heredan las secciones 0/1/2/4/5; su **§3 NO aplica acá** (es el mapa de archivos
  del framework — GIT-6 reformulado en su sede), y la tabla de alcances **interina** de
  este repo vive en esa sección (`assets`, `repo`, `docs`, más las futuras de la Zona)
  hasta que nazca `docs/stalker_convenciones_commits.txt`. Los tres commits existentes
  ya eran conformes — el árbol ejecutó la norma antes de que el doc la dijera bien.
  **[APLICADO 2026-07-19]**

Verificación: checker en verde + suite 12/12. Sin superficie de runtime.

---

## PARCHES DE sesión D-13: el repo estrena docs de diseño — 2026-07-19

Parte de la tanda multi-repo guiada por `dev/PROMPT_d12_d13_segundo_completo.txt`. Este repo
era el hueco **H5** del COMPLETO: tenía 6 IDs `STK-` acuñados, **5 con sede en su `CLAUDE.md`**
— o sea que el `CLAUDE.md` estaba haciendo de arquitectura, justo lo que §2 del flujo dice que
no debe pasar. Y era la única de las siete raíces sin doc de convenciones.

- PARCHE 1 — **Nace `docs/STALKER_Arquitectura.md` (mínima).** Fija lo que hacía falta para
  que nadie escriba la primera anomalía a ciegas: alcance, la frontera de consumidor puro
  (**STK-1**, con **COR-11**/**COR-5**/**COR-6** citados), el **mapa de consumo por módulo**
  —qué se le pide a cada uno y qué pasa si no está—, los dominios de contenido, el régimen de
  assets (**STK-2**/**STK-3**/**STK-8**), la autopsia de los packs de referencia (**STK-4**,
  **STK-5**) y la degradación honesta por CAPACIDAD (**CRV-2**/**CRV-3**). **No diseña ningún
  dominio**: eso llega con cada bloque. Lleva anotada la trampa de realms (**COR-12**) antes
  de que este repo registre su primer ítem — la pagaron Craving y Coagulant, y es el próximo.
  **[APLICADO 2026-07-19]**
- PARCHE 2 — **Nace `docs/stalker_convenciones_commits.txt` y `STK-9` con él.** Formaliza la
  tabla que vivía INTERINAMENTE en una línea del `CLAUDE.md` — que es el estado transitorio
  que GIT-6 contempla, y que deja de servir en cuanto el árbol de código crezca. Tres alcances
  **en uso** (`assets`, `repo`, `docs`) y siete **reservados** (`anomalias`, `artefactos`,
  `pda`, `detectores`, `npc`, `items`, `models`): se declaran antes de tener contenido a
  propósito, para que el día que nazca la primera anomalía el alcance ya exista. Los tres
  commits del repo ya son conformes. **[APLICADO 2026-07-19]**
- PARCHE 3 — El `CLAUDE.md` suma la arquitectura y las convenciones a su jerarquía de lectura,
  y su sección de commits pasa a apuntar al doc (que manda) en vez de contener la tabla.
  **[APLICADO 2026-07-19]**

**Deuda anotada, NO ejecutada:** las cinco sedes `STK-` que siguen en el `CLAUDE.md` (STK-1,
STK-2, STK-4, STK-5, STK-8) **no se movieron**. La arquitectura nueva las **cita**.
Consolidarlas ahí es la continuación natural de D-3, pero mover una sede es decisión del autor
y no se hizo por cuenta propia.

Verificación: checker en verde sobre 207 IDs + suite 12/12. Sin superficie de runtime: este
repo sigue teniendo un solo archivo Lua y no se tocó.

---

## PARCHES DE sesión Reparación del gate de coherencia (acta 2026-07-22) — 2026-07-22

Tanda de reparación documental propuesta por el gate de coherencia en su corrida COMPLETO del
2026-07-22 (`../../corpus/docs/auditorias/2026-07-22_coherencia_docs.md`; el gate propone, el
autor dispone). Acá lo que toca a este repo. Solo prosa; **ninguna norma cambió de contenido**.

- PARCHE 1 — **Hallazgo 2.9 del acta (pase de valor):** `docs/STALKER_Arquitectura.md` decía
  «cinco de los **ocho** IDs `STK-`… siguen con sede en el `CLAUDE.md`». `ids.yaml` define
  STK-1..STK-9: son **nueve** VIGENTE (STK-9 se acuñó en la misma tanda del 2026-07-19). El
  subconjunto «cinco con sede en CLAUDE.md» (STK-1,2,4,5,8) es correcto; solo el total estaba
  desfasado en uno. Corregido `ocho` → `nueve`. **[APLICADO 2026-07-22]**

Verificación: sin superficie de runtime — este repo sigue teniendo un solo archivo Lua y no se
tocó. Cambio trazable al acta (§7.1). No commiteado ni pusheado (GIT-7).

---

## PARCHES DE sesión Re-vestido de ítems genéricos con modelos de la Zona — 2026-07-23

Pedido del autor (2026-07-23, tanda cross-repo con Cargo — su entry **34**, que estrena el punto
de sustitución `Cargo.Items.SetModel(id, model)`; FLU-04: Cargo primero, este repo consume). Los
ítems genéricos del ecosistema (set médico de Coagulant, mochilas default de Cargo) se registran
sin modelo y caen a la cajita de cartón; este addon les pone la piel de la Zona.

- PARCHE 1 — feat(models): nace `lua/autorun/corpus_stalker_itemmodels.lua` (shared, ambos
  realms — COR-12: las defs viven por realm). Sustituciones: `corpus_coagulant_bandage` →
  `wick_bandage` (wick, COP), `corpus_coagulant_medkit` → `medkit_low` (spec45as),
  `cargo_backpack_small`/`_large` → `hgn/srp/items/backpack-1/2` (**mapeo provisorio**: el autor
  verifica en juego cuál es cuál). Tourniquet y Blood Bag sin modelo coherente en los packs
  (autor) — quedan en la cajita. Sonda + boot diferido a `Initialize` (COR-5), `file.Exists` por
  modelo (STK-2: si el árbol vino sin assets, el def conserva su default), log de conteo.
  **Activa el alcance `models`** (§3 de las convenciones; el CLAUDE.md refleja). **[APLICADO
  2026-07-23]**
- PARCHE 2 — docs(assets): al árbol de assets (no versionado, STK-2) entran los **3 medkits** de
  spec45as (`stalker rp  content #4`: `medkit_low/med/high` — botiquines normal/army/scientific;
  med/high esperan a los defs de ítem de la Zona) y la **venda** de wick (`stalker rp  content
  #1`), con sus materiales — que van **fuera** de `materials/models/` (cdmaterials sin prefijo
  `models/`, rutas verbatim STK-3). `docs/ASSETS.md` actualiza el inventario (156 `.mdl`,
  544 materiales, 249 MB / 1.548 archivos) y el script de reconstrucción de §2. Las mochilas
  backpack-1/2 **ya estaban** en el árbol (pack ZONA props). **[APLICADO 2026-07-23]**

Verificación: la pasada en juego vive en el checklist del entry 34 de Cargo (drop-cajita sin este
addon, sustitución 4/4 con él, cuál mochila es cuál). Offline no hay superficie: el archivo es
inerte sin Corpus/Cargo. **Confirmado en juego por el autor el 2026-07-23** — sustitución 4/4 y
mapeo chica→backpack-1 / grande→backpack-2 confirmado (deja de ser provisorio). Commiteado y
pusheado con autorización del autor.

---

## PARCHES DE sesión La voz de Sidorovich: persona del trader — 2026-07-24

Pedido del autor: mejorar el NPC trader con las voces de Sidorovich que entraron al árbol
(`sound/npc/sidorovich/`, con su `about.txt`) — saludo al acercarse, despedida al irse del área,
línea de espera cada 1 min para no ser repetitivo, y líneas al abrir/cerrar el trading — más
idles de citizen HL2 (los de la plaza). Cargo expone el punto de extensión genérico
(`Trade.SetDefaultPersona` + callbacks de evento, su entry 35); acá vive TODO el contenido
Sidorovich (STK-1: Cargo no lo nombra en ninguna parte).

- PARCHE 1 — feat(npc): nace `lua/autorun/corpus_stalker_sidorovich.lua` (ambos realms, sonda +
  boot diferido a `Initialize` — COR-5): arma la persona `{name, model sidor.mdl, idles de plaza,
  radius 220, wait_interval 60, sounds}` con el mapa del `about.txt` del autor (greet_first /
  greet_1-4 / wait_1-4 / bye_1-3 / greet_habar / habar_greet_1-3 / bye_habar_1-3) y la registra
  vía `Cargo.Trade.SetDefaultPersona` si la superficie existe (degradación honesta sin Cargo o
  con un Cargo viejo). Cada ruta se filtra con `file.Exists` (STK-2): un set que quedó vacío no
  se registra y el trader calla esa línea. Cuatro líneas quedan anotadas sin consumidor (`call`,
  `habar_request`, `bye_give_habar`, `start_pda`). **Activa el alcance `npc`** (§3 de las
  convenciones; el CLAUDE.md refleja). **[APLICADO 2026-07-24]**
- PARCHE 2 — docs(assets): el inventario de sonidos pasa de 4 a **185** (+23 voces de Sidorovich,
  +158 pistas de radio **sin consumidor todavía** — con nota de riesgo de licencia: música
  comercial, no ports de juego); árbol total 590 MB / 1.730 archivos. Los 3 sonidos de
  comer/beber `zona/stalkerrp/actions/*` quedan **RESERVADOS** a la comida propia de la Zona:
  los consumibles genéricos de Craving pasaron al banco general del framework
  (`corpus/sound/corpus/craving/`, COR-17 — separación sonidos/ítems, decisión del autor
  2026-07-24). **[APLICADO 2026-07-24]**

Verificación: la pasada en juego vive en el checklist de la entry 35 de Cargo (saludo/espera/
despedida/habar + idles de plaza con este addon montado; trader citizen y mudo sin él).
**Confirmado en juego por el autor el 2026-07-24** (entry 35 a-e ✓). Commiteado y pusheado con
autorización del autor.

---

## PARCHES DE sesión Sidorovich de cuerpo presente: NextBot matable — 2026-07-24

Pedido del autor (2026-07-24): la persona ya suena, pero el cuerpo seguía siendo la entity
`anim` demo de Cargo — inmortal, flotando unos centímetros y con la cara congelada. Nace la
**primera entidad del repo**: el trader real con comportamiento que el header del demo de Cargo
siempre anunció («cuando llegue un trader con cerebro, llama al mismo `Trade.AttachTrader`
desde su propia entidad»). Cargo no se tocó (STK-1: consumidor, nunca proveedor).

- PARCHE 1 — feat(npc): nace `lua/entities/corpus_stalker_sidorovich.lua` (NextBot, clase
  prefijada STK-5, spawnable en Entities → Corpus). Sobre el demo suma: **(a)** salud 400 y
  muerte real — al morir **borra su stock antes del ragdoll** (el contenedor de sesión de
  Cargo derrama al mundo en el remove — regla de eyección de `corpus_cargo_containers.lua`;
  las instancias únicas se eliminan con `Instances.Delete` para no dejar huérfanos en
  `data/`) y **respawnea a los 60 s** en su punto de spawn con stock fresco (AttachTrader
  re-siembra); no looteable hoy ni cuando exista el loot de cadáveres (cruce Cortex §9) —
  solo matable. **(b) Mirada:** pose params `head_yaw`/`head_pitch` (male_shared) hacia el
  jugador vivo más cercano dentro del radio de la persona, tope de cuello ±60°/±25° y solo
  hemisferio frontal. **(c) Expresiones:** detección por nombre de los dos flexes del
  sidor.mdl — `blink` parpadea de verdad (triangular ~0,18 s cada 2,5–6 s) y `mouth` aletea
  0→1 **mientras dura el audio de la línea en curso** (`SoundDuration` con fallback por
  tamaño de archivo: los .ogg en Windows suelen devolver 0). **(d) Al piso:** el origen de
  un NextBot es la planta de los pies y la locomoción lo asienta con gravedad — con el
  origen correcto el IK de las secuencias ValveBiped apoya los pies como en un NPC normal.
  Reusa la persona (`Trade.GetDefaultPersona`) y porta del demo la voz por proximidad y los
  callbacks de trade (`OnTradeOpened/Dealt/Closed`); stock placeholder = kit dev de Cargo
  hasta que exista el catálogo de ítems de la Zona. **Deuda declarada:** Cargo no tiene
  trade_close server→cliente — una pantalla de trade abierta cuando él muere queda huérfana
  y degrada honesto («The trader is out of reach»). **[APLICADO 2026-07-24]**

Verificación (pasada en juego del autor): (a) spawnea con los pies en el piso, sin flotar;
(b) parpadea, y la boca aletea al hablar y queda quieta en silencio; (c) sigue con la cabeza
al jugador cercano y vuelve al frente cuando se va (si el cabeceo vertical sale invertido, el
signo está anotado en `SidorCara`); (d) E abre el trade igual que el demo, con las voces de
habar; (e) matarlo: **ningún ítem cae al piso**, ragdoll cosmético, y a los 60 s respawnea con
stock fresco (el ragdoll se retira al volver él); (f) el trader demo de Cargo sigue intacto.
**Confirmado en juego por el autor el 2026-07-24: checklist a-f completo ✓, y el +USE nativo
SÍ llega al NextBot** (el fallback por KeyPress queda de red de seguridad). Cuatro reportes y
un pedido de diseño de sonido salen de la pasada → la tanda de ajustes de abajo. Commiteado y
pusheado con el resto de la tanda (autorización del autor 2026-07-24).

---

## PARCHES DE sesión Ajustes post-pasada del NextBot + estándar de voz por acción — 2026-07-24

La pasada del NextBot pasó completa y dejó cuatro reportes (idles que ladean/sientan, vida,
animación a ~5 fps, respawn configurable) más un pedido de diseño: **estandarizar la voz del
trader por ACCIÓN** — carpeta por acción, cualquier sonido dentro entra al pool — para que
otros usuarios armen sus traders sobre este NextBot sin tocar Lua. La ruta admin «cualquier
entidad como trader» quedó anotada en el roadmap de Cargo (#45), no acá (CRG territorio).

- PARCHE 1 — fix(npc): **animación lentísima («a 5 fps»).** CAUSA RAÍZ (3.er intento,
  hallada siguiendo la pista del autor de comparar con el example NPC): el `Think` de la
  entidad frenaba al bot con `NextThink(CurTime() + 0.5)` — en un nextbot el engine cuelga
  del think la cadena de updates (BodyUpdate → `FrameAdvance`, que avanza **un paso fijo
  por llamada**), así que a 2 Hz la animación corría a ~3% de velocidad. **Verificado
  contra DrGBase** (`dev/other/drgbase`, espíritu CRG-24 — la base de nextbots más curtida
  del workshop): su Think JAMÁS llama NextThink ni devuelve true; todo lo lento corre
  detrás de gates internos (`CurTime() > delay`). Así queda acá: think sin frenar + gate de
  0,25 s para voz y rotación de idles. Cada secuencia se arranca además con la receta del
  base_nextbot (`PlaySequenceAndWait`, sv_nextbot.lua de Facepunch): `SetSequence` +
  `ResetSequenceInfo()` + `SetCycle(0)` + `SetPlaybackRate` (helper `SidorTocarIdle`) —
  DrGBase trae la misma, calcada. **Intentos fallidos anotados** (mismo trato que el
  precedente de Cargo, su CHANGELOG #9, para no repetirlos): 1.º `UseClientSideAnimation()`
  en el Initialize cliente — falló en juego, revertido; 2.º la receta `ResetSequenceInfo`
  sola, sin destrabar el Think — falló: la receta era correcta y necesaria, pero la anim
  seguía muerta de hambre por el think a 2 Hz. Rotación de idles por TIMER (12–25 s).
  **[APLICADO 2026-07-24]**
- PARCHE 2 — fix(npc): **idles solo DE PIE.** El autor vio al NPC ladeado a la pared y
  sentado: eran las `plazaidle1-4` (loiterers de la plaza del trainstation). El set queda
  `idle_subtle` / `idle01` / `lineidle01-03` (estándar, brazos cruzados, brazos caídos — las
  que pidió el autor), en la entidad Y en la persona del demo. Verificar en juego que
  ninguna `lineidle` se apoye; si una lo hace, se quita de la constante. **[APLICADO 2026-07-24]**
- PARCHE 3 — fix(npc): **vida 400 → 100** (estándar NPC/jugador, pedido del autor); queda
  como campo de subclase `TraderHealth`. **[APLICADO 2026-07-24]**
- PARCHE 4 — feat(npc): **convar `corpus_stalker_trader_respawn`** (segundos, default 60,
  `0` = no respawnea y el ragdoll queda; `FCVAR_ARCHIVE`). Sin UI a propósito (pedido del
  autor: «no es necesario que vaya a utilities»). **[APLICADO 2026-07-24]**
- PARCHE 5 — feat(npc): **estándar de voz por ACCIÓN.** Los sonidos de Sidorovich se
  reorganizan en `sound/npc/sidorovich/<accion>/` (about.txt de la carpeta reescrito con el
  mapa; ASSETS.md refleja: 23 → 31 voces, +pain1-4/death_1-4 que añadió el autor). Diez
  acciones: `greet_first` (sin sonido cae a `greet`) / `greet` / `wait` / `bye` /
  `trade_open_first` (cae a `trade_open`) / `trade_open` / `trade_done` / `trade_fail`
  (cerró la pantalla sin comprar — carpeta VACÍA esperando líneas en ruso: silencio, jamás
  error de Lua) / `pain` (OnInjured, gap 1,1 s) / `death` (la línea sale del RAGDOLL: la
  entity se remueve con BecomeRagdoll y un EmitSound propio moriría con ella). El NextBot
  escanea las carpetas con `file.Find` (pool cacheado por `VoiceDir`); la persona del demo
  escanea las mismas carpetas de saludo/trade. **Subclase:** un trader de terceros pisa los
  campos `ENT.Trader*`/`ENT.Voice*` (modelo, vida, plata, spread, stock, carpeta de voz,
  radio, espera) y hereda todo — el fallback de +USE ahora despacha por
  `isfunction(ent.SidorUsar)`, no por clase. **[APLICADO 2026-07-24]**
- PARCHE 6 — fix(npc): **sincronía de la boca con el fin del audio** (reporte del autor en
  la re-pasada). `SoundDuration` miente con .ogg en Windows y el fallback por tamaño
  (~7,5 KB/s) **sobreestimaba todas las líneas un 60–90%** (greet_2: 0,80 s reales vs
  1,84 s estimados) — la boca seguía aleteando ~1 s después del audio. Ahora la duración
  de un .ogg se lee **exacta del propio contenedor** (granule de la última página Ogg ÷
  sample rate del header Vorbis, `DuracionOgg` en la entidad), validada offline contra las
  31 voces (0,52–13,78 s @ 44,1 kHz). Vale para cualquier .ogg de terceros en las carpetas
  del estándar; `SoundDuration` → tamaño/7500 quedan de cadena de fallback (.wav/.mp3 o
  parse fallido). **[APLICADO 2026-07-24]**

Verificación (pasada en juego del autor): (a) la animación de idle se ve FLUIDA (no a 5 fps)
y ninguna pose ladea a la pared ni sienta al NPC; (b) muere con 100 HP y suelta quejido al
recibir daño (gap ~1 s) y línea de muerte desde el cadáver; (c) `corpus_stalker_trader_respawn
0` → no respawnea (ragdoll queda), `60` → vuelve al minuto; (d) abrir el trade y cerrarlo SIN
comprar: silencio (trade_fail vacía) y sin errores en consola; comprar algo y cerrar: no suena
trade_fail; (e) las voces de siempre (saludo/espera/despedida/habar) siguen sonando — ahora
desde las carpetas — tanto en el NextBot como en el trader demo de Cargo; (f) consola: el log
de la persona reporta líneas por carpetas de acción; (g) la boca se detiene JUNTO con el
audio (línea corta tipo pain ~0,5 s y línea larga tipo greet_first ~5 s, ambas al ras).
**Confirmado en juego por el autor el 2026-07-24: checklist a-g completo ✓** (anim fluida tras
el PARCHE 1 en su 3.ª forma; boca sincronizada tras el PARCHE 6). Commiteado y pusheado con
autorización del autor.
