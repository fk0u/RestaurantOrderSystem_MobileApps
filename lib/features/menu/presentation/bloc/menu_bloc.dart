import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository;

  MenuBloc({required this.menuRepository}) : super(MenuInitial()) {
    on<FetchMenuProducts>(_onFetchMenuProducts);
    on<FilterMenuByCategory>(_onFilterMenuByCategory);
    on<SearchMenuProducts>(_onSearchMenuProducts);
  }

  Future<void> _onFetchMenuProducts(
    FetchMenuProducts event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());
    try {
      final products = await menuRepository.getProducts();
      emit(MenuLoaded(allProducts: products, filteredProducts: products));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }

  void _onFilterMenuByCategory(
    FilterMenuByCategory event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      final category = event.category;

      final filtered = category == 'all'
          ? currentState.allProducts
          : currentState.allProducts
                .where((p) => p.category == category)
                .toList();

      emit(
        currentState.copyWith(
          filteredProducts: filtered,
          activeCategory: category,
        ),
      );
    }
  }

  void _onSearchMenuProducts(
    SearchMenuProducts event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      final query = event.query.toLowerCase();

      final filtered = currentState.allProducts.where((p) {
        final matchesCategory =
            currentState.activeCategory == 'all' ||
            p.category == currentState.activeCategory;
        final matchesQuery = p.name.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();

      emit(currentState.copyWith(filteredProducts: filtered));
    }
  }
}
