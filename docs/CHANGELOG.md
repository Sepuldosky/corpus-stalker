
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

---

## PARCHES DE sesión El trader de Cargo soltó sus referencias vivas: Sidorovich se adapta — 2026-07-26

**Esta tanda es reactiva y no nació acá.** Cargo saneó la entidad del trader (su CHANGELOG, entry
45): `duplicator.CopyEntTable` hace `table.Merge(data, ent:GetTable())` quitando solo las funciones,
así que la Entity y el set de viewers que colgaban de `ent.CargoTrader` entraban a cualquier
duplicación y a cualquier `gm_save`. Se mudaron a una tabla del módulo indexada por id de sesión, y
con ellas se fue el campo `cont` — que arrastraba el stock entero.

Sidorovich leía los tres. **Sin este parche, matarlo tira `attempt to index a nil value` dentro de
`OnKilled`, y ese error se lleva puestos el ragdoll y el respawn.** Se detectó al correr el saneo
del lado de Cargo, no en juego: el repo no estaba entre las raíces declaradas de esa tanda, y el
autor decidió cerrarlo en la misma pasada en vez de dejar el módulo roto entre tandas.

- PARCHE 1 — fix(npc): **`OnKilled` pide el stock por la API.** `trader.cont.items` →
  `Trade.StockOf(trader)`, y `table.Empty(trader.viewers)` → `Trade.ClearViewers(trader)`. Van por
  un helper `TradeAPI(nombre)` con el lazy check de siempre (COR-5): sin Cargo montado, o con un
  Cargo viejo que no tenga la función, degrada en silencio y jamás revienta — que es justo lo que
  faltaba para que este acople no fuera frágil. El borrado de instancias del stock (para no dejar
  huérfanas) queda igual. **[APLICADO 2026-07-26]**
- PARCHE 2 — fix(npc): **la espera del `SidorVozThink` pregunta por la API.**
  `trader.viewers[ply]` → `Trade.HasViewer(trader, ply)`. Mismo efecto: no se le habla al que tiene
  la pantalla abierta. **[APLICADO 2026-07-26]**
- PARCHE 3 — fix(npc): **`ENT.SidorVoz` deja de indexarse por Player.** Era el mismo defecto que
  Cargo acaba de sacarse de encima, en esta entidad y sin que nadie lo hubiera mirado: una tabla
  `{ [Player] = { esperaProx } }` viviendo directo sobre la entity, que el duplicator copia. Pasa a
  SteamID64 — dato plano, y `SidorSaludados` ya usaba esa misma clave. La poda cambia de "borrar los
  Player inválidos" a "borrar a los que se DESCONECTARON": así el que muere cerca conserva su
  estado y reaparecer no vuelve a disparar el saludo. **[APLICADO 2026-07-26]**

Verificación offline: los tres archivos Lua de este repo parsean con el LuaJIT del harness de Cargo.
El grueso lo cubre el harness de Cargo (418 verdes), que ejercita la API nueva del lado del módulo.

- PARCHE 4 — fix(npc): **el estado de sesión no se hereda de un savegame.** Reporte de la ronda 2
  del check Q3 (2026-07-26): tras cargar una partida, Sidorovich **no respondía al USE**, «seguía
  hablando infinitamente» y tenía **la cara deformada**. Tres síntomas, una causa: el duplicator
  restaura los campos planos de la entidad, y **`CurTime()` arranca de cero al cargar el mapa**, así
  que todo sello de tiempo heredado queda en el futuro para siempre. `Initialize` reiniciaba trece
  campos y **se le escapaban cinco** — `SidorHablaHasta` (la boca se anima contra un plazo que no
  llega: el habla infinita y la cara deforme), `SidorProxUso` (el candado anti doble-USE nunca
  vence: por eso no se le podía hablar), `SidorProxLento`, `SidorProxDolor` y `SidorMuerto`, que no
  dio la cara pero es el peor de todos: heredado en `true` deja un trader muerto de pie. Ahora el
  bloque es uno solo, enumerado **desde el árbol** (§7.2). **[APLICADO 2026-07-26]**
- PARCHE 5 — fix(npc): **el reinicio se verifica AL LEER, no al nacer.** El PARCHE 4 reiniciaba en
  `Initialize` y **no alcanzó**: la 2.ª corrida de Q3 (con foto) volvió con los tres síntomas
  intactos. Ese fallo es la evidencia que faltaba — si el reset hubiera quedado en pie,
  `SidorProxUso = 0` habría destrabado el USE; no lo hizo, así que **el duplicator escribe los
  campos planos DESPUÉS** de `Initialize` y pisa cualquier reinicio hecho al nacer. Reiniciar en el
  constructor depende de un orden que no controlamos.
  Ahora hay un **sello de sesión**: `SESION` es una tabla nueva por carga de mapa (este archivo se
  re-ejecuta en cada arranque) y todo el estado se marca con ella. Las cuatro entradas que leen ese
  estado —`SidorCara` y `Think`, que corren cada frame, más `SidorUsar` y `OnKilled`, que son las
  que quedaban colgadas— preguntan primero por `SidorSesionViva()`: si el sello no es el de esta
  sesión, el estado llegó de un savegame y se descarta ahí mismo, sin importar cuándo lo
  escribieron. Los índices de flex entran en el reinicio: heredar el número hace que apunte a otro
  morph si el modelo que cargó no es el que guardó la partida.
  Es exactamente la forma que arregló el contenedor del lado de Cargo (su entry 45, PARCHE 6): **no
  confiar en el campo, validarlo contra lo vivo.** La diferencia entre los dos arreglos explica por
  qué uno funcionó a la primera y el otro no: el de Cargo validaba al leer, este reiniciaba al
  nacer. **Devolvió el USE y el comercio**, confirmado en la 3.ª corrida de Q3 — la cara siguió
  rota, y esa mitad la cierra el PARCHE 6. **[APLICADO 2026-07-26]**
- PARCHE 6 — fix(npc): **la cara estirada tenía una cuenta detrás, y el clamp que faltaba.** La
  3.ª corrida de Q3 llegó con una foto de dos Sidorovich lado a lado —el cargado deforme, el recién
  spawneado perfecto— que aisló el defecto sin ambigüedad. La causa es aritmética: el parpadeo es un
  triángulo `peso = 1 - |t / 0,18 * 2 - 1|` que **da por sentado que `t` es positivo**. Con
  `SidorParpadeoDesde` heredado de la partida guardada —mayor que el `CurTime()` nuevo, que arranca
  de cero— `t` sale NEGATIVO, entra igual en la rama porque `-495 < 0,18`, y el peso se va a
  **-5500** (verificado con la constante real del archivo, no estimado). Un `SetFlexWeight` con ese
  valor dispara los vértices por el lado negativo del morph: la púa de la foto.
  Dos arreglos, y hacen falta los dos. **(a) `math.Clamp(peso, 0, 1)`** — con el mismo `t` imposible
  el peso pasa a 0, así que ningún sello heredado ni ningún `t` fuera de rango puede volver a
  deformar el modelo. **(b) cerar TODOS los flexes al iniciar sesión**, antes de re-resolver los
  índices: este código solo reescribe los dos que conoce, así que un morph que quedó movido se queda
  movido para siempre — y si el nombre no aparece en el modelo montado, el índice queda `nil` y ni
  esos dos se reescriben. Sin (b) una cara ya estirada no se endereza aunque el sello funcione; sin
  (a) se vuelve a estirar. **La cara dejó de deformarse, y el clamp destapó que estaba TAPANDO**:
  ver el PARCHE 7. **[APLICADO 2026-07-26]**
- PARCHE 7 — fix(npc): **un segundo candado, por VALOR, porque el sello no dispara.** La 4.ª corrida
  de Q3 volvió con «arreglaron los flexes deformes, **pero no parpadea**, la boca nace hablando pero
  al decir algo se arregla», y ese cuadro es un diagnóstico completo: el plazo heredado **seguía
  ahí**. Con `SidorParpadeoDesde` de otra partida, `t` es siempre negativo, así que antes del clamp
  el peso era -5500 (cara estirada) y después del clamp es 0 **para siempre** — de ahí que no
  parpadee. El clamp no arregló nada: convirtió un síntoma visible en uno silencioso. Y la boca
  moviéndose hasta hablarle confirma lo mismo desde el otro lado: el reinicio solo corría en
  `SidorUsar`, no en `SidorCara`.
  O sea que el **sello de sesión del PARCHE 5 no está disparando** en el camino que corre cada
  frame. No se pudo determinar por qué desde fuera del juego, así que se dejó de depender de él:
  `PlazoImposible` compara cada plazo contra la **cota exacta de la línea que lo escribe**
  (`SidorParpadeoDesde` = `ahora`; `SidorProxUso` = `ahora + 0,4`; `SidorProxLento` = `ahora + 0,25`;
  `SidorProxParpadeo` ≤ `ahora + 6`; `SidorProxIdle` ≤ `ahora + 25`). Ninguno puede superar su cota
  dentro de una sesión porque el tiempo solo avanza: si lo hace, vino de otra partida, sin
  preguntarle nada al duplicator. Verificado fuera del juego con la aritmética real — detecta la
  entidad heredada, no se realimenta tras el reinicio, y **cero falsos positivos en 200 000 frames
  sanos**. El sello se queda como primer candado: cubre los índices de flex, las tablas de voz y la
  marca de muerte, que no tienen forma de «valor imposible». **[APLICADO 2026-07-26]**

Verificación offline: no hay forma de cubrir esto en el harness —los archivos de `lua/entities/` los
carga el engine, no el manifest del módulo— así que solo se verificó que el archivo parsea con el
LuaJIT del harness de Cargo. La prueba real es Q3.

Verificación en juego: **va con la planilla `Q` de Cargo**, que es donde vive esta tanda. Tres checks
tocan a este repo: **Q4** (el slice 1 del comercio sigue igual — con Sidorovich montado corre sobre
él y no sobre el demo, porque es el trader que el autor usa de verdad), **Q5** (matarlo y confirmar
ragdoll y respawn, que es lo que el `nil` de `OnKilled` rompía; va como check propio y no dentro de
Q4 a propósito: son dos cosas que fallan por motivos distintos) y **Q3**, que terminó siendo el que
más costó — el savegame.
Planilla: https://claude.ai/code/artifact/5734e521-db27-400d-9693-0fc1e12a85a9

**Confirmado en juego por el autor el 2026-07-26**, tras seis rondas: Q4 y Q5 cerraron en la
primera; Q3 necesitó los PARCHES 4-7, en este orden — reiniciar en `Initialize` (no alcanzó),
sellar la sesión (devolvió el USE y el comercio, no la cara), acotar el peso del flex (quitó la
deformación pero mató el parpadeo) y por fin el candado por valor (todo en su sitio).

**La lección del repo, y es de método:** los tres primeros intentos se apoyaban en *cuándo* corre el
código, y el orden en que el duplicator escribe no se puede observar desde fuera del juego. El que
funcionó se apoya en *qué valores son posibles*. **Cuando el orden no es observable, el invariante
tiene que ser de valor.** El contenedor de Cargo ya lo hacía —pregunta si el id está vivo, no cuándo
llegó— y fue el único que salió bien a la primera.

---

## PARCHES DE sesión Los ítems médicos de Coagulant dejan de sustituirse — 2026-08-06

Decisión del autor. Hasta hoy `corpus_stalker_itemmodels.lua` le ponía `wick_bandage` a la Bandage
de Coagulant y `medkit_low` a su Medkit. Se retira, por dos motivos, y el segundo es el que manda:

1. **Coagulant ya trae los suyos** desde el 2026-08-05: 19 `.mdl` propios (CC BY 4.0) en
   `models/corpus_coagulant/`. La sustitución dejó de tapar la cajita de cartón del drop y pasó a
   tapar un modelo bueno.
2. **Un botiquín de la Zona no es una piel del genérico, es otro ítem.** Un `medkit_army` tiene
   otro peso, otro precio y otra curación que el Medkit de Coagulant; vestir al genérico con su
   modelo miente sobre lo que es — el jugador ve un botiquín militar de STALKER y recibe los
   números del genérico. El lugar de esos modelos son **defs de ítem propias de la Zona**.

- PARCHE 1 — fix(models): se sacan las dos entradas de `corpus_coagulant_*` de `SUSTITUCIONES` en
  `lua/autorun/corpus_stalker_itemmodels.lua`. El header del archivo pasa a decir por qué, y deja
  escrita la distinción que hace correcta a la sustitución que **sí** queda. **[PENDIENTE]**

- PARCHE 2 — docs(assets): alta de `docs/ASSETS.md` §1.4 — los cuatro modelos médicos
  (`medkit_low/med/high` + `wick_bandage`) quedan **sin consumidor**, esperando defs propias. Se
  actualizan las dos filas de §1.1 y el comentario del script de reconstrucción, más el `README.md`
  y el «Estado» del `CLAUDE.md`. **[APLICADO 2026-08-06]**

**LO QUE SÍ QUEDA, Y POR QUÉ ES DISTINTO: las dos mochilas de Cargo.** Ésas se registran **sin
modelo a propósito** (`corpus_cargo_supplies.lua`: *"The backpacks declare NO model on purpose: HL2
has no backpack prop"*). Ahí no se tapa nada — se llena un hueco que el módulo dueño dejó abierto
para un addon de contenido. **Llenar un hueco no es pisar un modelo**, y ésa es la regla con la que
se decide la próxima vez.

**Lo que NO se hizo:** no se escribieron los defs de ítem de la Zona. El alcance de commit `items`
sigue **RESERVADO**, y STK-1 + COA-28 mandan — el diseño se acuerda con el autor y se anota antes de
bajarlo a código. Que el modelo exista no crea el ítem. Los cuatro `.mdl` siguen en el árbol de
assets (no versionado, STK-2) esperándolos.

Verificación offline: sintaxis Lua válida (`luaparser`). El PARCHE 1 toca runtime y nace
`[PENDIENTE]`: falta la pasada en juego — qué mirar es que la venda y el medkit de Coagulant
dropeen con **su** modelo y no con el de la Zona, y que las dos mochilas sigan con el suyo.

---

## PARCHES DE sesión Sidorovich no moría: el `hook.Run` de `OnKilled` sin protección — 2026-08-17

Reportado por el autor: al dispararle a Sidorovich y matarlo, **no muere** — se queda de pie, en
su sitio, con 0 de vida y mudo al USE. La **causa** era de corpus-caliber (su listener de
`OnNPCKilled` llamaba `GetActiveWeapon()` sobre este nextbot, método que el metatable `NextBot`
no tiene; parche en el CHANGELOG de ese repo, misma fecha). Este parche es la otra mitad: la que
hace que un tercero que explote **no pueda volver a hacer esto**.

`ENT:OnKilled` dispara `hook.Run("OnNPCKilled", …)` y **tiene que dispararlo antes del
`BecomeRagdoll`** — los listeners necesitan la entidad todavía viva, y el ragdoll la remueve. Pero
`hook.Run` no atrapa errores: la excepción de un listener sube por la pila y **aborta todo lo que
venía después en `OnKilled`**, incluido ese mismo `BecomeRagdoll`, la línea de muerte y el timer
de respawn. Sin `BecomeRagdoll` la entidad nunca se remueve: queda parada con la vida en 0.

**Y es permanente, no un fallo del primer golpe.** `self.SidorMuerto = true` se setea *arriba* del
`hook.Run`. Cada disparo posterior vuelve a llamar a `OnKilled` y sale por el `return` de ese flag:
el trader **no puede morir nunca más**, y `SidorUsar` corta por el mismo campo, de ahí el mudo al
USE. El log del autor lo mostraba entero — 20 impactos de Caliber después del error, sin un solo
`OnKilled` nuevo. Esa asimetría (el daño se sigue registrando, la muerte no se vuelve a intentar)
es la firma del defecto, y es lo que separa "murió mal" de "quedó atrapado".

- PARCHE 1 — fix(npc): `lua/entities/corpus_stalker_sidorovich.lua` — el `hook.Run("OnNPCKilled",
  …)` queda **donde estaba** (no puede moverse, ver arriba) pero envuelto en `ProtectedCall`, que
  reporta el error en consola con stack —vía `ErrorNoHaltWithStack`— sin frenar la ejecución. Un
  `pcall` pelado se lo habría comido en silencio, que para un bug de terceros es peor que el bug.
  El atacante y el inflictor se leen a locales antes del closure. **[PENDIENTE]**

**Por qué van los dos parches y no solo el de Caliber.** Arreglar únicamente al listener culpable
deja la trampa armada para el próximo addon que escuche `OnNPCKilled` — y son varios los que lo
hacen. La regla que queda: **un `hook.Run` en medio de una secuencia irreversible es una dependencia
de terceros**, y se protege como tal. Vale para cualquier trader que subclasee esta entidad, que
hereda este `OnKilled` tal cual.

Verificación (PASO 4, del autor): matarlo con el scavenger de Caliber **encendido**. Criterio:
ragdoll + línea de muerte + respawn según `corpus_stalker_trader_respawn`. Y el caso que de verdad
prueba el parche: **si Caliber vuelve a tirar el error en consola pero el trader igual muere y
ragdollea**, esta capa está haciendo su trabajo y el defecto que quedó vivo es el del otro repo —
los dos parches se verifican por separado, no se cubren entre sí.

**Ojo al probar:** un Sidorovich que ya quedó trabado en la sesión **sigue trabado** — tiene
`SidorMuerto = true` en memoria y un autorefresh de Lua no lo limpia. Hay que removerlo a mano o
recargar el mapa antes de la pasada.
