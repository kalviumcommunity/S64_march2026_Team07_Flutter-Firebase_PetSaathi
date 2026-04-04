import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/pet_model.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createPetProfile(PetModel pet) async {
    await _firestore.collection('pets').doc(pet.id.isEmpty ? null : pet.id).set(pet.toMap());
  }

  Future<void> updatePetProfile(PetModel pet) async {
    await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
  }

  Future<String> uploadPetPhoto(String ownerId, File file) async {
    final fileName = 'pet_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('owners/$ownerId/pets/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> deletePetProfile(String petId) async {
    await _firestore.collection('pets').doc(petId).delete();
  }

  Stream<List<PetModel>> watchOwnerPets(String ownerId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => PetModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<PetModel?> getPetDetail(String petId) async {
    final doc = await _firestore.collection('pets').doc(petId).get();
    if (!doc.exists) return null;
    return PetModel.fromMap(petId, doc.data()!);
  }
}
