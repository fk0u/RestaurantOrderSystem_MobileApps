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

  Future<AdminShift> createShift({
    String? userId,
    required String role,
    required DateTime startsAt,
    DateTime? endsAt,
  }) async {
    final map = await _api.post('/shifts', {
      'user_id': userId,
      'role': role,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'status': 'active',
    });

    return AdminShift(
      id: map['id'].toString(),
      userName: map['user']?['name']?.toString(),
      role: map['role']?.toString() ?? role,
      startsAt: map['starts_at']?.toString() ?? startsAt.toIso8601String(),
      endsAt: map['ends_at']?.toString(),
      status: map['status'] ?? 'active',
    );
  }

  Future<AdminPromotion> createPromotion({
    required String code,
    required String title,
    required String type,
    required double value,
    bool isActive = true,
  }) async {
    final map = await _api.post('/promotions', {
      'code': code,
      'title': title,
      'type': type,
      'value': value,
      'is_active': isActive,
    });

    return AdminPromotion(
      id: map['id'].toString(),
      code: map['code'] ?? code,
      title: map['title'] ?? title,
      type: map['type'] ?? type,
      value: (map['value'] as num?)?.toDouble() ?? value,
      isActive: map['is_active'] == true,
    );
  }

  Future<AdminPromotion> updatePromotionActive({
    required String id,
    required bool isActive,
  }) async {
    final map = await _api.put('/promotions/$id', {
      'is_active': isActive,
    });

    return AdminPromotion(
      id: map['id'].toString(),
      code: map['code'] ?? '-',
      title: map['title'] ?? '-',
      type: map['type'] ?? 'fixed',
      value: (map['value'] as num?)?.toDouble() ?? 0,
      isActive: map['is_active'] == true,
    );
  }

  Future<List<AdminDailyStock>> getDailyStocks({String? date}) async {
    final data = await _api.getList('/reports/daily-stock', query: {
      if (date != null) 'date': date,
    });
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AdminDailyStock(
        id: map['id'].toString(),
        productId: map['product_id']?.toString() ?? map['product']?['id']?.toString() ?? '',
        productName: map['product']?['name']?.toString() ?? '-',
        openingStock: (map['opening_stock'] as num?)?.toInt() ?? 0,
        closingStock: (map['closing_stock'] as num?)?.toInt() ?? 0,
        sold: (map['sold'] as num?)?.toInt() ?? 0,
        adjusted: (map['adjusted'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<AdminSalesReport> getSalesReport({DateTime? from, DateTime? to}) async {
    final query = <String, String>{};
    if (from != null) query['from'] = from.toIso8601String();
    if (to != null) query['to'] = to.toIso8601String();

    final data = await _api.getObject('/reports/sales', query: query.isEmpty ? null : query);
    final summary = data['summary'] as Map<String, dynamic>? ?? {};
    final byStatus = (data['by_status'] as List<dynamic>? ?? []).map((item) {
      final s = item as Map<String, dynamic>;
      return AdminSalesStatus(
        status: s['status']?.toString() ?? '-',
        count: (s['count'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return AdminSalesReport(
      orders: (summary['orders'] as num?)?.toInt() ?? 0,
      revenue: (summary['revenue'] as num?)?.toDouble() ?? 0,
      subtotal: (summary['subtotal'] as num?)?.toDouble() ?? 0,
      byStatus: byStatus,
    );
  }

  Future<void> adjustStock({
    required String productId,
    required int quantity,
    String? reason,
  }) async {
    await _api.post('/stock/$productId/adjust', {
      'quantity': quantity,
      'reason': reason,
    });
  }
}
