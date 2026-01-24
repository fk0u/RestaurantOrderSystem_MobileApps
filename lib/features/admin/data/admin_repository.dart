import '../../../core/services/api_client.dart';
import 'admin_models.dart';

class AdminRepository {
  final ApiClient _api = ApiClient();

  Future<List<AdminReservation>> getReservations() async {
    final data = await _api.getList('/reservations');
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminReservation(
        id: map['id'].toString(),
        tableNumber: map['table']?['number']?.toString() ?? map['table_number']?.toString(),
        partySize: (map['party_size'] as num?)?.toInt() ?? 0,
        reservedAt: map['reserved_at']?.toString() ?? '',
        status: map['status'] ?? 'reserved',
      );
    }).toList();
  }

  Future<List<AdminShift>> getShifts() async {
    final data = await _api.getList('/shifts');
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminShift(
        id: map['id'].toString(),
        userName: map['user']?['name']?.toString(),
        role: map['role']?.toString() ?? '-',
        startsAt: map['starts_at']?.toString() ?? '',
        endsAt: map['ends_at']?.toString(),
        status: map['status'] ?? 'active',
      );
    }).toList();
  }

  Future<List<AdminPromotion>> getPromotions() async {
    final data = await _api.getList('/promotions');
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminPromotion(
        id: map['id'].toString(),
        code: map['code'] ?? '-',
        title: map['title'] ?? '-',
        type: map['type'] ?? 'fixed',
        value: (map['value'] as num?)?.toDouble() ?? 0,
        isActive: map['is_active'] == true,
      );
    }).toList();
  }

  Future<List<AdminDailyStock>> getDailyStocks({String? date}) async {
    final data = await _api.getList('/reports/daily-stock', query: {
      if (date != null) 'date': date,
    });
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminDailyStock(
        id: map['id'].toString(),
        productName: map['product']?['name']?.toString() ?? '-',
        openingStock: (map['opening_stock'] as num?)?.toInt() ?? 0,
        closingStock: (map['closing_stock'] as num?)?.toInt() ?? 0,
        sold: (map['sold'] as num?)?.toInt() ?? 0,
        adjusted: (map['adjusted'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }
}
