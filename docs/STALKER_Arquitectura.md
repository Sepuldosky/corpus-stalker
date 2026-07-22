# Corpus S.T.A.L.K.E.R. — Arquitectura del addon de contenido

> **Uso de este documento:** diseño del addon de **contenido** de la Zona. Autocontenido: no hace falta la arquitectura del framework para entenderlo, aunque sí para implementarlo (`../../corpus/docs/CORPUS_Architecture.md` §3 API, §6 detección en runtime).
>
> **Estado: MÍNIMA.** Este doc nace el 2026-07-19 con el alcance, la frontera y el mapa de consumo por módulo — lo que hace falta para que nadie escriba la primera anomalía sin saber contra qué se apoya. El diseño detallado de cada dominio (anomalías, artefactos, PDA, detectores) llega con su propio bloque, y cada uno puede desprender su doc particular (patrón de `corpus_flujo_trabajo.txt` §2).
>
> **Por qué existe** (deuda D-13, hueco H5 del COMPLETO del 2026-07-19): este repo tenía 6 IDs `STK-` acuñados, **5 con sede en su `CLAUDE.md`** — o sea que el `CLAUDE.md` estaba haciendo de arquitectura, exactamente lo que §2 del flujo dice que no debe pasar. Un `CLAUDE.md` es guía operativa (nivel 4); el diseño va en un doc de diseño.

---

## Índice

1. [Qué es este addon y qué NO es](#1-qué-es-este-addon-y-qué-no-es)
2. [La frontera: consumidor puro](#2-la-frontera-consumidor-puro)
3. [Mapa de consumo por módulo](#3-mapa-de-consumo-por-módulo)
4. [Dominios de contenido](#4-dominios-de-contenido)
5. [Assets: el régimen de terceros](#5-assets-el-régimen-de-terceros)
6. [Los packs de referencia: qué se recicla y qué no](#6-los-packs-de-referencia-qué-se-recicla-y-qué-no)
7. [Degradación honesta](#7-degradación-honesta)
8. [Estado de este documento](#8-estado-de-este-documento)

---

## 1. Qué es este addon y qué NO es

El ecosistema Corpus es **genérico por diseño**: el framework aloja infraestructura compartida (**COR-10**), y los cinco módulos poseen dominios abstractos — inventario, medicina, combate, supervivencia, IA. Ninguno sabe qué es un artefacto, una anomalía ni la Zona.

**Este addon es la capa que los convierte en S.T.A.L.K.E.R.** Es la séptima raíz del workspace y la única que no es ni el framework ni un módulo.

La distinción que más se malinterpreta: **no es un sexto módulo**. Un módulo POSEE un dominio y expone superficie para que otros lo consuman; este addon **no expone nada** — solo consume. Si algún día algo de acá pareciera necesitar exponerse, la respuesta correcta casi siempre es abrir un punto de extensión en el módulo dueño, no mover el contenido (**STK-1**).

## 2. La frontera: consumidor puro

**STK-1 —** consumidor, nunca proveedor. Se traduce en tres reglas operativas:

- **Hard-dep: solo Corpus** (cita **COR-11**). Los cinco módulos son soft-deps y se detectan en runtime con `Corpus.GetModule` / `Corpus.HasModule` — jamás se asumen (cita **COR-5**). El orden de mount no está garantizado.
- **Nada sube.** Ni al framework (lo prohíbe **COR-1**/**COR-10**) ni a un módulo: un módulo que aprendiera qué es un artefacto dejaría de ser genérico y arrastraría la Zona a todos los que lo usen.
- **Prefijo propio** (cita **COR-6**): `corpus_stalker_*.lua` en todo lo que cargue el engine. Con siete addons montados a la vez, el prefijo es lo único que evita que dos archivos con el mismo nombre se pisen en el merge de `lua/autorun/`.

## 3. Mapa de consumo por módulo

Qué le pide este addon a cada módulo, y qué pasa si no está. **Ninguna fila es una hard-dep.**

| Módulo | Qué se consume | Superficie | Sin él |
|---|---|---|---|
| **Corpus** (hard) | Registro, persistencia, net, UI shell, ready barrier, log | Las 6 primitivas de §3 | El addon **no arranca** — falla ruidoso, no silencioso |
| **Cargo** | Defs de ítem (artefactos, consumibles, munición, equipo), grid, peso, contenedores | `Cargo.Items.Register`, `Inventory.*`, `StatusPanel.RegisterBar` | Los ítems no se registran: se apagan con log. Las entidades de mundo siguen existiendo |
| **Cortex** | Defs de NPC y datos de facción para CortexBase | `GetFactionInfo` y la superficie de defs de su Block (aún sin abrir) | Sin NPCs propios de la Zona; el resto del contenido funciona |
| **Coagulant** | Efectos clínicos de la radiación y de las anomalías químicas | `ApplyExternalCondition(ply, id, severity)` — la firma que **CRV-4** congeló | Sin efectos clínicos; el daño cae al HP nativo |
| **Caliber** | Mitigación de trajes de la Zona (armadura zonal) | Su pipeline de armadura de **jugador** — Block 3, todavía abierto | Los trajes pesan y se equipan, sin efecto de mitigación |
| **Craving** | Consumibles de la Zona (comida, agua, vodka) | Su tabla de consumibles y el `onUse` | Los consumibles quedan como ítems inertes de Cargo |

> **Trampa de realms, ya pagada dos veces por otros repos** (cita **COR-12**, sede `CORPUS_Architecture.md` §5): toda def registrada contra Cargo va en **`shared`** — la def **y** su `onUse`. La UI de Cargo exige `isfunction(def.onUse)` **client-side** para mostrar "Use", aunque la closure solo corra en server. Registrarla solo en server produce un ítem **visible pero inusable**. Lo pagaron Craving y Coagulant; este repo es el próximo que registrará ítems, así que queda anotado antes de escribir el primero.

## 4. Dominios de contenido

Inventariados y analizados; **ninguno escrito todavía** salvo los playermodels. Cada uno abre su propio bloque de diseño.

| Dominio | Qué es | Módulos que toca |
|---|---|---|
| **Anomalías** | Entidades de zona con daño por proximidad: eléctrica, térmica, gravitatoria, química | Coagulant (efecto clínico), Caliber (mitigación por traje) |
| **Artefactos** | Ítems con efecto pasivo mientras están equipados, y radiación como contrapeso | Cargo (def + sub-slot), Coagulant (radiación) |
| **PDA** | UI propia: mapa, contactos, tareas | Corpus (UI shell — **COR-15**: una sola entrada en el menú Q) |
| **Detectores** | Ítems que señalan artefactos cercanos con feedback audible/visual | Cargo (def), anomalías/artefactos (lectura) |
| **Defs de NPC** | Stalkers, mutantes y sus facciones para CortexBase | Cortex |
| **Defs de ítem** | Consumibles, munición y equipo de la Zona | Cargo, Craving |
| **Playermodels** | Registro de modelos jugables — **lo único implementado hoy** | Ninguno (registro directo del engine) |
| **Facciones** | Datos de facción: nombre, relaciones, colores | Cortex (`GetFactionInfo`) |

**STK-5 — Nombres de clase de entidad prefijados.** Los packs de origen usan `blood`, `fire`, `teleport`, `control`… — colisión garantizada con cualquier otro addon del servidor. Acá van como `corpus_stalker_<cosa>`. Es la misma razón que **COR-6**, aplicada al registro de `scripted_ents` en vez de al nombre de archivo.

## 5. Assets: el régimen de terceros

**STK-2 — Los assets no se versionan.** `models/`, `materials/`, `sound/`, `particles/` y `resource/` están en `.gitignore`. Son ports de contenido propiedad de **GSC Game World**: la licencia MIT de este repo cubre **el código, no los assets**. No se añaden al repo ni con `git add -f`.

**STK-3 — Rutas verbatim** (sede: [`ASSETS.md`](ASSETS.md)). Los `.mdl` referencian sus materiales por ruta compilada (`cdmaterials`); re-namespacear exigiría recompilar cada modelo. Ninguna ruta de modelo se toca — se conserva exactamente como viene del pack de origen.

**STK-8 — Política de atribución:** crédito completo al autor original de cada port, y retiro inmediato si un titular lo pide. El README lo enuncia en lenguaje de visitante; la sede normativa es el `CLAUDE.md`.

La consecuencia práctica de las tres juntas: **el repo es solo código y docs**, y el árbol de assets se reconstruye desde los packs de origen siguiendo [`ASSETS.md`](ASSETS.md). Quien clone esto sin los packs tiene un addon que carga y no muestra nada — es el comportamiento esperado, no un bug.

## 6. Los packs de referencia: qué se recicla y qué no

**STK-4 — No se copia el código de los packs de referencia.** Está roto y es activamente peligroso; el inventario completo está en `dev/stalker_rp_packs_mapa.md` §5. Los cuatro hallazgos que lo condenan:

- **Monkeypatch global de `engine.IsMounted`** — miente a todos los demás addons del servidor.
- **Un hook que anula las explosiones del servidor entero**, no solo las propias.
- **`net.ReadTable()` sin validar admin** — ejecución de datos arbitrarios del cliente.
- **Artefactos que no hacen nada**: la def existe, el efecto nunca se implementó.

Todo se **reescribe**. Lo que sí se reutiliza de esos packs son los **assets** (bajo el régimen de §5) y las **ideas de diseño**: qué anomalías existen, cómo se sienten, qué artefacto sale de cuál.

La distinción general del ecosistema entre **RECICLAR** (copiar código o assets → importa la licencia) y **COMPAT-RUNTIME** (detectar y consumir por API → la licencia no importa) vive en `dev/mods_workshop_mapa.md`, y hay que consultarla antes de diseñar cualquier integración con un mod ajeno.

## 7. Degradación honesta

Este addon es el consumidor con **más** soft-deps del ecosistema —los cinco módulos—, así que es donde la degradación honesta más se nota. La regla: **cada dominio de contenido tiene que ser jugable con el subconjunto de módulos que esté montado**, y lo que falte se apaga con un log, nunca con un error.

Concretamente, la degradación NO es por presencia sino por **capacidad** — el patrón que Craving fijó en **CRV-2**/**CRV-3**: un módulo montado pero sin la función que se necesita cae al mismo fallback que su ausencia. Preguntar `Corpus.HasModule("coagulant")` y asumir que entonces `ApplyExternalCondition` existe es el bug que ese par de normas existe para prevenir.

## 8. Estado de este documento

Mínimo y honesto: fija alcance, frontera y mapa de consumo. **No diseña ningún dominio** — eso llega con cada bloque.

| Sección | Estado |
|---|---|
| Frontera y consumo por módulo | **Cerrado** |
| Régimen de assets y packs de referencia | **Cerrado** |
| Anomalías / Artefactos / PDA / Detectores | Pendiente — bloque de diseño propio cada uno |
| Defs de NPC y facciones | Pendiente — **bloqueado** por el Block de Cortex, que no abrió |

> **Deuda anotada (2026-07-19):** cinco de los nueve IDs `STK-` (STK-1, STK-2, STK-4, STK-5, STK-8) siguen con **sede en el `CLAUDE.md`**, y este doc los **cita**. Consolidarlos acá es la continuación natural de la deuda D-3, pero mover una sede es decisión del autor y no se hizo por cuenta propia en la tanda que creó este archivo.
