class Promotion {
  final String id;
  final String code;
  final String title;
  final String type; // percent | fixed
  final double value;
  final double minOrder;
  final double? maxDiscount;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;

  Promotion({
    required this.id,
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    required this.minOrder,
    required this.maxDiscount,
    required this.isActive,
    required this.startsAt,
    required this.endsAt,
  });
}
