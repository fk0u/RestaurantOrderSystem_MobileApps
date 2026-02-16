import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class FetchMenuProducts extends MenuEvent {}

class FilterMenuByCategory extends MenuEvent {
  final String category;

  const FilterMenuByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class SearchMenuProducts extends MenuEvent {
  final String query;

  const SearchMenuProducts(this.query);

  @override
  List<Object> get props => [query];
}
