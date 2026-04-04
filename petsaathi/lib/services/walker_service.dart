import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class WalkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> watchAvailableWalkers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'walker')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList());
  }

  Future<UserModel?> getWalkerDetail(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }
}
