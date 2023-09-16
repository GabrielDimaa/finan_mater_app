import 'package:finan_master_app/features/transactions/domain/entities/i_financial_operation.dart';
import 'package:finan_master_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:finan_master_app/features/transactions/domain/enums/transaction_type_enum.dart';
import 'package:finan_master_app/features/transactions/helpers/factories/transaction_factory.dart';
import 'package:finan_master_app/shared/domain/entities/entity.dart';

class TransferEntity extends Entity implements IFinancialOperation {
  late TransactionEntity _transactionFrom;
  late TransactionEntity _transactionTo;

  TransactionEntity get transactionFrom => _transactionFrom;

  TransactionEntity get transactionTo => _transactionTo;

  DateTime get date => _transactionFrom.date;

  set transactionFrom(TransactionEntity value) => _transactionFrom = value..type = TransactionTypeEnum.transfer;

  set transactionTo(TransactionEntity value) => _transactionTo = value..type = TransactionTypeEnum.transfer;

  set amount(double value) {
    _transactionFrom.amount = value * -1;
    _transactionTo.amount = value;
  }

  set date(DateTime value) {
    _transactionFrom.date = value;
    _transactionTo.date = value;
  }

  TransferEntity({
    required super.id,
    required super.createdAt,
    required super.deletedAt,
    required TransactionEntity? transactionFrom,
    required TransactionEntity? transactionTo,
  }) {
    _transactionFrom = transactionFrom ?? TransactionFactory.newEntity(TransactionTypeEnum.transfer);
    _transactionTo = transactionTo ?? TransactionFactory.newEntity(TransactionTypeEnum.transfer);
  }
}
