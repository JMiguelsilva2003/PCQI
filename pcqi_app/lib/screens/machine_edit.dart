import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';

class MachineEdit extends StatefulWidget {
  const MachineEdit({super.key});

  @override
  State<MachineEdit> createState() => _MachineEditState();
}

class _MachineEditState extends State<MachineEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Editar máquina"),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cinzaClaro,
              borderRadius: BorderRadius.circular(10),
            ),

            child: ExpandablePanel(
              header: Center(
                child: ListTile(
                  title: Text(
                    "Opções da máquina",
                    textAlign: TextAlign.center,
                    style: AppStyles.textStyleOptionsTab,
                  ),
                ),
              ),
              collapsed: SizedBox(width: 1),
              expanded: Text("testee"),
            ),
          ),
        ],
      ),
    );
  }
}
