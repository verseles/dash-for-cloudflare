import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/models/cloudflare_resources.dart';
import 'api_providers.dart';
import '../../../features/auth/providers/account_provider.dart';

part 'resource_providers.g.dart';

@riverpod
Future<List<KVNamespace>> kvNamespaces(KvNamespacesRef ref) async {
  final accountId = ref.watch(selectedAccountIdProvider);
  if (accountId == null) return [];

  final api = ref.read(cloudflareApiProvider);
  final response = await api.getKVNamespaces(accountId);
  
  if (!response.success) {
    throw Exception(response.errors.firstOrNull?.message ?? 'Failed to fetch KV namespaces');
  }
  
  return response.result ?? [];
}

@riverpod
Future<List<R2Bucket>> r2Buckets(R2BucketsRef ref) async {
  final accountId = ref.watch(selectedAccountIdProvider);
  if (accountId == null) return [];

  final api = ref.read(cloudflareApiProvider);
  final response = await api.getR2Buckets(accountId);
  
  if (!response.success) {
    throw Exception(response.errors.firstOrNull?.message ?? 'Failed to fetch R2 buckets');
  }
  
  return response.result ?? [];
}

@riverpod
Future<List<D1Database>> d1Databases(D1DatabasesRef ref) async {
  final accountId = ref.watch(selectedAccountIdProvider);
  if (accountId == null) return [];

  final api = ref.read(cloudflareApiProvider);
  final response = await api.getD1Databases(accountId);
  
  if (!response.success) {
    throw Exception(response.errors.firstOrNull?.message ?? 'Failed to fetch D1 databases');
  }
  
  return response.result ?? [];
}
