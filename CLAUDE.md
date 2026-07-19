# CLAUDE.md

Guía para trabajar en **Corpus S.T.A.L.K.E.R.** (`corpus-stalker`) — el addon de contenido de la Zona
del ecosistema Corpus. Léela antes de tocar código o docs de este repo.

## Qué es

El ecosistema Corpus (framework + Cortex, Caliber, Coagulant, Craving, Cargo) es **genérico**: no sabe
nada de S.T.A.L.K.E.R. **Este addon es la capa que lo convierte en la Zona.** Aquí vive el contenido
del universo: anomalías, artefactos, PDA, detectores, defs de NPC para CortexBase, defs de ítem,
playermodels y facciones.

**Regla cardinal (STK-1):** este addon es un **consumidor**, nunca un proveedor. Hard-depende de Corpus
y detecta los módulos en runtime (`Corpus.GetModule` / `Corpus.HasModule`, nunca asumir — COR-5). **Nada
de lo que vive aquí sube al framework ni a un módulo** — Corpus es delgado y no contiene lógica de dominio
(COR-10);
los módulos son genéricos y no contienen contenido de un juego concreto. Si algo de aquí "necesita"
subir, la respuesta casi siempre es exponer un punto de extensión en el módulo, no mover el contenido.

## Estado

**Scaffold.** Hoy solo hay `lua/autorun/corpus_stalker_playermodels.lua` (registro de playermodels) y
los assets de ítem que consumen Cargo y Craving. Las entidades están **inventariadas y analizadas,
pero no escritas**.

## Docs — jerarquía de lectura

0. **Arquitectura del addon** → [`docs/STALKER_Arquitectura.md`](docs/STALKER_Arquitectura.md).
   Alcance, frontera, mapa de consumo por módulo y régimen de assets. **Léelo antes de escribir
   contenido nuevo** — dice contra qué se apoya cada dominio y qué pasa si el módulo no está.
1. **Assets** → [`docs/ASSETS.md`](docs/ASSETS.md). Qué hay, de qué pack sale cada ruta, cómo
   reconstruir el árbol. **Los assets NO están en el repo** (ver abajo).
2. **Inventario de los packs de origen** (no publicado, en `dev/`) → `dev/stalker_rp_packs_mapa.md`
   (6 packs, 3,2 GB: qué montar, qué NO, y la autopsia del código de referencia) y
   `dev/zona_stalkerrp_contenido.md` (packs ZONA de 2014). **Leerlos antes de copiar un solo asset.**
3. **Metodología** → `../corpus/docs/corpus_flujo_trabajo.txt` (doc canónico de todo el ecosistema).
4. **El framework** → `../corpus/docs/CORPUS_Architecture.md` (§3 API, §6 detección en runtime).
5. **Convenciones de commit** → [`docs/stalker_convenciones_commits.txt`](docs/stalker_convenciones_commits.txt).
   Alcances específicos de **este** repo (STK-9).

## Assets: no se versionan

**STK-2 — Los assets no se versionan.** `models/`, `materials/`, `sound/`, `particles/`, `resource/`
están en `.gitignore`. Son ports de S.T.A.L.K.E.R. propiedad de **GSC Game World**: la MIT de este repo
cubre el código, no los assets. No los añadas al repo, ni siquiera con `git add -f`.

**Rutas verbatim (STK-3, sede en [`docs/ASSETS.md`](docs/ASSETS.md)):** los `.mdl` referencian sus
materiales por ruta compilada (`cdmaterials`). Re-namespacear exigiría recompilar. No se toca ninguna
ruta de modelo.

**STK-8 — Política de assets de terceros:** crédito completo al autor original de cada port, y
retiro inmediato si un titular lo pide. El README público la enuncia en lenguaje de visitante;
la sede normativa es esta línea.

## Contratos que no debes romper

Los cuatro primeros **citan** normas del framework — su sede es `corpus/`, no acá; se repiten
porque son las que este addon rompe más fácil. Los dos últimos sí son propios de la Zona.

1. **COR-5 — Detección, nunca asunción.** Ningún archivo asume que Corpus u otro módulo ya cargó. Lazy
   check (`Corpus.GetModule`) o `Corpus.OnReady` para wiring que corre una vez.
2. **COR-6 — Prefijo de archivo:** `corpus_stalker_*.lua`, para no colisionar con los seis addons
   hermanos montados a la vez.
3. **COR-12 — Defs contra Cargo: en ambos realms.** Las defs **y** sus `onUse` van en `shared` — la UI
   exige `isfunction(onUse)` client-side, aunque la closure solo corra en server. Ya lo pagaron Craving
   y Coagulant. Sede con la causa completa: `corpus/docs/CORPUS_Architecture.md` §5.
4. **COR-3 / COR-4 — Persistencia y net namespaced** vía las primitivas de Corpus (`Corpus.Data`,
   `Corpus.Net`), nunca `net.Receive` con nombres crudos.
5. **STK-4 — No copiar el código de los packs de referencia.** Está roto y es peligroso (monkeypatch
   global de `engine.IsMounted`, hook que anula las explosiones de todo el servidor, `net.ReadTable()`
   sin validar admin, artefactos que no hacen nada). Se reescribe. Ver `dev/stalker_rp_packs_mapa.md` §5.
6. **STK-5 — Nombres de clase de entidad prefijados.** Los packs de origen usan `blood`, `fire`,
   `teleport`, `control`… — colisión garantizada. Aquí van como `corpus_stalker_<cosa>`.

## Idioma y commits

Comentarios y mensajes de commit en **español**; los `<tipo>` de commit en inglés. Convenciones:
[`docs/stalker_convenciones_commits.txt`](docs/stalker_convenciones_commits.txt) — **el doc manda**;
de él salen los alcances de este repo (**STK-9**, §3). Las secciones **0/1/2/4/5** (estructura,
tipos, formato) se heredan de `../corpus/docs/corpus_convenciones_commits.txt`; **su §3 NO aplica
acá**, es el mapa de primitivas del framework (GIT-6 — la §3 es por repo).

Alcances **en uso**: `assets`, `repo`, `docs`. **Reservados** hasta que su contenido se escriba:
`anomalias`, `artefactos`, `pda`, `detectores`, `npc`, `items`, `models`. Los tres commits
existentes (`docs(assets)`, `docs(docs)`, `chore(repo)`) ya son conformes. `chore` es un **tipo**,
no un alcance.

## Verificación

No hay test runner (es un addon GMod): se carga el mapa y se confirma en consola/juego. El autor corre
la pasada en juego. Ver `corpus_flujo_trabajo.txt` §1 (Paso 4).

## Git

Repo publicado en GitHub (`github.com/Sepuldosky/corpus-stalker`, público). **No hagas commit ni push
salvo que se pida explícitamente** (política unificada del ecosistema — cita GIT-7; voto del autor
2026-07-19). **No agregues el trailer `Co-Authored-By: Claude`** ni ninguna atribución de
co-autoría a Claude/Anthropic en los commits.
