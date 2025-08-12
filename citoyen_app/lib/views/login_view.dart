import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import 'dashboard_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uri = Uri.parse("http://localhost:4000/api/auth/login");
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": emailCtrl.text,
          "password": passwordCtrl.text,
          "role": "citoyen",
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        String? numeroUnique = data["numeroUnique"] ?? data["citoyen"]?["numeroUnique"];

        // Si pas de numéro unique mais un token → on va chercher les infos
        if (numeroUnique == null && data["token"] != null) {
          final meRes = await http.get(
            Uri.parse("http://localhost:4000/api/citoyens/me"),
            headers: {
              "Authorization": "Bearer ${data["token"]}",
              "Content-Type": "application/json"
            },
          );
          if (meRes.statusCode == 200) {
            final meData = jsonDecode(meRes.body);
            numeroUnique = meData["numeroUnique"];
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardView(numeroUnique: numeroUnique),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Erreur lors de la connexion")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(controller: emailCtrl, label: "Email ou Numéro unique"),
            const SizedBox(height: 12),
            CustomInput(controller: passwordCtrl, label: "Mot de passe", obscureText: true),
            const SizedBox(height: 20),
            CustomButton(
              text: loading ? "Connexion..." : "Se connecter",
              // ✅ Correction : on enveloppe la fonction async dans une closure
              onPressed: loading ? null: () {
                 login();
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Pas encore de compte ?"),
                TextButton(
                  onPressed: goToRegister,
                  child: const Text(
                    "S’inscrire",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}