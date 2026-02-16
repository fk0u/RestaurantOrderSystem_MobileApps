import 'package:equatable/equatable.dart';
import '../../domain/product_entity.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String activeCategory;

  const MenuLoaded({
    required this.allProducts,
    required this.filteredProducts,
    this.activeCategory = 'all',
  });

  MenuLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? activeCategory,
  }) {
    return MenuLoaded(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  @override
  List<Object?> get props => [allProducts, filteredProducts, activeCategory];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
