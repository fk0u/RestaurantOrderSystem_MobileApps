import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'admin_controller.dart';
import '../data/admin_models.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminControllerProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final reservationsState = ref.watch(reservationsProvider);
    final shiftsState = ref.watch(shiftsProvider);
    final promotionsState = ref.watch(promotionsProvider);
    final dailyStockState = ref.watch(dailyStockProvider);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Dasbor Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Ringkasan'),
              Tab(text: 'Inventory'),
              Tab(text: 'Reservasi'),
              Tab(text: 'Shift'),
              Tab(text: 'Promo'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(adminControllerProvider);
                ref.invalidate(reservationsProvider);
                ref.invalidate(shiftsProvider);
                ref.invalidate(promotionsProvider);
                ref.invalidate(dailyStockProvider);
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (orders) {
                final totalSales = orders.fold(0.0, (sum, order) => sum + order.total);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total Penjualan',
                              currencyFormatter.format(totalSales),
                              Icons.monetization_on,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total Pesanan',
                              orders.length.toString(),
                              Icons.receipt_long,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Riwayat Pesanan Terbaru',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.receipt,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${order.date} • ${order.status}'),
                              trailing: Text(
                                currencyFormatter.format(order.total),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildInventoryTab(dailyStockState),
            _buildReservationsTab(reservationsState),
            _buildShiftsTab(shiftsState),
            _buildPromotionsTab(promotionsState),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
             value,
             style: const TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 18,
             ),
             maxLines: 1,
             overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTab(AsyncValue<List<AdminDailyStock>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada data stok harian'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Opening ${item.openingStock} • Closing ${item.closingStock}'),
                trailing: Text('Sold ${item.sold}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReservationsTab(AsyncValue<List<AdminReservation>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada reservasi'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text('Meja ${item.tableNumber ?? '-'} • ${item.partySize} orang'),
                subtitle: Text('${item.reservedAt} • ${item.status}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShiftsTab(AsyncValue<List<AdminShift>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada shift'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.userName ?? 'Staff'),
                subtitle: Text('${item.role} • ${item.startsAt} - ${item.endsAt ?? '-'}'),
                trailing: Text(item.status),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPromotionsTab(AsyncValue<List<AdminPromotion>> state) {
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Belum ada promo'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item.code} • ${item.type}'),
                trailing: Text(item.isActive ? 'Aktif' : 'Nonaktif'),
              ),
            );
          },
        );
      },
    );
  }
}
