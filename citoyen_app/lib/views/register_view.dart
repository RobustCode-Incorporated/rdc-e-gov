import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final nomCtrl = TextEditingController();
  final postnomCtrl = TextEditingController();
  final prenomCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  DateTime? dateNaissance;
  String? selectedGenre;
  int? selectedProvinceId;
  int? selectedCommuneId;
  String? numeroUnique;
  bool loading = false;

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> communes = [];

  final genres = ["Homme", "Femme"];

  @override
  void initState() {
    super.initState();
    fetchProvinces();
  }

  // Récupérer la liste des provinces depuis le backend
  Future<void> fetchProvinces() async {
    try {
      final uri = Uri.parse("http://localhost:4000/api/provinces");
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          provinces = List<Map<String, dynamic>>.from(data);
        });
      } else {
        debugPrint("Erreur chargement provinces: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Erreur fetchProvinces: $e");
    }
  }

  // Récupérer la liste des communes filtrée par province
  Future<void> fetchCommunesByProvince(int provinceId) async {
    try {
      final uri = Uri.parse("http://localhost:4000/api/communes/public/province/$provinceId");
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          communes = List<Map<String, dynamic>>.from(data);
          selectedCommuneId = null; // reset selection commune
        });
      } else {
        debugPrint("Erreur chargement communes: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("Erreur fetchCommunesByProvince: $e");
    }
  }

  Future<void> pickDate() async {
    final today = DateTime.now();
    final initialDate = DateTime(today.year - 18, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: today,
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        dateNaissance = picked;
      });
    }
  }

  Future<void> register() async {
    if (nomCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        selectedProvinceId == null ||
        selectedCommuneId == null ||
        selectedGenre == null ||
        dateNaissance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final uri = Uri.parse("http://localhost:4000/api/citoyens/register");
      final res = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nom": nomCtrl.text,
          "postnom": postnomCtrl.text,
          "prenom": prenomCtrl.text,
          "email": emailCtrl.text,
          "password": passwordCtrl.text,
          "telephone": phoneCtrl.text,
          "dateNaissance": dateNaissance!.toIso8601String().split("T")[0], // format ISO date
          "genre": selectedGenre,
          "communeId": selectedCommuneId,
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 201) {
        setState(() {
          numeroUnique = data["numeroUnique"] ?? data["citoyen"]?["numeroUnique"];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Inscription réussie")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Erreur lors de l’inscription")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription citoyen")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInput(controller: nomCtrl, label: "Nom"),
            const SizedBox(height: 12),
            CustomInput(controller: postnomCtrl, label: "Postnom"),
            const SizedBox(height: 12),
            CustomInput(controller: prenomCtrl, label: "Prénom"),
            const SizedBox(height: 12),
            CustomInput(controller: emailCtrl, label: "Email"),
            const SizedBox(height: 12),
            CustomInput(controller: passwordCtrl, label: "Mot de passe", obscureText: true),
            const SizedBox(height: 12),
            CustomInput(controller: phoneCtrl, label: "Téléphone"),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateNaissance == null
                        ? "Sélectionner date de naissance"
                        : dateNaissance!.toIso8601String().split("T")[0]),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Genre",
              ),
              value: selectedGenre,
              items: genres.map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedGenre = val;
                });
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Province",
              ),
              value: selectedProvinceId,
              items: provinces.map((p) {
                return DropdownMenuItem(value: p['id'] as int, child: Text(p['nom']));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedProvinceId = val;
                  selectedCommuneId = null;
                  communes = [];
                });
                if (val != null) {
                  fetchCommunesByProvince(val);
                }
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Commune",
              ),
              value: selectedCommuneId,
              items: communes.map((c) {
                return DropdownMenuItem(value: c['id'] as int, child: Text(c['nom']));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedCommuneId = val;
                });
              },
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: loading ? "Inscription..." : "S’inscrire",
              onPressed: loading ? null : register,
            ),

            if (numeroUnique != null) ...[
              const SizedBox(height: 20),
              Text(
                "Votre numéro unique : $numeroUnique",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}