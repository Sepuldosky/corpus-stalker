
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
