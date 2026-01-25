import '../../../core/services/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationRepository {
  final ApiClient _api = ApiClient();

  Future<List<AppNotification>> getNotifications(Ref ref) async {
    final auth = ref.read(authControllerProvider).value;
    final query = <String, String>{};
    if (auth != null) {
      query['user_id'] = auth.id;
    }

    final data = await _api.getList('/notifications', query: query.isEmpty ? null : query);
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AppNotification(
        id: map['id'].toString(),
        title: map['title'] ?? '-',
        body: map['body'] ?? '-',
        isRead: map['is_read'] == true,
        createdAt: map['created_at']?.toString() ?? '',
      );
    }).toList();
  }

  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read', {});
  }
}
