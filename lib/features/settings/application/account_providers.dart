import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/database_provider.dart';
import '../data/account_repository.dart';

part 'account_providers.g.dart';

@riverpod
AccountRepository accountRepository(Ref ref) => AccountRepository(
  ref.watch(databaseProvider),
  ref.watch(authServiceProvider),
);
