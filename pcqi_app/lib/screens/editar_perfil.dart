import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? nomeAtual;
  String? emailAtual;

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  Future<void> carregarDadosUsuario() async {
    const url = "https://pcqi-api.onrender.com/api/v1/users/me";
    final token = await SharedPreferencesHelper.getAccessToken();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nomeAtual = data["name"];
          emailAtual = data["email"];
        });
      } else {
        print("Erro ao carregar usuário: ${response.body}");
      }
    } catch (e) {
      print("Erro de conexão: $e");
    }
  }

  Future<void> salvarPerfil() async {
    const url = "https://pcqi-api.onrender.com/api/v1/users/me";
    final token = await SharedPreferencesHelper.getAccessToken();

    final body = {
      "name": nomeController.text.isNotEmpty ? nomeController.text : nomeAtual,
      "email": emailController.text.isNotEmpty
          ? emailController.text
          : emailAtual,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Perfil atualizado com sucesso!")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro de conexão: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: Text(
          "Editar Perfil",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.branco,
          ),
        ),
        backgroundColor: AppColors.azulEscuro,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30), // mesmo padding do register
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Campo Nome
              TextFormField(
                controller: nomeController,
                maxLength: 80,
                style: AppStyles.textFieldTextStyle,
                decoration:
                    AppStyles.textFieldDecoration(
                      "Nome atual: ${nomeAtual ?? ''}",
                    ).copyWith(
                      hintText: "Novo nome",
                      prefixIcon: Icon(Icons.person, color: AppColors.cinza),
                    ),
              ),
              const SizedBox(height: 15),

              // Campo Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppStyles.textFieldTextStyle,
                decoration:
                    AppStyles.textFieldDecoration(
                      "E-mail atual: ${emailAtual ?? ''}",
                    ).copyWith(
                      hintText: "Novo e-mail",
                      prefixIcon: Icon(Icons.mail, color: AppColors.cinza),
                    ),
              ),
              const SizedBox(height: 30),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulEscuro,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: salvarPerfil,
                  child: Text(
                    "Salvar Alterações",
                    style: AppStyles
                        .loadingButtonTextStyle, // você pode manter esse
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
