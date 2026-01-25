import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_repository.dart';
import '../data/notification_model.dart';

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return NotificationRepository().getNotifications(ref);
});
