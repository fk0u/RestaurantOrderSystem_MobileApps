import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/table_entity.dart';
import '../../../core/services/api_client.dart';

final tableRepositoryProvider = Provider((ref) => TableRepository());

class TableRepository {
  final ApiClient _api = ApiClient();

  Future<List<RestaurantTable>> getTables() async {
    final data = await _api.getList('/tables');
    return data.map((json) {
      final map = json as Map<String, dynamic>;
      return RestaurantTable(
        id: map['id'].toString(),
        number: map['number'] ?? '',
        capacity: (map['capacity'] as num?)?.toInt() ?? 0,
        status: map['status'] ?? 'available',
        x: (map['x'] as num?)?.toDouble() ?? 0,
        y: (map['y'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  Future<void> updateTableStatus(String id, String status) async {
    await _api.patch('/tables/$id/status', {'status': status});
  }
}
