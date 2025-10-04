import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 40,
            spawnMinRadius: 15,
            spawnMinSpeed: 15,
            particleCount: 30,
            spawnMaxSpeed: 50,
            spawnOpacity: 0.5,
            baseColor: AppColors.azulBebe,
          ),
        ),
        vsync: this,
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Facilite seu sistema de produção.",
                style: AppStyles.textStyleTitulo.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulEscuro,
                    foregroundColor: AppColors.azulEscuro,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => {Navigator.pushNamed(context, '/login')},
                  child: Text(
                    "Entrar",
                    style: TextStyle(color: AppColors.branco, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulEscuro,
                    foregroundColor: AppColors.azulEscuro,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => {Navigator.pushNamed(context, '/cadastro')},
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(color: AppColors.branco, fontSize: 25),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
