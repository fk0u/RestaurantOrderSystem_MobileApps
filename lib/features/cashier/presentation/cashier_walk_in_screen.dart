import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_order_system/core/theme/design_system.dart';
import '../../menu/presentation/bloc/menu_bloc.dart';
import '../../menu/presentation/bloc/menu_event.dart';
import '../../menu/presentation/bloc/menu_state.dart';
import '../../cart/presentation/bloc/cart_bloc.dart';
import '../../cart/presentation/bloc/cart_event.dart';
import '../../cart/presentation/bloc/cart_state.dart';
import '../../menu/domain/product_entity.dart';
import 'cashier_controller.dart';

class CashierWalkInScreen extends ConsumerStatefulWidget {
  const CashierWalkInScreen({super.key});

  @override
  ConsumerState<CashierWalkInScreen> createState() =>
      _CashierWalkInScreenState();
}

class _CashierWalkInScreenState extends ConsumerState<CashierWalkInScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuBloc>().add(FetchMenuProducts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _guestNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Pesanan Baru'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Row(
        children: [
          // Left Side: Product Grid
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildSearchBar(),
                _buildCategories(),
                Expanded(child: _buildProductGrid()),
              ],
            ),
          ),
          // Vertical Divider
          Container(width: 1, color: Colors.grey[300]),
          // Right Side: Cart Summary
          Expanded(flex: 2, child: _buildCartSummary()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (query) {
          context.read<MenuBloc>().add(SearchMenuProducts(query));
        },
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'label': 'Semua', 'value': 'all'},
      {'label': 'Makanan', 'value': 'makanan_utama'},
      {'label': 'Minuman', 'value': 'minuman'},
      {'label': 'Camilan', 'value': 'camilan'},
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['value'];
          return ChoiceChip(
            label: Text(cat['label']!),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() => _selectedCategory = cat['value']!);
                context.read<MenuBloc>().add(
                  FilterMenuByCategory(cat['value']!),
                );
              }
            },
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is MenuLoaded) {
          final products = state.filteredProducts;
          if (products.isEmpty)
            return const Center(child: Text('Menu tidak ditemukan'));

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Add to cart directly
          context.read<CartBloc>().add(
            AddCartItem(product: product, quantity: 1, note: '', modifiers: []),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyFormatter.format(product.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _guestNameController,
            decoration: const InputDecoration(
              labelText: 'Nama Pelanggan (Opsional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                if (state is CartLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return const Center(child: Text('Keranjang kosong'));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(
                          '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(item.product.price)} x ${item.quantity}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  context.read<CartBloc>().add(
                                    UpdateCartItemQuantity(
                                      item.id,
                                      item.quantity - 1,
                                    ),
                                  );
                                } else {
                                  context.read<CartBloc>().add(
                                    RemoveCartItem(item.id),
                                  );
                                }
                              },
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                context.read<CartBloc>().add(
                                  UpdateCartItemQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const Divider(),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              double total = 0;
              if (state is CartLoaded) {
                total = state.items.fold(
                  0,
                  (sum, item) => sum + (item.product.price * item.quantity),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => _submitOrder(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Buat Pesanan',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _submitOrder(BuildContext context) {
    final cartState = context.read<CartBloc>().state;
    if (cartState is CartLoaded && cartState.items.isNotEmpty) {
      // Use CashierController to submit order
      // Assuming CashierController has a method for this, otherwise we might need to use CartBloc or a new UseCase
      // For now, let's just show a dialogue or implement the logic in CashierController
      ref
          .read(cashierControllerProvider.notifier)
          .createWalkInOrder(
            items: cartState.items,
            guestName: _guestNameController.text.isNotEmpty
                ? _guestNameController.text
                : 'Walk-in Guest',
          )
          .then((success) {
            if (success) {
              context.read<CartBloc>().add(ClearCart());
              context.pop(); // Go back to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pesanan berhasil dibuat!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal membuat pesanan')),
              );
            }
          });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keranjang masih kosong')));
    }
  }
}
