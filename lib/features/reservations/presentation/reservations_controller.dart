import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/reservation_repository.dart';
import '../data/reservation_model.dart';

final reservationsListProvider = FutureProvider<List<Reservation>>((ref) {
  return ReservationRepository().getReservations();
});
