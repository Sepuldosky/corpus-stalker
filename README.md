# Corpus S.T.A.L.K.E.R. (`corpus-stalker`)

**El addon de contenido de S.T.A.L.K.E.R. del ecosistema [Corpus](https://github.com/Sepuldosky/corpus).**

Corpus y sus cinco módulos (Cortex, Caliber, Coagulant, Craving, Cargo) son **genéricos**: no saben
nada de la Zona. Este addon es la capa que los convierte en un juego de S.T.A.L.K.E.R. — aquí viven
las **entidades y el contenido del universo**, no la infraestructura:

- **Anomalías** (electra, gravi, mincer, voronka, jarka…) y **artefactos**.
- **PDA**, **detectores de anomalías**, contador Geiger.
- **Defs de NPC** que alimentan a **CortexBase** (la base de IA propia de Cortex): facciones,
  mutantes, sonidos por estado, comportamiento.
- Defs de ítem (comida, medicina, munición) contra Cargo / Craving / Coagulant.
- Playermodels y registro de facciones.

Es un **consumidor** del ecosistema, nunca al revés: hard-depende de Corpus y detecta los módulos en
runtime (`Corpus.GetModule`). Nada de lo que vive aquí sube al framework — esa es la regla cardinal
de Corpus: el framework es delgado y no contiene lógica de dominio.

## Estado

**Scaffold.** Hoy contiene el registro de playermodels, el re-vestido de ítems genéricos del
ecosistema con modelos de la Zona (botiquines, venda y mochilas, vía la API de sustitución de
modelos de Cargo) y los assets de ítem que ya consumen Cargo y Craving. Las entidades (anomalías,
artefactos, PDA, detectores) están **inventariadas y analizadas, pero no escritas** — el mapeo de
assets y la autopsia del código de referencia están en `dev/stalker_rp_packs_mapa.md` (no
publicado).

## Assets — no están en este repo

Los modelos, texturas, sonidos y partículas **no se versionan** (ver [`.gitignore`](.gitignore)). Son
ports de S.T.A.L.K.E.R., propiedad de **GSC Game World**: la MIT de este repo cubre el código, no los
assets, y publicarlos sería redistribuirlos. Además git guarda binarios de pena — cada recompilación
de un `.mdl` quedaría en el historial para siempre.

**[`docs/ASSETS.md`](docs/ASSETS.md) documenta qué pack provee cada ruta y cómo reconstruir el árbol.**
Clonar este repo te da el código; los assets se montan aparte.

## Licencia

- **Código** (`lua/`, `docs/`): [MIT](LICENSE), como el resto del ecosistema.
- **Assets** (no incluidos): de **GSC Game World** y de los autores intermedios. Se usan bajo la
  tolerancia de facto de GSC al modding de su IP — de la que viven GAMMA, Anomaly y media comunidad
  de GMod. **Política: crédito completo, y retiro inmediato si un titular lo pide.**

## Créditos

- **GSC Game World** — S.T.A.L.K.E.R. (Shadow of Chernobyl / Clear Sky / Call of Pripyat): modelos,
  texturas, sonidos, y el diseño original de anomalías y artefactos.
- **Predator-cz** — modelos y entidades de artefactos.
- **ThatYellowPicturePony**, **[Pollitto] Курритто**, **Limta Roulence** — entidades de anomalía de
  referencia.
- **Subleader**, **AirBlack**, **Hobo_Gus** — detectores (Bear / Echo / Veles).
- **Neon** — compilación de los packs ZONA StalkerRP. **Cluelesshobo** — lua de registro de
  playermodels original, adaptado aquí.
- **spec45as**, **jessev92**, **kali**, **wick**, **dejtriyev**, **HGN SRP**, **TNB**, **mrpresident**,
  **flyboi**, **jerry**, **raviool**, **senscith** — autores intermedios visibles en las rutas de los
  modelos.

Si eres autor de algo de aquí y quieres crédito distinto, o su retiro, abre un issue.

## Montaje

Junction en `garrysmod/addons/corpus-stalker` → esta carpeta, mismo patrón que los seis repos del
ecosistema. Verificación: menú C → playermodels `ZONA *`; `cargo_dev_give` → los ítems dev muestran
modelo S.T.A.L.K.E.R. en la grid.
