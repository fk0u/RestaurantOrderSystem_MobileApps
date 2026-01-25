import '../../../core/services/api_client.dart';
import 'promotion_model.dart';

class PromotionRepository {
  final ApiClient _api = ApiClient();

  Future<Promotion?> getByCode(String code) async {
    final data = await _api.getList('/promotions', query: {
      'code': code,
      'active': 'true',
    });
    if (data.isEmpty) return null;
    final map = data.first as Map<String, dynamic>;
    return Promotion(
      id: map['id'].toString(),
      code: map['code'] ?? code,
      title: map['title'] ?? '-',
      type: map['type'] ?? 'fixed',
      value: (map['value'] as num?)?.toDouble() ?? 0,
      minOrder: (map['min_order'] as num?)?.toDouble() ?? 0,
      maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      isActive: map['is_active'] == true,
      startsAt: map['starts_at'] != null ? DateTime.tryParse(map['starts_at']) : null,
      endsAt: map['ends_at'] != null ? DateTime.tryParse(map['ends_at']) : null,
    );
  }
}
