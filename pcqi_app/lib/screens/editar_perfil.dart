import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/providers/provider_model.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

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
    /*carregarDadosUsuario();*/
  }

  /*Future<void> carregarDadosUsuario() async {
    const url = "https://pcqi-api.onrender.com/api/v1/users/me";
    final token = SharedPreferencesHelper.getAccessToken();

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
  }*/

  Future<void> salvarPerfil() async {
    String newName = nomeController.text.trim();
    String newPassword = emailController.text.trim();

    if (newName.isEmpty && newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complete ao menos um dos campos")),
      );
    } else {
      if (newName.isNotEmpty && newPassword.isEmpty) {
        final body = {"name": nomeController.text};
        await sendInfo(body);
      } else if (newName.isEmpty && newPassword.isNotEmpty) {
        if (newPassword.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "A senha deve conter no mínimo 8 caracteres. Apague-a completamente caso não deseje modificá-la.",
              ),
            ),
          );
        } else {
          final body = {"password": newPassword};
          await sendInfo(body);
        }
      } else {
        final body = {"name": newName, "password": newPassword};
        await sendInfo(body);
      }
    }
  }

  Future<void> sendInfo(Map<String?, String?> info) async {
    const url = "https://pcqi-api.onrender.com/api/v1/users/me";
    final token = SharedPreferencesHelper.getAccessToken();
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(info),
      );

      /*if (response.statusCode == 200) {*/
      UserModel result = UserModel.fromJson(jsonDecode(response.body));
      final provider = context.read<ProviderModel>();
      if (result.name != null && result.name != "") {
        provider.setUsername(result.name!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perfil atualizado com sucesso!")),
      );
      /*} else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro: ${response.body}")));
      }*/
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro de conexão: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderModel>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: AppColors.branco,
        appBar: AppBar(
          title: Text(
            "Editar Perfil",
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins-Regular',
              fontWeight: FontWeight.w600,
              color: AppColors.cinzaClaro,
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
                  buildCounter:
                      (
                        BuildContext context, {
                        int? currentLength,
                        int? maxLength,
                        bool? isFocused,
                      }) => null,
                  style: AppStyles.textFieldTextStyle,
                  decoration: AppStyles.textFieldDecoration("Novo nome")
                      .copyWith(
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          color: AppColors.cinza,
                        ),
                      ),
                ),
                const SizedBox(height: 15),

                // Campo Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppStyles.textFieldTextStyle,
                  buildCounter:
                      (
                        BuildContext context, {
                        int? currentLength,
                        int? maxLength,
                        bool? isFocused,
                      }) => null,
                  decoration: AppStyles.textFieldDecoration("Nova senha")
                      .copyWith(
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.cinza,
                        ),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "*Não é obrigatório preencher todos os campos",
                  style: TextStyle(
                    fontFamily: 'Poppins-Regular',
                    fontSize: 12,
                    color: AppColors.cinza,
                  ),
                ),
                const SizedBox(height: 30),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    type: ButtonType.elevated,
                    style: AppStyles.loadingButtonStyle,
                    successDuration: Duration(seconds: 0),
                    onPressed: () async {
                      await salvarPerfil();
                    },
                    child: Text(
                      "Salvar alterações",
                      style: AppStyles.loadingButtonTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
