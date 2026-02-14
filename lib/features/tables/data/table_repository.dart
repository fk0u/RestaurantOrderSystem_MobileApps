import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/table_entity.dart';

import '../../../../core/network/api_client.dart';

final tableRepositoryProvider = Provider((ref) => TableRepository(ApiClient()));

class TableRepository {
  final ApiClient _apiClient;

  TableRepository(this._apiClient);

  Future<List<RestaurantTable>> getTables() async {
    try {
      final response = await _apiClient.get('/tables');
      return (response as List).map((map) {
        return RestaurantTable(
          id:
              map['app_id'] as String? ??
              map['id'].toString(), // Use app_id if available, else id
          number: map['number'] as String,
          capacity: map['capacity'] as int,
          status: map['status'] as String,
          x: (map['x'] as num).toDouble(),
          y: (map['y'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load tables: $e');
    }
  }

  Future<void> updateTableStatus(String id, String status) async {
    try {
      await _apiClient.put('/tables/$id', body: {'status': status});
    } catch (e) {
      throw Exception('Failed to update table status: $e');
    }
  }
}
