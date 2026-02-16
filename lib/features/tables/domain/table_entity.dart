class RestaurantTable {
  final String id;
  final String number;
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'
  final double x;
  final double y;

  RestaurantTable({
    required this.id,
    required this.number,
    required this.capacity,
    required this.status,
    required this.x,
    required this.y,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'],
      number: json['number'],
      capacity: json['capacity'] as int,
      status: json['status'],
      x: json['x'] as double,
      y: json['y'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'capacity': capacity,
      'status': status,
      'x': x,
      'y': y,
    };
  }

  RestaurantTable copyWith({String? status}) {
    return RestaurantTable(
      id: id,
      number: number,
      capacity: capacity,
      status: status ?? this.status,
      x: x,
      y: y,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestaurantTable &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
