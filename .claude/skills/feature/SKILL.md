---
name: feature
description: Orquestador de la Software Factory iOS. Lleva una idea o un issue de GitHub hasta un PR revisado pasando por spec → plan → implementación → QA → review → PR, con gates de aprobación configurables (manual/auto). Úsalo cuando el usuario invoque /feature o pida "fabricar" una funcionalidad.
argument-hint: "<descripción | #issue> [--approval=strict|audit|auto] [--resume <run-id>]"
---

# /feature: Software Factory

Eres el **orquestador**. No escribes specs, planes ni código: delegas cada etapa en su subagente (`product`, `architect`, `developer`, `qa`, `reviewer`), aplicas los gates y llevas el registro. Sé breve en el chat: una línea por etapa.

## 0. Preparación

1. **Argumentos** (`$ARGUMENTS`):
   - `#123` o una URL de issue → `gh issue view 123 --json title,body,labels` es la entrada.
   - `--approval=<preset>` sobrescribe la configuración de esta corrida.
   - `--resume <run-id>` → lee `.factory/runs/<run-id>/state.json` y continúa desde `stage`.
2. **Configuración**: lee `.factory/config.yml`. Calcula los gates efectivos (`spec`, `plan`, `implementation`, `review`, `pr`):
   - `strict` → todos `manual`; `audit` → `spec` y `plan` manual, el resto `auto`; `auto` → todos `auto`.
   - Precedencia: `--approval` > `approval.gates.*` > `approval.preset`.
3. **Pre-chequeos** (si alguno falla, detente y explica cómo resolverlo):
   - `git status --porcelain` sin cambios en archivos versionados.
   - `gh auth status` correcto (solo bloquea si el gate `pr` va a ejecutarse; avisa al inicio igualmente).
   - `git fetch <remote> && git switch <base_branch> && git pull --ff-only`.
4. **Corrida**: `RUN_ID=$(date +%Y%m%d-%H%M)-<slug-kebab-de-3-4-palabras>`, `RUN_DIR=.factory/runs/$RUN_ID`. Crea:
   - la rama `<branch_prefix><slug>`;
   - `$RUN_DIR/input.md` con la entrada original;
   - `$RUN_DIR/state.json`: `{"run_id","branch","stage","gates":{...},"iterations":0,"started_at"}`;
   - `$RUN_DIR/log.md`: tabla de auditoría `| hora | etapa | modo | decisión | nota |`.
   Actualiza `state.json` al terminar cada etapa.

## Protocolo de gate

Al terminar una etapa con gate `<g>`:

- **auto** → registra en `log.md` (`auto`, `aprobado`) y continúa. Una línea en el chat: `✓ <g> (auto)`.
- **manual** → muestra un resumen del artefacto (máximo 15 líneas, con la ruta del archivo completo) y pregunta con `AskUserQuestion`:
  - **Aprobar**
  - **Aprobar y continuar en automático** (solo si `allow_switch_to_auto`; pone en `auto` todos los gates restantes de esta corrida y lo guarda en `state.json`)
  - **Pedir cambios** → la respuesta libre del usuario vuelve al mismo subagente como feedback y el gate se repite
  - **Abortar** → registra, deja la rama tal cual y termina con instrucciones de `--resume`
  Registra la decisión y el texto del usuario en `log.md`.

## Paradas de seguridad (siempre manuales, incluso en auto)

Detente y pregunta si:
- se alcanzan `limits.max_fix_iterations` ciclos de corrección;
- el reviewer mantiene bloqueantes tras el último ciclo (`stop_on_unresolved_blockers`);
- el diff supera `limits.max_files_changed` archivos;
- un subagente cambió `project.pbxproj`, añadió dependencias, desactivó tests o tocó archivos fuera del alcance del plan;
- algún paso necesita una acción destructiva (force-push, borrar ramas, reset).

## Etapas

1. **spec** → subagente `product` con la entrada y `RUN_DIR`. Gate `spec`.
2. **plan** → subagente `architect` con `RUN_DIR`. Gate `plan`.
3. **implementation**
   a. Subagente `developer` con `RUN_DIR`.
   b. Subagente `qa` con `RUN_DIR`.
   c. Si `qa.md` dice FAIL → `iterations++` y vuelve a (a) pasando `qa.md` como informe de fallos.
   d. **Verificación del orquestador**: ejecuta tú mismo `scripts/factory/gate.sh` (con `--ui` si aplica). No confíes solo en lo que reportan los subagentes. Si falla, vuelve a (a).
   e. Commit local: `git add -A && git commit -m "feat(<slug>): <título de la spec>"`. Gate `implementation` (resumen: archivos cambiados con `git diff --stat <base>...HEAD`, tabla de QA).
4. **review** → subagente `reviewer` con `RUN_DIR` y la rama base.
   - `CHANGES_REQUESTED` → `iterations++`, `developer` con `review.md`, luego `qa` y `gate.sh`, commit `fix(<slug>): resolver review`, y de nuevo `reviewer`.
   - `APPROVE` → gate `review` (resumen: veredicto y no bloqueantes).
5. **pr**
   - Gate `pr` antes de publicar: es una acción externa.
   - `git push -u <remote> <branch>`.
   - `gh pr create --base <base_branch> [--draft] --title "<título>" --body-file $RUN_DIR/pr.md`, donde `pr.md` contiene:
     - el **Resumen** (de `review.md`);
     - la **Historia y criterios** (de `spec.md`, con los checkboxes marcados según QA);
     - la tabla de **Tests** (de `qa.md`);
     - los **No bloqueantes pendientes**;
     - la tabla de **Auditoría de la fábrica** (copia de `log.md`, con el preset efectivo e iteraciones);
     - al final: `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
   - Los commits terminan con la línea `Co-Authored-By` indicada por el entorno.

## Cierre

Termina con: enlace del PR, número de iteraciones, gates manuales frente a automáticos y la ruta `RUN_DIR`. El merge siempre lo hace un humano.
