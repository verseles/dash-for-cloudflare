import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';
part 'account.g.dart';

/// Cloudflare Account model.
/// Used for account-level resources like Pages and Workers.
@freezed
sealed class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    Map<String, dynamic>? settings,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}
