# Feature 13: Cloudflare Workers Management - Research

## Overview

Gerenciamento de Workers/Scripts com listagem, detalhes, routes, cron triggers e bindings.

## API Endpoints (REST v4)

Base URL: `https://api.cloudflare.com/client/v4`

### Scripts (Account-scoped)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/workers/scripts` | GET | List all Workers scripts |
| `/accounts/{account_id}/workers/scripts/{script_name}` | GET | Download script content |
| `/accounts/{account_id}/workers/scripts/{script_name}` | DELETE | Delete a script |
| `/accounts/{account_id}/workers/scripts/{script_name}/settings` | GET | Get script settings/bindings |
| `/accounts/{account_id}/workers/scripts/{script_name}/settings` | PATCH | Update script settings |

### Routes (Zone-scoped)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/zones/{zone_id}/workers/routes` | GET | List routes for a zone |
| `/zones/{zone_id}/workers/routes` | POST | Create a route |
| `/zones/{zone_id}/workers/routes/{route_id}` | PUT | Update a route |
| `/zones/{zone_id}/workers/routes/{route_id}` | DELETE | Delete a route |

### Cron Triggers

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/workers/scripts/{script_name}/schedules` | GET | List cron schedules |
| `/accounts/{account_id}/workers/scripts/{script_name}/schedules` | PUT | Update cron schedules |

### KV Storage

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/storage/kv/namespaces` | GET | List KV namespaces |
| `/accounts/{account_id}/storage/kv/namespaces/{namespace_id}` | GET | Get namespace details |

### Other Resources (Read-only for display)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/workers/durable_objects/namespaces` | GET | List Durable Objects |
| `/accounts/{account_id}/d1/database` | GET | List D1 databases |
| `/accounts/{account_id}/r2/buckets` | GET | List R2 buckets |

## API Response Examples

### List Scripts Response
```json
{
  "result": [
    {
      "id": "my-worker",
      "etag": "abc123",
      "handlers": ["fetch", "scheduled"],
      "created_on": "2024-01-01T00:00:00Z",
      "modified_on": "2024-06-15T10:30:00Z",
      "usage_model": "bundled",
      "last_deployed_from": "wrangler"
    }
  ],
  "success": true
}
```

### Script Settings Response
```json
{
  "result": {
    "bindings": [
      { "type": "kv_namespace", "name": "MY_KV", "namespace_id": "abc123" },
      { "type": "r2_bucket", "name": "MY_BUCKET", "bucket_name": "my-bucket" },
      { "type": "d1", "name": "MY_DB", "id": "db-uuid" },
      { "type": "durable_object_namespace", "name": "MY_DO", "class_name": "MyClass" },
      { "type": "plain_text", "name": "API_URL", "text": "https://api.example.com" },
      { "type": "secret_text", "name": "API_KEY" }
    ],
    "compatibility_date": "2024-01-01",
    "compatibility_flags": ["nodejs_compat"],
    "usage_model": "bundled"
  }
}
```

### Routes Response
```json
{
  "result": [
    {
      "id": "route-uuid",
      "pattern": "example.com/*",
      "script": "my-worker",
      "request_limit_fail_open": false
    }
  ],
  "success": true
}
```

### Schedules (Cron) Response
```json
{
  "result": {
    "schedules": [
      { "cron": "*/5 * * * *", "created_on": "2024-01-01T00:00:00Z" },
      { "cron": "0 0 * * *", "created_on": "2024-01-01T00:00:00Z" }
    ]
  }
}
```

## Data Models (Freezed)

### Worker
```dart
@freezed
class Worker with _$Worker {
  const factory Worker({
    required String id,
    String? etag,
    @Default([]) List<String> handlers,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'modified_on') required DateTime modifiedOn,
    @JsonKey(name: 'usage_model') @Default('bundled') String usageModel,
    @JsonKey(name: 'last_deployed_from') String? lastDeployedFrom,
  }) = _Worker;
}
```

### WorkerSettings
```dart
@freezed
class WorkerSettings with _$WorkerSettings {
  const factory WorkerSettings({
    @Default([]) List<WorkerBinding> bindings,
    @JsonKey(name: 'compatibility_date') String? compatibilityDate,
    @JsonKey(name: 'compatibility_flags') @Default([]) List<String> compatibilityFlags,
    @JsonKey(name: 'usage_model') @Default('bundled') String usageModel,
  }) = _WorkerSettings;
}
```

### WorkerBinding
```dart
@freezed
class WorkerBinding with _$WorkerBinding {
  const factory WorkerBinding({
    required String type,
    required String name,
    // KV
    @JsonKey(name: 'namespace_id') String? namespaceId,
    // R2
    @JsonKey(name: 'bucket_name') String? bucketName,
    // D1
    String? id,
    // Durable Objects
    @JsonKey(name: 'class_name') String? className,
    // Plain text
    String? text,
  }) = _WorkerBinding;
}
```

### WorkerRoute
```dart
@freezed
class WorkerRoute with _$WorkerRoute {
  const factory WorkerRoute({
    required String id,
    required String pattern,
    required String script,
    @JsonKey(name: 'request_limit_fail_open') @Default(false) bool requestLimitFailOpen,
  }) = _WorkerRoute;
}
```

### WorkerSchedule
```dart
@freezed
class WorkerSchedule with _$WorkerSchedule {
  const factory WorkerSchedule({
    required String cron,
    @JsonKey(name: 'created_on') DateTime? createdOn,
  }) = _WorkerSchedule;
}
```

## Binding Types Reference

| Type | Properties | Description |
|------|------------|-------------|
| `kv_namespace` | `namespace_id` | KV Storage binding |
| `r2_bucket` | `bucket_name` | R2 Object Storage |
| `d1` | `id` | D1 SQL Database |
| `durable_object_namespace` | `class_name` | Durable Objects |
| `service` | `service`, `environment` | Service binding (Worker-to-Worker) |
| `plain_text` | `text` | Environment variable (visible) |
| `secret_text` | (none) | Environment variable (hidden) |
| `queue` | `queue_name` | Cloudflare Queue |
| `hyperdrive` | `id` | Hyperdrive connection |

## Required Permissions

API Token must have:
- **Workers Scripts:Read** - List and view workers
- **Workers KV Storage:Read** - View KV namespaces
- **Workers Routes:Read** - View routes (zone-scoped)
- **Account Settings:Read** - Fetch account info

## Dashboard UI Patterns

### Workers List View
- Unified list with Workers and Pages (we separate them)
- Card shows: name, last modified, handlers (fetch/scheduled icons)
- Quick indicator if it has routes or cron triggers

### Worker Detail View
- **Tabs:** Overview, Triggers, Settings
- **Overview:** Usage metrics, last deployment info
- **Triggers tab:**
  - Routes section with pattern and zone
  - Cron schedules with human-readable format
- **Settings tab:**
  - Bindings list (grouped by type)
  - Variables list (plain_text visible, secret_text masked)

### Mobile Improvements
- Grouped bindings by type with icons (KV, R2, D1, etc.)
- Human-readable cron descriptions ("Every 5 minutes")
- Swipe to disable/enable (future feature)
- Real-time logs via push notifications (future)

## Cron Expression Display

Use a simple parser to display human-readable format:
- `*/5 * * * *` → "Every 5 minutes"
- `0 * * * *` → "Every hour"
- `0 0 * * *` → "Daily at midnight"
- `0 0 * * 1` → "Every Monday at midnight"

## Sources
- https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/list/
- https://developers.cloudflare.com/workers/configuration/routing/routes/
- https://developers.cloudflare.com/workers/configuration/cron-triggers/
- https://developers.cloudflare.com/workers/runtime-apis/bindings/
