# Dash for Cloudflare

Unofficial Cloudflare management app built with Flutter.

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

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, Retrofit)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Build
flutter build apk --release
flutter build linux --release
flutter build web --release

# Pre-commit check (recommended)
./precommit.sh
```

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
