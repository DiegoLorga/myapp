import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String email;
  final DateTime? fechaRegistro;

  UsuarioModel({required this.uid, required this.email, this.fechaRegistro});

  factory UsuarioModel.fromMap(String uid, Map<String, dynamic> map) {
    return UsuarioModel(
      uid: uid,
      email: map['email'] ?? '',
      fechaRegistro: (map['fechaRegistro'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fechaRegistro': fechaRegistro ?? FieldValue.serverTimestamp(),
    };
  }
}
