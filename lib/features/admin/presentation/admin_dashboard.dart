import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';
import 'admin_controller.dart';
import '../data/admin_models.dart';
import '../data/admin_repository.dart';

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
    final salesReportState = ref.watch(salesReportProvider);

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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSalesFilter(context, ref),
                      const SizedBox(height: 16),
                      salesReportState.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                        data: (report) => Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Total Penjualan',
                                currencyFormatter.format(report.revenue),
                                Icons.monetization_on,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                'Total Pesanan',
                                report.orders.toString(),
                                Icons.receipt_long,
                                Colors.orange,
                              ),
                            ),
                          ],
                        ),
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
            _buildInventoryTab(context, ref, dailyStockState),
            _buildReservationsTab(reservationsState),
            _buildShiftsTab(context, ref, shiftsState),
            _buildPromotionsTab(context, ref, promotionsState),
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

  Widget _buildInventoryTab(BuildContext context, WidgetRef ref, AsyncValue<List<AdminDailyStock>> state) {
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
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showAdjustStockDialog(context, ref, item),
                ),
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

  Widget _buildShiftsTab(BuildContext context, WidgetRef ref, AsyncValue<List<AdminShift>> state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateShiftDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Shift'),
            ),
          ),
        ),
        Expanded(
          child: state.when(
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
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionsTab(BuildContext context, WidgetRef ref, AsyncValue<List<AdminPromotion>> state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreatePromoDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Promo'),
            ),
          ),
        ),
        Expanded(
          child: state.when(
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
                subtitle: Text('${item.code} • ${item.type} • ${item.value.toStringAsFixed(0)}'),
                trailing: Switch(
                  value: item.isActive,
                  onChanged: (val) async {
                    await AdminRepository().updatePromotionActive(id: item.id, isActive: val);
                    ref.invalidate(promotionsProvider);
                  },
                ),
              ),
            );
          },
        );
      },
          ),
        ),
      ],
    );
  }

  Future<void> _showCreateShiftDialog(BuildContext context, WidgetRef ref) async {
    final roleController = TextEditingController(text: 'cashier');
    final userIdController = TextEditingController();
    DateTime start = DateTime.now();
    DateTime? end;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Shift', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: userIdController,
                    decoration: const InputDecoration(labelText: 'User ID (opsional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roleController,
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text('Mulai ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'),
                          onPressed: () async {
                            final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(start));
                            if (picked != null) {
                              setModalState(() {
                                start = DateTime(start.year, start.month, start.day, picked.hour, picked.minute);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule),
                          label: Text('Selesai ${end == null ? '-' : '${end!.hour.toString().padLeft(2, '0')}:${end!.minute.toString().padLeft(2, '0')}'}'),
                          onPressed: () async {
                            final picked = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(end ?? DateTime.now()));
                            if (picked != null) {
                              setModalState(() {
                                end = DateTime(start.year, start.month, start.day, picked.hour, picked.minute);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await AdminRepository().createShift(
                              userId: userIdController.text.trim().isEmpty ? null : userIdController.text.trim(),
                              role: roleController.text.trim().isEmpty ? 'staff' : roleController.text.trim(),
                              startsAt: start,
                              endsAt: end,
                            );
                            ref.invalidate(shiftsProvider);
                            if (context.mounted) Navigator.pop(ctx);
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreatePromoDialog(BuildContext context, WidgetRef ref) async {
    final codeController = TextEditingController();
    final titleController = TextEditingController();
    final valueController = TextEditingController();
    String type = 'percent';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Promo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Kode Promo', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Judul Promo', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'percent', child: Text('Percent')),
                      DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                    ],
                    onChanged: (value) => setModalState(() => type = value ?? 'percent'),
                    decoration: const InputDecoration(labelText: 'Tipe', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Nilai', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal'))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final value = double.tryParse(valueController.text.trim()) ?? 0;
                            if (value <= 0) return;
                            await AdminRepository().createPromotion(
                              code: codeController.text.trim(),
                              title: titleController.text.trim(),
                              type: type,
                              value: value,
                            );
                            ref.invalidate(promotionsProvider);
                            if (context.mounted) Navigator.pop(ctx);
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSalesFilter(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final now = DateTime.now();
              ref.read(salesRangeProvider.notifier).state = DateTimeRange(
                start: DateTime(now.year, now.month, now.day),
                end: DateTime(now.year, now.month, now.day, 23, 59, 59),
              );
              ref.invalidate(salesReportProvider);
            },
            child: const Text('Hari ini'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              final now = DateTime.now();
              ref.read(salesRangeProvider.notifier).state = DateTimeRange(
                start: now.subtract(const Duration(days: 7)),
                end: now,
              );
              ref.invalidate(salesReportProvider);
            },
            child: const Text('7 Hari'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                ref.read(salesRangeProvider.notifier).state = picked;
                ref.invalidate(salesReportProvider);
              }
            },
            child: const Text('Custom'),
          ),
        ),
      ],
    );
  }

  Future<void> _showAdjustStockDialog(BuildContext context, WidgetRef ref, AdminDailyStock item) async {
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adjust Stok - ${item.productName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (+/-)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal'))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                        if (qty == 0) return;
                        await AdminRepository().adjustStock(
                          productId: item.productId,
                          quantity: qty,
                          reason: reasonController.text.trim(),
                        );
                        ref.invalidate(dailyStockProvider);
                        if (context.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
