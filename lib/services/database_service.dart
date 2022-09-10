import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/trip_model.dart';
import '../models/user_model.dart' as user;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeUser(user.User user) async {
    await _firestore.collection('drivers').doc(user.id).set(user.toMap());
    _firestore.collection('registeredUsers').doc('drivers').set({
      'registeredEmails': FieldValue.arrayUnion([user.email]),
    });
  }

  Future<bool> checkIfPassenger(String email) async {
    Map<String, dynamic> data =
        (await _firestore.collection('registeredUsers').doc('passengers').get())
            .data()!;

    if (kDebugMode) {
      print(data);
    }

    if (data['registeredEmails'] == null) {
      return false;
    } else if ((data['registeredEmails'] as List).contains(email)) {
      return true;
    }

    return false;
  }

  Future<user.User> getUser(String id) async {
    return user.User.fromJson(
      (await _firestore.collection('drivers').doc(id).get()).data()!,
    );
  }

  void updateUser(Map<String, dynamic> data) {
    _firestore
        .collection('drivers')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update(data);
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

  Future<List<Trip>> getDriverCompletedTrips() async {
    return (await _firestore
            .collection('trips')
            .where(
              'driverId',
              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            )
            .where('tripCompleted', isEqualTo: true)
            .get())
        .docs
        .map(
          (QueryDocumentSnapshot snapshot) =>
              Trip.fromJson(snapshot.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> updateTrip(Trip trip) async {
    await _firestore.collection('trips').doc(trip.id).update(trip.toMap());
  }
}
