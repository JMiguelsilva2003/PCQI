import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcqi_app/config/app_colors.dart';

// Modelo de usuário
class User {
  final String name;
  final String email;

  User({required this.name, required this.email});
}

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  User? user; // começa nulo (vai simular que vem da API)

  @override
  void initState() {
    super.initState();
    // simulação de "chamada API"
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        user = User(
          name: "Usuário de Exemplo",
          email: "usuario@teste.com",
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      appBar: AppBar(
        title: Text(
          "Perfil",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.branco,
          ),
        ),
        backgroundColor: AppColors.azulEscuro,
        elevation: 0,
      ),
      body: Center(
        child: user == null
            ? const CircularProgressIndicator() // loading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.azulBebe,
                    child: Icon(Icons.person,
                        size: 60, color: AppColors.preto),
                  ),
                  const SizedBox(height: 20),

                  // Nome
                  Text(
                    user!.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.preto,
                    ),
                  ),

                  // Email
                  const SizedBox(height: 5),
                  Text(
                    user!.email,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.cinza,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão Editar Perfil
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulEscuro,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Editar Perfil (em breve)")),
                        );
                      },
                      child: Text(
                        "Editar Perfil",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.branco,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Excluir Conta
                  SizedBox(
                    width: 200,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.vermelho, width: 2),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _confirmDelete(context),
                      icon: Icon(Icons.delete, color: AppColors.vermelho),
                      label: Text(
                        "Excluir Conta",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.vermelho,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Função de confirmação para exclusão de conta
  void _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "Excluir conta",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.preto,
          ),
        ),
        content: Text(
          "Tem certeza que deseja excluir sua conta?\n"
          "Esta ação é permanente e não pode ser desfeita.",
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.cinza),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar",
                style: GoogleFonts.poppins(color: AppColors.cinzaEscuro)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.vermelho),
            child: Text("Excluir",
                style: GoogleFonts.poppins(color: AppColors.vermelho)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Conta excluída com sucesso",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }
}
