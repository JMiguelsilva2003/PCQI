import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/screens/camera.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:pcqi_app/services/stats_services.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late Future<Map<String, dynamic>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = StatsService.getStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            /// Exibe os cards de estatísticas
            Center(
              child: FutureBuilder<Map<String, dynamic>>(
                future: statsFuture,
                builder: (context, snapshot) {
                  /// LOADING
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Scaffold(
                      backgroundColor: AppColors.branco,
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.azulEscuro,
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Carregando...",
                              style: AppStyles.textStyleTituloSecundario,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  /// ERRO
                  if (snapshot.hasError) {
                    return Scaffold(
                      backgroundColor: AppColors.branco,
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Erro ao carregar estatísticas.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                statsFuture = StatsService.getStats();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Tentar novamente"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.azulEscuro,
                              foregroundColor: AppColors.branco,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  /// SUCESSO
                  final data = snapshot.data!;
                  return Scaffold(
                    backgroundColor: AppColors.branco,
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Dashboard",
                          style: AppStyles.textStyleForgotPassword.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 25),

                        /// Cards estilizados
                        _buildStatCard(
                          Icons.assessment_rounded,
                          "Total de Mangas",
                          data["total"],
                        ),
                        _buildStatCard(
                          Icons.assignment_turned_in_outlined,
                          "Maduras",
                          data["maduras"],
                        ),
                        _buildStatCard(
                          Icons.assistant_photo,
                          "Verdes",
                          data["verdes"],
                        ),
                        _buildStatCard(
                          Icons.question_mark_rounded,
                          "Outras",
                          data["outras"],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.azulEscuro,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 3),
              color: AppColors.azulEscuro.withValues(alpha: 0.25),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 35),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
