import '../../../core/services/api_client.dart';
import 'reservation_model.dart';

class ReservationRepository {
  final ApiClient _api = ApiClient();

  Future<List<Reservation>> getReservations() async {
    final data = await _api.getList('/reservations');
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return Reservation(
        id: map['id'].toString(),
        tableId: map['table_id']?.toString(),
        tableNumber: map['table']?['number']?.toString(),
        partySize: (map['party_size'] as num?)?.toInt() ?? 0,
        reservedAt: map['reserved_at']?.toString() ?? '',
        status: map['status'] ?? 'reserved',
      );
    }).toList();
  }

  Future<Reservation> createReservation({
    required String? tableId,
    required int partySize,
    required DateTime reservedAt,
    String? note,
  }) async {
    final map = await _api.post('/reservations', {
      'table_id': tableId,
      'party_size': partySize,
      'reserved_at': reservedAt.toIso8601String(),
      'note': note,
      'status': 'reserved',
    });

    return Reservation(
      id: map['id'].toString(),
      tableId: map['table_id']?.toString(),
      tableNumber: map['table']?['number']?.toString(),
      partySize: (map['party_size'] as num?)?.toInt() ?? 0,
      reservedAt: map['reserved_at']?.toString() ?? '',
      status: map['status'] ?? 'reserved',
    );
  }
}
