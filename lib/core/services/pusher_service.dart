import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/app_config.dart';
import 'notification_service.dart';

class PusherService {
  static final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await _pusher.init(
      apiKey: AppConfig.pusherKey,
      cluster: AppConfig.pusherCluster,
      onEvent: (event) {
        if (event.channelName == 'orders' && event.eventName == 'order.ready') {
          try {
            final data = jsonDecode(event.data ?? '{}') as Map<String, dynamic>;
            NotificationService.showOrderReadyNotification(
              orderId: data['order_id']?.toString() ?? 'ORDER',
              queueNumber: (data['queue_number'] as num?)?.toInt() ?? 0,
              orderType: data['order_type'] ?? 'takeaway',
              tableNumber: data['table_number']?.toString(),
            );
          } catch (_) {}
        }
      },
    );

    await _pusher.subscribe(channelName: 'orders');
    await _pusher.connect();

    _initialized = true;
  }
}
