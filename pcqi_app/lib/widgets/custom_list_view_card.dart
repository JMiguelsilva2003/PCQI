import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/machine_model.dart';

class CustomSectorViewCard extends StatelessWidget {
  final String name;
  final String description;
  final List<MachineModel> machines;
  final Function(String machineId)? onDeleteMachine;
  final String? deletingMachineId; // <-- para controlar loading

  const CustomSectorViewCard({
    super.key,
    required this.name,
    required this.description,
    required this.machines,
    this.onDeleteMachine,
    this.deletingMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Card(
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.branco,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 2, color: AppColors.azulEscuro),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppStyles.textStyleCustomListViewCard),
              Text(description, style: AppStyles.textStyleCustomListViewCard),

              const SizedBox(height: 12),

              ...machines.map(
                (machine) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(machine.name ?? "Máquina sem nome"),
                  trailing: deletingMachineId == machine.id?.toString()
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Excluir máquina"),
                                content: Text(
                                  "Tem certeza que deseja excluir a máquina \"${machine.name}\"?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      final id =
                                          machine.id?.toString() ?? "";

                                      if (id.isNotEmpty) {
                                        onDeleteMachine?.call(id);
                                      }
                                    },
                                    child: const Text("Excluir"),
                                  ),
                                ],
                              ),
                            );
                          },
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
