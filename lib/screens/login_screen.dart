import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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
          await auth.signOut();
          mostrarError(
            'Usuario válido, pero no registrado en la base de datos.',
          );
          return;
        }

        print('✅ Usuario logeado');
        //Provider.of<CarritoProvider>(context, listen: false).setUser(uid);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('🟡 No encontrado, creando nuevo usuario...');
          final newUser = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          final uid = newUser.user!.uid;

          await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
            'email': email,
            'fechaRegistro': FieldValue.serverTimestamp(),
          });

          print('✅ Usuario creado en Auth y Firestore');
        } else if (e.code == 'wrong-password') {
          mostrarError('Contraseña incorrecta');
        } else {
          mostrarError('Error desconocido: ${e.message}');
        }
      }
    } on FirebaseAuthException catch (e) {
      mostrarError('Firebase Error: ${e.message}');
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
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: loginOrRegister,
                    child: const Text('Iniciar sesión'),
                  ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
