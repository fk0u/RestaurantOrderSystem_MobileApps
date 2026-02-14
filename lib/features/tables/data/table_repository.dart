import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/table_entity.dart';
import '../../../core/services/mock_service.dart';
// import '../../../core/services/api_client.dart';

final tableRepositoryProvider = Provider((ref) => TableRepository());

class TableRepository {
  // final ApiClient _api = ApiClient();
  final MockService _mockService = MockService(); // Should ideally be injected

  Future<List<RestaurantTable>> getTables() async {
    // final data = await _api.getList('/tables');
    return _mockService.getTables();
  }

  Future<void> updateTableStatus(String id, String status) async {
    // await _api.patch('/tables/$id/status', {'status': status});
    await _mockService.updateTableStatus(id, status);
  }
}
