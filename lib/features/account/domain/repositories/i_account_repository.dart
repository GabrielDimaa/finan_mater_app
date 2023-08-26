import 'package:finan_master_app/features/account/domain/entities/account_entity.dart';

abstract interface class IAccountRepository {
  Future<List<AccountEntity>> findAll();

  Future<AccountEntity> save(AccountEntity entity);

  Future<void> delete(AccountEntity entity);
}
