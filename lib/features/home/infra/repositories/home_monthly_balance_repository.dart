import 'package:finan_master_app/features/home/domain/entities/home_monthly_balance_entity.dart';
import 'package:finan_master_app/features/home/domain/repositories/i_home_monthly_balance_repository.dart';
import 'package:finan_master_app/features/transactions/infra/data_sources/i_transaction_local_data_source.dart';

class HomeMonthlyBalanceRepository implements IHomeMonthlyBalanceRepository {
  final ITransactionLocalDataSource _dataSource;

  HomeMonthlyBalanceRepository({required ITransactionLocalDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<List<HomeMonthlyBalanceEntity>> findMonthlyBalances({required DateTime startDate, required DateTime endDate}) async {
    final List<Map<String, dynamic>> results = await _dataSource.findMonthlyBalances(startDate: startDate, endDate: endDate);

    return results
        .map((result) => HomeMonthlyBalanceEntity(
      date: DateTime.tryParse(result['month'].toString())!.toLocal(),
      balance: result['monthly_sum'],
    ))
        .toList();
  }
}
