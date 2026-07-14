# CLAUDE.md

Guía para trabajar en **Corpus S.T.A.L.K.E.R.** (`corpus-stalker`) — el addon de contenido de la Zona
del ecosistema Corpus. Léela antes de tocar código o docs de este repo.

## Qué es

El ecosistema Corpus (framework + Cortex, Caliber, Coagulant, Craving, Cargo) es **genérico**: no sabe
nada de S.T.A.L.K.E.R. **Este addon es la capa que lo convierte en la Zona.** Aquí vive el contenido
del universo: anomalías, artefactos, PDA, detectores, defs de NPC para CortexBase, defs de ítem,
playermodels y facciones.

**Regla cardinal:** este addon es un **consumidor**, nunca un proveedor. Hard-depende de Corpus y
detecta los módulos en runtime (`Corpus.GetModule` / `Corpus.HasModule`, nunca asumir). **Nada de lo
que vive aquí sube al framework ni a un módulo** — Corpus es delgado y no contiene lógica de dominio;
los módulos son genéricos y no contienen contenido de un juego concreto. Si algo de aquí "necesita"
subir, la respuesta casi siempre es exponer un punto de extensión en el módulo, no mover el contenido.

## Estado

**Scaffold.** Hoy solo hay `lua/autorun/corpus_stalker_playermodels.lua` (registro de playermodels) y
los assets de ítem que consumen Cargo y Craving. Las entidades están **inventariadas y analizadas,
pero no escritas**.

## Docs — jerarquía de lectura

1. **Assets** → [`docs/ASSETS.md`](docs/ASSETS.md). Qué hay, de qué pack sale cada ruta, cómo
   reconstruir el árbol. **Los assets NO están en el repo** (ver abajo).
2. **Inventario de los packs de origen** (no publicado, en `dev/`) → `dev/stalker_rp_packs_mapa.md`
   (6 packs, 3,2 GB: qué montar, qué NO, y la autopsia del código de referencia) y
   `dev/zona_stalkerrp_contenido.md` (packs ZONA de 2014). **Leerlos antes de copiar un solo asset.**
3. **Metodología** → `../corpus/docs/corpus_flujo_trabajo.txt` (doc canónico de todo el ecosistema).
4. **El framework** → `../corpus/docs/CORPUS_Architecture.md` (§3 API, §6 detección en runtime).

## Assets: no se versionan

`models/`, `materials/`, `sound/`, `particles/`, `resource/` están en `.gitignore`. Son ports de
S.T.A.L.K.E.R. propiedad de **GSC Game World**: la MIT de este repo cubre el código, no los assets.
No los añadas al repo, ni siquiera con `git add -f`.

**Rutas verbatim:** los `.mdl` referencian sus materiales por ruta compilada (`cdmaterials`).
Re-namespacear exigiría recompilar. No se toca ninguna ruta de modelo.

## Contratos que no debes romper

1. **Detección, nunca asunción.** Ningún archivo asume que Corpus u otro módulo ya cargó. Lazy check
   (`Corpus.GetModule`) o `Corpus.OnReady` para wiring que corre una vez.
2. **Prefijo de archivo:** `corpus_stalker_*.lua` en `lua/autorun/...`, para no colisionar con los
   seis addons hermanos montados a la vez.
3. **Defs contra Cargo: en ambos realms.** Las defs **y** sus `onUse` van en `shared` — la UI exige
   `isfunction(onUse)` client-side, aunque la closure solo corra en server. Ya lo pagaron Craving y
   Coagulant.
4. **Persistencia y net namespaced** vía las primitivas de Corpus (`Corpus.Data`, `Corpus.Net`), nunca
   `net.Receive` con nombres crudos.
5. **No copiar el código de los packs de referencia.** Está roto y es peligroso (monkeypatch global de
   `engine.IsMounted`, hook que anula las explosiones de todo el servidor, `net.ReadTable()` sin
   validar admin, artefactos que no hacen nada). Se reescribe. Ver `dev/stalker_rp_packs_mapa.md` §5.
6. **Nombres de clase de entidad prefijados.** Los packs de origen usan `blood`, `fire`, `teleport`,
   `control`… — colisión garantizada. Aquí van como `corpus_stalker_<cosa>`.

## Idioma

Comentarios y mensajes de commit en **español**; los `<tipo>` de commit en inglés. Convenciones:
`../corpus/docs/corpus_convenciones_commits.txt`.

## Verificación

No hay test runner (es un addon GMod): se carga el mapa y se confirma en consola/juego. El autor corre
la pasada en juego. Ver `corpus_flujo_trabajo.txt` §1 (Paso 4).

## Git

Repo publicado en GitHub (`github.com/Sepuldosky/corpus-stalker`, público). **No hagas push salvo que
se pida explícitamente.** **No agregues el trailer `Co-Authored-By: Claude`** ni ninguna atribución de
co-autoría a Claude/Anthropic en los commits.
