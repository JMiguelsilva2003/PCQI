import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/models/user_model.dart';
import 'package:pcqi_app/providers/provider_model.dart';
import 'package:pcqi_app/screens/editar_perfil.dart';
import 'package:pcqi_app/services/shared_preferences_helper.dart';
import 'package:provider/provider.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  UserModel? user;
  bool isLoading = true; // controla loading
  String? errorMessage; // guarda mensagens de erro

  @override
  void initState() {
    super.initState();
    carregarUsuario();
  }

  Future<void> carregarUsuario() async {
    const url = "https://pcqi-api.onrender.com/api/v1/users/me";
    final token = SharedPreferencesHelper.getAccessToken();

    if (token == null) {
      setState(() {
        errorMessage = "Usuário não autenticado.";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        UserModel result = UserModel.fromJson(jsonDecode(response.body));
        if (!mounted) return;
        final provider = context.read<ProviderModel>();
        provider.setUser(result);
        isLoading = false;
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Sessão expirada. Faça login novamente.";
          isLoading = false;
        });
        // aqui você poderia redirecionar para tela de login
      } else {
        setState(() {
          errorMessage = "Erro ao carregar perfil: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro de conexão: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aaa = Provider.of<ProviderModel>(context);
    return Consumer<ProviderModel>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: AppColors.branco,
        appBar: AppBar(
          title: Text(
            "Perfil",
            style: TextStyle(
              fontFamily: 'Poppins-Regular',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.branco,
            ),
          ),
          backgroundColor: AppColors.azulEscuro,
          elevation: 0,
        ),
        body: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != null
              ? Text(
                  errorMessage!,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.vermelho,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins-Bold',
                  ),
                  textAlign: TextAlign.center,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.azulBebe,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.preto,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      aaa.userData.name!,
                      style: TextStyle(
                        fontSize: 22,
                        color: AppColors.preto,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      aaa.userData.email!,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.cinza,
                        fontFamily: 'Poppins-Regular',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Botão Editar Perfil
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulEscuro,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditarPerfil(),
                            ),
                          );
                        },
                        child: Text(
                          "Editar Perfil",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins-Bold',
                            color: AppColors.branco,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vermelho,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await SharedPreferencesHelper.setAccessToken("");
                          await SharedPreferencesHelper.setRefreshToken("");
                          if (!context.mounted) return;
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamedAndRemoveUntil(
                            '/landingpage',
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Sair da conta",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins-Bold',
                            color: AppColors.branco,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    /*
                        // Botão Excluir Conta
                        SizedBox(
                          width: 200,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.vermelho, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _confirmDelete(context),
                            icon:
                                Icon(Icons.delete, color: AppColors.vermelho),
                            label: Text(
                              "Excluir Conta",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.vermelho,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),*/
                  ],
                ),
        ),
      ),
    );
  }

  // diálogo de confirmação da exclusão
  /*void _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Excluir conta",
          style: TextStyle(
            fontFamily: 'Poppins-Bold',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.preto,
          ),
        ),
        content: Text(
          "Tem certeza que deseja excluir sua conta?\n"
          "Esta ação é permanente e não pode ser desfeita.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins-Regular',
            color: AppColors.cinza,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancelar",
              style: TextStyle(
                color: AppColors.cinzaEscuro,
                fontFamily: 'Poppins-Regular',
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.vermelho),
            child: Text(
              "Excluir",
              style: TextStyle(
                color: AppColors.vermelho,
                fontFamily: 'Poppins-Regular',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Conta excluída com sucesso",
            style: TextStyle(fontFamily: 'Poppins-Regular'),
          ),
        ),
      );
    }
  }*/
}
