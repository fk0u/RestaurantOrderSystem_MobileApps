import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/presentation/cart_controller.dart';
import 'menu_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/theme/design_system.dart';
import '../../tables/data/table_repository.dart';
import '../../tables/domain/table_entity.dart';
import '../domain/product_entity.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(menuControllerProvider);
    final cartItems = ref.watch(cartControllerProvider);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final selectedTable = ref.watch(selectedTableProvider);
    final selectedSeatCount = ref.watch(selectedSeatCountProvider);

    // Filter Logic
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: cartItems.isNotEmpty
          ? Container(
              margin: const EdgeInsets.only(bottom: 100),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/cart'),
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  '${cartItems.length} Item | ${_formatCurrency(cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity)))}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        bottom: false, // Allow content to go behind dock
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Menu',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Pesanan #34619', // Mock Order ID
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Badge (Mock)
                  InkWell(
                    onTap: () => _showTablePicker(context, ref),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        selectedTable == null
                            ? 'Pilih meja'
                            : 'Meja ${selectedTable.number}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (selectedTable != null && selectedSeatCount != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Duduk ${selectedSeatCount} orang • Kapasitas ${selectedTable.capacity}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),

            // Search Bar (Mock)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari makanan atau minuman...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildCategoryChip(ref, 'Semua', 'all', selectedCategory),
                  const SizedBox(width: 12),
                  _buildCategoryChip(
                    ref,
                    'Makanan Utama',
                    'makanan_utama',
                    selectedCategory,
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryChip(
                    ref,
                    'Minuman',
                    'minuman',
                    selectedCategory,
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryChip(
                    ref,
                    'Camilan',
                    'camilan',
                    selectedCategory,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Product Sections
            Expanded(
              child: menuState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Terjadi kesalahan: $err')),
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(child: Text('Tidak ada menu tersedia'));
                  }
                  // final inCartIds = cartItems.map((e) => e.product.id).toSet(); // Removed
                  final availableProducts = products
                      .where((p) => p.stock > 0)
                      .toList();
                  final unavailableProducts = products
                      .where((p) => p.stock <= 0)
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: availableProducts.length,
                        itemBuilder: (context, index) {
                          final product = availableProducts[index];
                          // Safe Quantity Check
                          int qty = 0;
                          try {
                            final found = cartItems.where(
                              (item) => item.product.id == product.id,
                            );
                            if (found.isNotEmpty) {
                              qty = found.first.quantity;
                            }
                          } catch (e) {
                            qty = 0;
                          }

                          return GestureDetector(
                            onTap: () =>
                                context.push('/product_detail', extra: product),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.r24,
                                ),
                                boxShadow: AppShadows.card,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Expanded(
                                    flex: 5,
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(
                                                  AppDimens.r24,
                                                ),
                                              ),
                                          child: Image.network(
                                            product.imageUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.local_fire_department,
                                                  color: Colors.orange,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${product.calories} kkal',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Fav Button
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite_border,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Info Section
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormatter.format(
                                              product.price,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Stok: ${product.stock}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Spacer(),
                                          // Add Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 36,
                                            child: qty > 0
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _buildQtyBtn(
                                                        () => ref
                                                            .read(
                                                              cartControllerProvider
                                                                  .notifier,
                                                            )
                                                            .updateQuantity(
                                                              product.id,
                                                              qty - 1,
                                                            ),
                                                        Icons.remove,
                                                      ),
                                                      Text(
                                                        '$qty',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      _buildQtyBtn(
                                                        () => ref
                                                            .read(
                                                              cartControllerProvider
                                                                  .notifier,
                                                            )
                                                            .updateQuantity(
                                                              product.id,
                                                              qty + 1,
                                                            ),
                                                        Icons.add,
                                                        isDisabled:
                                                            qty >=
                                                            product.stock,
                                                      ),
                                                    ],
                                                  )
                                                : ElevatedButton(
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                            cartControllerProvider
                                                                .notifier,
                                                          )
                                                          .addItem(product);
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).hideCurrentSnackBar();
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            '${product.name} ditambahkan',
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    500,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppColors.background,
                                                      foregroundColor:
                                                          AppColors.textPrimary,
                                                      elevation: 0,
                                                      padding: EdgeInsets.zero,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Tambah',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (unavailableProducts.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Menu Tidak Tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 280,
                          child: GridView.builder(
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: unavailableProducts.length,
                            itemBuilder: (context, index) {
                              final product = unavailableProducts[index];
                              return _buildUnavailableCard(
                                product,
                                currencyFormatter,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  Future<void> _showTablePicker(BuildContext context, WidgetRef ref) async {
    final tablesFuture = ref.read(tableRepositoryProvider).getTables();
    RestaurantTable? selectedTable = ref.read(selectedTableProvider);
    final seatController = TextEditingController(
      text: ref.read(selectedSeatCountProvider)?.toString() ?? '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final seatCount = int.tryParse(seatController.text.trim());
            final isSeatValid = seatCount != null && seatCount > 0;
            final isTableValid = selectedTable != null;
            final isCapacityValid = selectedTable == null || seatCount == null
                ? false
                : seatCount <= selectedTable!.capacity;
            final canSubmit = isSeatValid && isTableValid && isCapacityValid;

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom:
                    MediaQuery.of(ctx).viewInsets.bottom +
                    MediaQuery.of(ctx).padding.bottom +
                    24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Meja',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<RestaurantTable>>(
                    future: tablesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LinearProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('Tidak ada data meja.');
                      }

                      final availableTables = snapshot.data!
                          .where((t) => t.status == 'available')
                          .toList();

                      if (availableTables.isEmpty) {
                        return const Text('Tidak ada meja tersedia saat ini.');
                      }

                      return DropdownButtonFormField<RestaurantTable>(
                        value: availableTables
                            .where((t) => t.id == selectedTable?.id)
                            .firstOrNull,
                        items: availableTables
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(
                                  '${t.number} • ${t.capacity} orang',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setModalState(() => selectedTable = value),
                        decoration: const InputDecoration(
                          labelText: 'Meja',
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: seatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah orang yang duduk',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  if (isSeatValid && selectedTable != null && !isCapacityValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Jumlah orang melebihi kapasitas meja (maks ${selectedTable!.capacity}).',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  if (selectedTable != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Kapasitas meja: ${selectedTable!.capacity} orang',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: canSubmit
                              ? () {
                                  ref
                                          .read(selectedTableProvider.notifier)
                                          .state =
                                      selectedTable;
                                  ref
                                          .read(
                                            selectedSeatCountProvider.notifier,
                                          )
                                          .state =
                                      seatCount;
                                  Navigator.pop(ctx);
                                }
                              : null,
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

  Widget _buildUnavailableCard(
    Product product,
    NumberFormat currencyFormatter,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimens.r24),
                  ),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
                    child: Image.network(
                      product.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tidak tersedia',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Tidak tersedia',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    WidgetRef ref,
    String label,
    String id,
    String selectedId,
  ) {
    final isSelected = id == selectedId;
    return GestureDetector(
      onTap: () => ref.read(selectedCategoryProvider.notifier).state = id,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyBtn(
    VoidCallback onTap,
    IconData icon, {
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[200] : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDisabled ? Colors.grey : AppColors.primary,
        ),
      ),
    );
  }
}

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');
final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);
final selectedSeatCountProvider = StateProvider<int?>((ref) => null);
