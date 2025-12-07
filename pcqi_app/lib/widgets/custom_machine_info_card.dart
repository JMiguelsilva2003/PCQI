import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';

class CustomMachineItemCard extends StatefulWidget {
  final String machineName;
  final int machineID;
  final Function(String machineId)? onDeleteMachine;
  final Function(String machineId)? onEditMachine;

  const CustomMachineItemCard({
    super.key,
    required this.machineName,
    required this.machineID,
    this.onDeleteMachine,
    this.onEditMachine,
  });

  @override
  State<CustomMachineItemCard> createState() => _CustomMachineItemCardState();
}

class _CustomMachineItemCardState extends State<CustomMachineItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      /*decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.azulEscuro, width: 1),
      ),*/
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.machineName,
                  style: AppStyles.textStyleMachineTitleCard,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ID da máquina: ${widget.machineID}',
                  style: AppStyles.textStyleMachineSecondaryTitleCard,
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () =>
                widget.onEditMachine?.call(widget.machineID.toString()),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () =>
                widget.onDeleteMachine?.call(widget.machineID.toString()),
          ),
        ],
      ),
    );
  }
}



