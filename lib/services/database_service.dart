import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';
import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('drivers').doc(user.id).set(user.toMap());
  }

  Stream<List<Trip>> getTrips() {
    return _firestore
        .collection('trips')
        .where('canceled', isEqualTo: false)
        .where('accepted', isEqualTo: false)
        .snapshots()
        .map(
          (QuerySnapshot snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot doc) =>
                    Trip.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }
}
