import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> showOrderReadyNotification({
    required String orderId,
    required int queueNumber,
    required String orderType,
    String? tableNumber,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status',
      'Order Status',
      channelDescription: 'Notifikasi status pesanan',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    final typeLabel = orderType == 'dine_in' ? 'Dine In' : 'Takeaway';
    final tableInfo = orderType == 'dine_in' && tableNumber != null
        ? ' • Meja $tableNumber'
        : '';

    final body = 'Antrian #$queueNumber • $typeLabel$tableInfo';

    await _notifications.show(
      orderId.hashCode,
      'Pesanan siap diambil',
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
