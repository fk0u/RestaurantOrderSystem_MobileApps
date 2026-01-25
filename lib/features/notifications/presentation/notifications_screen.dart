import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/design_system.dart';
import '../presentation/notifications_controller.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(notificationsProvider),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada notifikasi'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.s21),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: item.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimens.r16),
                  boxShadow: AppShadows.card,
                ),
                child: ListTile(
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.body),
                  trailing: IconButton(
                    icon: Icon(item.isRead ? Icons.check : Icons.mark_email_read),
                    onPressed: item.isRead
                        ? null
                        : () async {
                            await NotificationRepository().markRead(item.id);
                            ref.invalidate(notificationsProvider);
                          },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
