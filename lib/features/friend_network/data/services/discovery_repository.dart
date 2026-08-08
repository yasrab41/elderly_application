import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/social_models.dart';

class DiscoveryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<PublicProfileModel>> getDiscoverableProfiles() async {
    final myUid = _auth.currentUser!.uid;
    final snap = await _firestore.collection('publicProfiles').get();
    return snap.docs
        .where((d) => d.id != myUid)
        .map((d) => PublicProfileModel.fromMap(d.id, d.data()))
        .toList();
  }
}
