class Reservation {
  final String id;
  final String? tableId;
  final String? tableNumber;
  final int partySize;
  final String reservedAt;
  final String status;

  Reservation({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.partySize,
    required this.reservedAt,
    required this.status,
  });
}
