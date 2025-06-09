import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginOrRegister() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final auth = FirebaseAuth.instance;

      try {
        print('🔵 Intentando login');
        final credential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        final uid = credential.user!.uid;

        final doc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .get();

        if (!doc.exists) {
          print('⚠️ Usuario en Auth pero no en Firestore. Cerrando sesión.');
          await auth.signOut();
          mostrarError(
            'Usuario válido, pero no registrado en la base de datos.',
          );
          return;
        }

        print('✅ Login completo');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('🟡 Usuario no encontrado, intentando crear...');
          try {
            final userCredential = await auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            final uid = userCredential.user!.uid;

            print('✅ Usuario creado en Firebase Auth con UID: $uid');

            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(uid)
                .set({
                  'email': email,
                  'fechaRegistro': FieldValue.serverTimestamp(),
                });

            print('✅ Documento creado en Firestore');
          } catch (e) {
            print('❌ Error al crear usuario: $e');
            mostrarError('No se pudo crear el usuario. Detalle: $e');
          }
        } else if (e.code == 'wrong-password') {
          mostrarError('Contraseña incorrecta');
        } else {
          throw e;
        }
      }
    } on FirebaseAuthException catch (e) {
      mostrarError('Firebase Error: ${e.message}');
      print('🔥 ERROR: ${e.code}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 24),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: loginOrRegister,
                  child: Text('Iniciar sesión'),
                ),
          ],
        ),
      ),
    );
  }
}
