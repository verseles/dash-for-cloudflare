# Dash for CF

Unofficial native dashboard for Cloudflare services. Built with Flutter for all platforms.


## Project Info

| Campo               | Valor                                    |
| ------------------- | ---------------------------------------- |
| **Package ID**      | `ad.dash.cf`                             |
| **Web URL**         | `cf.dash.ad`                             |
| **Platforms**       | Android, iOS, Web, Linux, macOS, Windows |
| **Dev Platforms**   | Android, Linux                           |
| **Repository**      | github.com/verseles/dash-for-cloudflare  |

## Tech Stack

| Category             | Package/Technology                    |
| -------------------- | ------------------------------------- |
| **Framework**        | Flutter 3.x                           |
| **State Management** | Riverpod 2.x                          |
| **HTTP Client**      | Dio + Retrofit                        |
| **Routing**          | go_router                             |
| **Data Classes**     | Freezed + JSON Serializable           |
| **Secure Storage**   | flutter_secure_storage                |
| **Simple Storage**   | shared_preferences                    |
| **Charts**           | Syncfusion Charts (Community License) |
| **Maps**             | Syncfusion Maps (Community License)   |
| **i18n**             | flutter_localizations + intl          |
| **Desktop**          | window_manager, tray_manager          |

## Features

### 🌐 DNS Management
- Zone listing and search with auto-selection
- Full CRUD for DNS Records (A, AAAA, CNAME, TXT, etc.)
- DNSSEC status and management
- Zone settings configuration

### 📊 Analytics Dashboard
- **Web Traffic:** Requests, bandwidth, visitors
- **Security:** Threats blocked, challenges issued
- **Performance:** Cache hit rates, content type distribution
- **Interactive Charts:** Powered by GraphQL and Syncfusion

### 📄 Cloudflare Pages
- Project listing and management
- **Deployments:** View history, status, and commit details
- **Live Build Logs:** Real-time polling of build progress
- **Actions:** Rollback to previous deployments, manage custom domains
- **Settings:** Environment variables and build configurations (Auto-save)

### 👷 Cloudflare Workers
- Script management and details
- **Triggers:** Route management (zone-scoped) and Cron Triggers
- **Bindings:** Visual management of KV, R2, D1, and other bindings
- **Observability:** Usage metrics and invocation stats

### ⚙️ General
- **Multi-Account:** Support for multiple Cloudflare accounts
- **Security:** API Token validation and secure storage
- **UI/UX:** Material 3 Design, Dark/Light mode, Responsive layout
- **i18n:** Full support for English and Portuguese

## Quick Start

```bash
# Install dependencies and generate code
make deps
make gen

# During development (quick feedback ~20s)
make check

# Before committing (full verification ~30s)
make precommit

# Build (choose platform)
make android     # APK (arm64) + upload via tdl
make linux       # Linux release
make web         # Web release
```

## Make Commands

| Command           | Description                                    | Time   |
| ----------------- | ---------------------------------------------- | ------ |
| `make check`      | Quick validation (deps+gen+analyze+test)       | ~20s   |
| `make precommit`  | Full verification (check+builds)               | ~30s   |
| `make android`    | Build APK (arm64) + upload via tdl             | ~30s   |
| `make android-x64`| Build APK (x64 for emulator)                   | ~30s   |
| `make linux`      | Build Linux release                            | ~10s   |
| `make web`        | Build Web release                              | ~20s   |
| `make test`       | Run tests                                      | ~10s   |
| `make analyze`    | Static analysis                                | ~3s    |
| `make deps`       | Install dependencies                           | ~2s    |
| `make gen`        | Generate code (Freezed, Retrofit)              | ~5s    |
| `make clean`      | Clean build artifacts                          | ~2s    |
| `make install`    | Install on Linux (~/.local)                    | -      |
| `make uninstall`  | Uninstall from Linux                           | -      |

## Quality Assurance

We adopt a **Test Pyramid** strategy to ensure code quality and stability:

- **Unit Tests (`test/unit/`)**: Focus on business logic, parsers, and data models. Fast execution (~10ms) with mocked dependencies.
- **Widget Tests (`test/widget/`)**: Verify UI components, user interactions, and screen states. Uses Riverpod overrides for isolated testing.
- **Integration Tests (`test/integration/`)**: Validate complete user flows (e.g., DNS Record creation, Pages Rollback) simulating the app structure with mocked network calls.

Run all tests with: `make test` or `make check`.

## CORS Strategy

| Platform    | Needs Proxy? | Base URL                                                 |
| ----------- | ------------ | -------------------------------------------------------- |
| **Web**     | Yes          | `https://cors.verseles.com/api.cloudflare.com/client/v4` |
| **Android** | No           | `https://api.cloudflare.com/client/v4`                   |
| **iOS**     | No           | `https://api.cloudflare.com/client/v4`                   |
| **Desktop** | No           | `https://api.cloudflare.com/client/v4`                   |

## Documentation

- [ADR.md](./ADR.md) - Architecture Decision Records
- [roadmap/roadmap.md](./roadmap/roadmap.md) - Project roadmap and task tracking

## References

| Topic                  | Link                                            |
| ---------------------- | ----------------------------------------------- |
| Flutter Riverpod       | riverpod.dev                                    |
| go_router              | pub.dev/packages/go_router                      |
| Freezed                | pub.dev/packages/freezed                        |
| Dio + Retrofit         | pub.dev/packages/retrofit                       |
| Syncfusion Charts      | pub.dev/packages/syncfusion_flutter_charts      |
| Syncfusion Maps        | pub.dev/packages/syncfusion_flutter_maps        |
| Flutter Secure Storage | pub.dev/packages/flutter_secure_storage         |
| Window Manager         | pub.dev/packages/window_manager                 |
| Cloudflare API         | developers.cloudflare.com/api                   |

## License

MIT
