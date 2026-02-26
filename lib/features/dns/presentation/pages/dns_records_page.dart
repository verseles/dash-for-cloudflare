import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dns_records_provider.dart';
import '../../providers/zone_provider.dart';
import '../widgets/dns_record_item.dart';
import '../widgets/dns_record_edit_dialog.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_view.dart';

/// DNS Records page with list and filters
class DnsRecordsPage extends ConsumerStatefulWidget {
  const DnsRecordsPage({super.key});

  @override
  ConsumerState<DnsRecordsPage> createState() => _DnsRecordsPageState();
}

class _DnsRecordsPageState extends ConsumerState<DnsRecordsPage> {
  bool _isSearchExpanded = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedZone = ref.watch(selectedZoneNotifierProvider);
    final recordsAsync = ref.watch(dnsRecordsNotifierProvider);

    if (selectedZone == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.domain, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(l10n.dns_selectZoneFirst),
          ],
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: recordsAsync.when(
        loading: () => _buildSkeletonList(),
        error: (error, _) => CloudflareErrorView(
          key: const ValueKey('error'),
          error: error,
          onRetry: () => ref.read(dnsRecordsNotifierProvider.notifier).refresh(),
        ),
        data: (state) => _buildContent(context, state, l10n),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    DnsRecordsState state,
    AppLocalizations l10n,
  ) {
    final filteredRecords = state.filteredRecords;

    return Scaffold(
      key: const ValueKey('data'),
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(context, state, l10n),

          // Record list
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: filteredRecords.isEmpty
                ? _buildEmptyState(state, l10n)
                : RefreshIndicator(
                    key: const ValueKey('list'),
                    onRefresh: () =>
                        ref.read(dnsRecordsNotifierProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = filteredRecords[index];
                        return DnsRecordItem(
                          record: record,
                          isSaving: state.savingIds.contains(record.id),
                          isNew: state.newIds.contains(record.id),
                          isDeleting: state.deletingIds.contains(record.id),
                          onTap: () => _showEditDialog(record),
                          onDelete: () => _deleteRecord(record.id),
                          onProxyToggle: (value) =>
                              _toggleProxy(record.id, value),
                        )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideY(
                              begin: 0.1,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
                              delay: (50 * index.clamp(0, 10)).ms,
                            );
                      },
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        tooltip: l10n.dns_addRecord,
        child: const Icon(Symbols.add),
      )
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 400.ms,
            delay: 200.ms,
            curve: Curves.elasticOut,
          ),
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    DnsRecordsState state,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter chips
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l10n.common_all),
                    selected: state.activeFilter == 'All',
                    onSelected: (_) => ref
                        .read(dnsRecordsNotifierProvider.notifier)
                        .setFilter('All'),
                  ),
                  const SizedBox(width: 8),
                  ...recordTypes.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: state.activeFilter == type,
                        selectedColor: getRecordTypeColor(
                          type,
                        ).withValues(alpha: 0.2),
                        onSelected: (_) => ref
                            .read(dnsRecordsNotifierProvider.notifier)
                            .setFilter(type),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search toggle
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            width: _isSearchExpanded ? 200 : 40,
            child: _isSearchExpanded
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.dns_searchRecords,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Symbols.close, size: 18),
                        onPressed: () {
                          setState(() => _isSearchExpanded = false);
                          _searchController.clear();
                          ref
                              .read(dnsRecordsNotifierProvider.notifier)
                              .setSearchQuery('');
                        },
                      ),
                    ),
                    onChanged: (value) {
                      ref
                          .read(dnsRecordsNotifierProvider.notifier)
                          .setSearchQuery(value);
                    },
                  )
                : IconButton(
                    icon: const Icon(Symbols.search),
                    onPressed: () => setState(() => _isSearchExpanded = true),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(DnsRecordsState state, AppLocalizations l10n) {
    final hasFilters =
        state.activeFilter != 'All' || state.searchQuery.isNotEmpty;

    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Symbols.filter_alt_off : Symbols.graph_3,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? l10n.dns_noRecordsMatch : l10n.dns_noRecords,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                ref.read(dnsRecordsNotifierProvider.notifier).resetFilters();
                _searchController.clear();
                setState(() => _isSearchExpanded = false);
              },
              child: Text(l10n.common_clearFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    final skeletonColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final skeletonColorLight = Theme.of(context).colorScheme.surfaceContainerHigh;

    return ListView.builder(
      key: const ValueKey('loading'),
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 24,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: skeletonColorLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(dynamic record) {
    showDialog(
      context: context,
      builder: (context) => DnsRecordEditDialog(record: record),
    );
  }

  Future<void> _deleteRecord(String recordId) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(dnsRecordsNotifierProvider.notifier)
          .deleteRecord(recordId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.dns_recordDeleted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error_prefix(e.toString()))),
        );
      }
    }
  }

  Future<void> _toggleProxy(String recordId, bool value) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(dnsRecordsNotifierProvider.notifier)
          .updateProxy(recordId, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.error_prefix(e.toString()))),
        );
      }
    }
  }
}
