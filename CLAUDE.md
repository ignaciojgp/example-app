# example-app

App iOS en SwiftUI (iOS 26.5+, Xcode 26). Bundle: `mx.com.geekmx.example-app`.

## Estructura
- `example-app/`: código de la app. El proyecto usa **carpetas sincronizadas** (objectVersion 77): los archivos nuevos se incluyen solos. **No edites `project.pbxproj`.**
- `example-appTests/`: unit tests con **Swift Testing** (`import Testing`, `@Test`, `#expect`).
- `example-appUITests/`: UI tests con XCTest.

## Comandos
- `scripts/factory/gate.sh [--ui]`: lint, build y tests. Es la puerta de calidad: debe estar en verde antes de cualquier commit.
- `scripts/factory/build.sh`, `test.sh [--ui]`, `lint.sh`: etapas sueltas. Los logs quedan en `.build/logs/`.
- Simulador: `DESTINATION="platform=iOS Simulator,name=iPhone 17"` (sobrescribible por variable de entorno).

## Convenciones
- SwiftUI y `@Observable` para el estado; la lógica va en modelos o view models testeables, no en las vistas.
- Concurrencia estricta: la UI en `@MainActor`, async/await y nada de callbacks nuevos.
- Sin dependencias de terceros salvo que se justifiquen en el plan.
- Añade `accessibilityIdentifier` a los elementos que usen los UI tests.
- Commits: Conventional Commits (`feat:`, `fix:`, `test:`, `chore:`).

## Software Factory
`/feature <idea | #issue> [--approval=strict|audit|auto]`: flujo automatizado hasta un PR draft revisado.
La configuración de aprobaciones está en `.factory/config.yml` y la documentación en `.factory/README.md`.
