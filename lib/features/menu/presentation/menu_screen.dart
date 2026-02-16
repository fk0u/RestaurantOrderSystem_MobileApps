import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/theme/design_system.dart';
import '../../tables/data/table_repository.dart';
import '../../tables/domain/table_entity.dart';
import '../domain/product_entity.dart';
import 'bloc/menu_bloc.dart';
import 'bloc/menu_event.dart';
import 'bloc/menu_state.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_state.dart';
import '../../cart/domain/cart_item.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the bloc with an event to load products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuBloc>().add(FetchMenuProducts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final selectedTable = ref.watch(selectedTableProvider);
    final selectedSeatCount = ref.watch(selectedSeatCountProvider);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final cartItems = (cartState is CartLoaded)
            ? cartState.items
            : <CartItem>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: cartItems.isNotEmpty
              ? Container(
                      margin: const EdgeInsets.only(bottom: 100),
                      child: FloatingActionButton.extended(
                        onPressed: () => context.push('/cart'),
                        backgroundColor: AppColors.primary,
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        label: Text(
                          '${cartItems.length} Item | ${_formatCurrency(cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity)))}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.elasticOut)
                    .fadeIn()
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            bottom: false,
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
                      ).animate().fadeIn().scale(),
                      const SizedBox(width: 16),
                      Expanded(
                        child:
                            Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Daftar Menu',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Text(
                                      'Restaurant Order System',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .moveX(begin: -10, end: 0),
                      ),
                      const SizedBox(width: 8),
                      // Table Selector
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
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
                      ).animate().fadeIn(delay: 300.ms).scale(),
                    ],
                  ),
                ),

                if (selectedTable != null && selectedSeatCount != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Duduk $selectedSeatCount orang • Kapasitas ${selectedTable.capacity}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ).animate().fadeIn(),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context.read<MenuBloc>().add(SearchMenuProducts(query));
                    },
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
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),

                const SizedBox(height: 16),

                // Categories
                BlocBuilder<MenuBloc, MenuState>(
                  builder: (context, state) {
                    String currentCategory = 'all';
                    if (state is MenuLoaded) {
                      currentCategory = state.activeCategory;
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildCategoryChip(
                            context,
                            'Semua',
                            'all',
                            currentCategory,
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryChip(
                            context,
                            'Makanan Utama',
                            'makanan_utama',
                            currentCategory,
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryChip(
                            context,
                            'Minuman',
                            'minuman',
                            currentCategory,
                          ),
                          const SizedBox(width: 12),
                          _buildCategoryChip(
                            context,
                            'Camilan',
                            'camilan',
                            currentCategory,
                          ),
                        ],
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 500.ms).moveX(),

                const SizedBox(height: 16),

                // Product Grid
                Expanded(
                  child: BlocBuilder<MenuBloc, MenuState>(
                    builder: (context, menuState) {
                      if (menuState is MenuLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (menuState is MenuError) {
                        return Center(
                          child: Text('Error: ${menuState.message}'),
                        );
                      }

                      if (menuState is MenuLoaded) {
                        final products = menuState.filteredProducts;
                        final availableProducts = products
                            .where((p) => p.stock > 0)
                            .toList();
                        final unavailableProducts = products
                            .where((p) => p.stock <= 0)
                            .toList();

                        if (products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Menu tidak ditemukan',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          children: [
                            if (availableProducts.isNotEmpty)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.7,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: availableProducts.length,
                                itemBuilder: (context, index) {
                                  final product = availableProducts[index];
                                  return _buildProductCard(
                                    context,
                                    product,
                                    cartItems,
                                    currencyFormatter,
                                    index,
                                  );
                                },
                              ),

                            if (unavailableProducts.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Menu Tidak Tersedia',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
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
                            ],
                          ],
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    List<CartItem> cartItems,
    NumberFormat currencyFormatter,
    int index,
  ) {
    // Safe Quantity Check from Cart
    int qty = 0;
    try {
      final found = cartItems.where((item) => item.product.id == product.id);
      if (found.isNotEmpty) {
        qty = found.first.quantity;
      }
    } catch (e) {
      qty = 0;
    }

    return GestureDetector(
      onTap: () {
        context.push('/product_detail', extra: product);
      },
      child:
          Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.r24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppDimens.r24),
                              ),
                              color: Colors.grey[100],
                              image: DecorationImage(
                                image: NetworkImage(product.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (qty > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$qty',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Details
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // Standard push to detail for adding
                                context.push('/product_detail', extra: product);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(0, 32),
                              ),
                              child: const Text(
                                'Tambah',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, delay: (50 * index).ms)
              .scale(begin: const Offset(0.9, 0.9)),
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
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.r24),
                ),
                color: Colors.grey[100],
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Habis',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(product.price),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String categoryValue,
    String currentCategory,
  ) {
    final isSelected = currentCategory == categoryValue;
    return GestureDetector(
      onTap: () {
        context.read<MenuBloc>().add(FilterMenuByCategory(categoryValue));
      },
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  void _showTablePicker(BuildContext context, WidgetRef ref) {
    final tablesFuture = ref.read(tableRepositoryProvider).getTables();
    RestaurantTable? selectedTable = ref.read(selectedTableProvider);
    final seatController = TextEditingController(
      text: ref.read(selectedSeatCountProvider)?.toString() ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom +
                24,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              final seatCount = int.tryParse(seatController.text.trim());
              final isSeatValid = seatCount != null && seatCount > 0;
              final isCapacityValid = selectedTable == null || seatCount == null
                  ? false
                  : seatCount <= selectedTable!.capacity;
              final canSubmit =
                  isSeatValid && selectedTable != null && isCapacityValid;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pilih Meja',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<RestaurantTable>>(
                    future: tablesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
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
                  const SizedBox(height: 24),
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
              );
            },
          ),
        );
      },
    );
  }
}

// Providers for Table selection (kept as Riverpod for now)
final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);
final selectedSeatCountProvider = StateProvider<int?>((ref) => null);
