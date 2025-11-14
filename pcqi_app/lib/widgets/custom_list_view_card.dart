import 'package:flutter/material.dart';
import 'package:pcqi_app/models/machine_model.dart';

class CustomSectorViewCard extends StatefulWidget {
  final String name;
  final String description;
  final List<MachineModel> machines;
  final Function(String machineId)? onDeleteMachine;
  final Function(String machineName)? onCreateMachine;

  const CustomSectorViewCard({
    super.key,
    required this.name,
    required this.description,
    required this.machines,
    this.onDeleteMachine,
    this.onCreateMachine,
  });

  @override
  State<CustomSectorViewCard> createState() => _CustomSectorViewCardState();
}

class _CustomSectorViewCardState extends State<CustomSectorViewCard> {
  bool expanded = false;

  void _openCreateMachineDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Adicionar máquina"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nome da máquina"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              Navigator.of(dialogCtx).pop(); // FECHA O DIALOG
              widget.onCreateMachine?.call(name); // ENVIA O NOME PARA A TELA DE SETORES
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.name, style: const TextStyle(fontSize: 18)),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _openCreateMachineDialog, 
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("Adicionar máquina"),
                    ),
                    IconButton(
                      icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(() => expanded = !expanded),
                    ),
                  ],
                ),
              ],
            ),

            if (expanded)
              Column(
                children: widget.machines.map((machine) {
                  return ListTile(
                    title: Text(machine.name ?? "máquina sem nome"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          widget.onDeleteMachine?.call(machine.id.toString()),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
