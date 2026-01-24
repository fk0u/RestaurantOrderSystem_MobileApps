class AdminReservation {
  final String id;
  final String? tableNumber;
  final int partySize;
  final String reservedAt;
  final String status;

  AdminReservation({
    required this.id,
    required this.tableNumber,
    required this.partySize,
    required this.reservedAt,
    required this.status,
  });
}

class AdminShift {
  final String id;
  final String? userName;
  final String role;
  final String startsAt;
  final String? endsAt;
  final String status;

  AdminShift({
    required this.id,
    required this.userName,
    required this.role,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });
}

class AdminPromotion {
  final String id;
  final String code;
  final String title;
  final String type;
  final double value;
  final bool isActive;

  AdminPromotion({
    required this.id,
    required this.code,
    required this.title,
    required this.type,
    required this.value,
    required this.isActive,
  });
}

class AdminDailyStock {
  final String id;
  final String productName;
  final int openingStock;
  final int closingStock;
  final int sold;
  final int adjusted;

  AdminDailyStock({
    required this.id,
    required this.productName,
    required this.openingStock,
    required this.closingStock,
    required this.sold,
    required this.adjusted,
  });
}
