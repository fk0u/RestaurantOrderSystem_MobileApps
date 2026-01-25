import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/design_system.dart';
import 'auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.s21),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.s21),
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                         Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.float,
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/300'),
                              fit: BoxFit.cover,
                            ),
                          ),
                         ),
                         Positioned(
                           bottom: 0, right: 0,
                           child: Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: AppColors.primary,
                               shape: BoxShape.circle,
                               border: Border.all(color: Colors.white, width: 2),
                             ),
                             child: const Icon(Icons.edit, color: Colors.white, size: 16),
                           ),
                         )
                      ],
                    ),
                    const SizedBox(height: AppDimens.s13),
                    Text(user?.name ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(
                      user?.role ?? 'customer',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.s34),

              _buildMenuTile(Icons.person_outline, 'Edit Profil', () {}),
              _buildMenuTile(Icons.wallet, 'Metode Pembayaran', () {}),
              _buildMenuTile(Icons.location_on_outlined, 'Alamat Tersimpan', () {}),
              _buildMenuTile(
                Icons.notifications_outlined,
                'Notifikasi',
                () => context.push('/notifications'),
                hasBadge: true,
              ),
              _buildMenuTile(Icons.help_outline, 'Bantuan & Dukungan', () {}),
              
              const SizedBox(height: AppDimens.s21),
              
              _buildMenuTile(
                Icons.logout, 
                'Keluar', 
                () => ref.read(authControllerProvider.notifier).logout(),
                isDestructive: true
              ),
              
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false, bool hasBadge = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.s13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r24),
        boxShadow: AppShadows.card,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppDimens.s8),
          decoration: BoxDecoration(
            color: isDestructive ? AppColors.error.withValues(alpha: 0.1) : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isDestructive ? AppColors.error : AppColors.textPrimary
          )
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasBadge)
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
            if (hasBadge) const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }
}
