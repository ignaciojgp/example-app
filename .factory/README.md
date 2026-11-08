# Software Factory (local)

```
/feature "<idea>" | #issue
   │
   ├─ spec            product    → spec.md            [gate: spec]
   ├─ plan            architect  → plan.md            [gate: plan]
   ├─ implementation  developer ⇄ qa → gate.sh 🟢     [gate: implementation]
   │                  (máx. N iteraciones)
   ├─ review          reviewer   → review.md          [gate: review]
   │                  CHANGES_REQUESTED → developer → qa → reviewer
   └─ pr              push + gh pr create --draft     [gate: pr]
```

## Modos de aprobación

| Preset   | spec | plan | implementation | review | pr |
|----------|------|------|----------------|--------|----|
| `strict` | 👤   | 👤   | 👤             | 👤     | 👤 |
| `audit`  | 👤   | 👤   | 🤖             | 🤖     | 🤖 |
| `auto`   | 🤖   | 🤖   | 🤖             | 🤖     | 🤖 |

- **Global**: `approval.preset` en `config.yml`.
- **Por gate**: `approval.gates.<gate>: manual|auto`.
- **Por corrida**: `/feature "..." --approval=auto`.
- **Durante una corrida**: en cualquier gate manual, la opción "Aprobar y continuar en automático" pone en auto el resto de esa corrida.

Las paradas de seguridad (límite de iteraciones, bloqueantes sin resolver, diff demasiado grande, cambios en `project.pbxproj` o en dependencias, acciones destructivas) siempre preguntan.

Ruta de confianza sugerida: primeras corridas en `strict`, luego `audit` y, cuando los PRs salgan bien sin intervención, `auto`. El PR siempre se abre como draft y el merge es humano.

## Tests y simulador

`scripts/factory/test.sh` ejecuta los tests **en serie en un solo simulador** (`-parallel-testing-enabled NO`). Con testing en paralelo, xcodebuild clona el simulador por núcleo, y en una máquina de 8 GB eso dispara la carga por encima de 150 y provoca timeouts intermitentes en los UI tests.

- ⚠️ Antes de cada corrida, `test.sh` ejecuta `xcrun simctl shutdown all`, que **apaga todos los simuladores** de la máquina.
- Para máquinas con más memoria: `PARALLEL_TESTING=YES scripts/factory/gate.sh --ui` (acepta YES/TRUE/1/ON; cualquier otro valor equivale a NO).
- El número de tests que pasaron se toma del `.xcresult` (`.build/TestResults.xcresult`). Si no está disponible, se cuenta en el log.

## Auditoría

Cada corrida queda en `.factory/runs/<run-id>/` (ignorado por git): `input.md`, `spec.md`, `plan.md`, `qa.md`, `review.md`, `log.md`, `state.json` y `pr.md`.
La tabla de `log.md` (qué gate, en qué modo y quién aprobó) también se copia en la descripción del PR.

Para retomar una corrida interrumpida: `/feature --resume <run-id>`.
