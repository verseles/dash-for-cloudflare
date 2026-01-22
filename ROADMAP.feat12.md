# Feature 12: Cloudflare Pages Management - Research

## Overview

Gerenciamento de projetos Cloudflare Pages com listagem, detalhes de deployments, e ações de rollback.

## API Endpoints (REST v4)

Base URL: `https://api.cloudflare.com/client/v4`

### Projects

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/pages/projects` | GET | List all Pages projects |
| `/accounts/{account_id}/pages/projects/{project_name}` | GET | Get project details |
| `/accounts/{account_id}/pages/projects/{project_name}` | DELETE | Delete a project |

### Deployments

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/accounts/{account_id}/pages/projects/{project_name}/deployments` | GET | List all deployments |
| `/accounts/{account_id}/pages/projects/{project_name}/deployments/{deployment_id}` | GET | Get deployment details |
| `/accounts/{account_id}/pages/projects/{project_name}/deployments/{deployment_id}/rollback` | POST | Rollback to deployment |

## API Response Examples

### List Projects Response
```json
{
  "result": [
    {
      "id": "project-uuid",
      "name": "my-site",
      "subdomain": "my-site.pages.dev",
      "domains": ["my-site.pages.dev", "custom.example.com"],
      "created_on": "2024-01-01T00:00:00Z",
      "canonical_deployment": { ... },
      "latest_deployment": { ... }
    }
  ],
  "success": true
}
```

### Project Details Response
```json
{
  "result": {
    "id": "project-uuid",
    "name": "my-site",
    "subdomain": "my-site.pages.dev",
    "domains": ["my-site.pages.dev"],
    "created_on": "2024-01-01T00:00:00Z",
    "build_config": {
      "build_command": "npm run build",
      "destination_dir": "dist",
      "root_dir": "/",
      "web_analytics_tag": null,
      "web_analytics_token": null
    },
    "deployment_configs": {
      "production": {
        "env_vars": { "API_URL": { "value": "https://api.example.com" } }
      },
      "preview": {
        "env_vars": {}
      }
    },
    "latest_deployment": { ... },
    "canonical_deployment": { ... }
  }
}
```

### Deployment Response
```json
{
  "result": {
    "id": "deployment-uuid",
    "url": "https://abc123.my-site.pages.dev",
    "environment": "production",
    "deployment_trigger": {
      "type": "ad_hoc",
      "metadata": {
        "branch": "main",
        "commit_hash": "abc123def456",
        "commit_message": "Update homepage"
      }
    },
    "stages": [
      { "name": "queued", "status": "success", "started_on": "...", "ended_on": "..." },
      { "name": "initialize", "status": "success", ... },
      { "name": "clone_repo", "status": "success", ... },
      { "name": "build", "status": "success", ... },
      { "name": "deploy", "status": "active", ... }
    ],
    "build_config": { ... },
    "created_on": "2024-01-15T10:30:00Z"
  }
}
```

## Data Models (Freezed)

### PagesProject
```dart
@freezed
class PagesProject with _$PagesProject {
  const factory PagesProject({
    required String id,
    required String name,
    required String subdomain,
    @Default([]) List<String> domains,
    @JsonKey(name: 'created_on') required DateTime createdOn,
    @JsonKey(name: 'build_config') BuildConfig? buildConfig,
    @JsonKey(name: 'latest_deployment') PagesDeployment? latestDeployment,
    @JsonKey(name: 'canonical_deployment') PagesDeployment? canonicalDeployment,
  }) = _PagesProject;
}
```

### PagesDeployment
```dart
@freezed
class PagesDeployment with _$PagesDeployment {
  const factory PagesDeployment({
    required String id,
    required String url,
    required String environment,
    @JsonKey(name: 'deployment_trigger') DeploymentTrigger? deploymentTrigger,
    @Default([]) List<DeploymentStage> stages,
    @JsonKey(name: 'created_on') required DateTime createdOn,
  }) = _PagesDeployment;
}
```

### DeploymentStage
```dart
@freezed
class DeploymentStage with _$DeploymentStage {
  const factory DeploymentStage({
    required String name,
    required String status, // queued, active, success, failure, skipped
    @JsonKey(name: 'started_on') DateTime? startedOn,
    @JsonKey(name: 'ended_on') DateTime? endedOn,
  }) = _DeploymentStage;
}
```

### BuildConfig
```dart
@freezed
class BuildConfig with _$BuildConfig {
  const factory BuildConfig({
    @JsonKey(name: 'build_command') String? buildCommand,
    @JsonKey(name: 'destination_dir') String? destinationDir,
    @JsonKey(name: 'root_dir') String? rootDir,
  }) = _BuildConfig;
}
```

## Required Permissions

API Token must have:
- **Cloudflare Pages:Read** - For listing and viewing projects/deployments
- **Cloudflare Pages:Edit** - For rollback actions

## Dashboard UI Patterns

### Project List View
- Card-based layout with project name and icon
- Status indicator (Active, Building, Failed)
- Production URL prominently displayed
- Last deployment timestamp

### Project Detail View
- **Tabs:** Deployments, Custom Domains, Settings
- **Deployments tab:** 
  - Top cards for Production and Latest Preview
  - Chronological list with status, commit, timestamp
- **Domains tab:** Table with SSL status

### Deployment View
- Header with status and deployment URL
- Build logs in monospace console (grouped by phase)
- Metadata cards (branch, commit, environment)

### Mobile Improvements
- Simplified log view with expand option
- Push notifications for build status
- Swipe actions for quick rollback
- Pull-to-refresh on all lists

## Sources
- https://developers.cloudflare.com/pages/configuration/api
- https://developers.cloudflare.com/pages/configuration/rollbacks
- https://developers.cloudflare.com/api/resources/pages/subresources/projects/methods/list/
