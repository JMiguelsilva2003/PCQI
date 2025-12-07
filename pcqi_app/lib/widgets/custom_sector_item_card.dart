import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:pcqi_app/config/app_colors.dart';
import 'package:pcqi_app/config/app_styles.dart';
import 'package:pcqi_app/models/sector_model.dart';
import 'package:pcqi_app/widgets/custom_machine_info_card.dart';

class CustomSectorItemCard extends StatefulWidget {
  final SectorModel sector;
  final Function(String machineId)? onDeleteMachine;
  final Function(String machineId)? onEditMachine;
  final Function(String machineName)? onCreateMachine;

  const CustomSectorItemCard({
    super.key,
    required this.sector,
    this.onDeleteMachine,
    this.onCreateMachine,
    this.onEditMachine,
  });

  @override
  State<CustomSectorItemCard> createState() => _CustomSectorItemCardState();
}

class _CustomSectorItemCardState extends State<CustomSectorItemCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.azulEscuro, width: 2),
      ),
      child: ExpandablePanel(
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sector.name!,
              style: AppStyles.textStyleSectorTitleCard,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'ID do setor: ${widget.sector.id}',
              style: AppStyles.textStyleSectorSecondaryTitleCard,
            ),
          ],
        ),
        collapsed: SizedBox(width: 1),
        expanded: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  widget.onCreateMachine?.call(widget.sector.id.toString());
                },
                style: AppStyles.buttonStyleElevatedButton,
                child: Text(
                  "Adicionar máquina",
                  style: AppStyles.textStyleElevatedButton,
                ),
              ),
            ),

            const SizedBox(height: 8),

            if (widget.sector.machines.isEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Divider(),
                  Text(
                    'Não há máquinas neste setor',
                    style: AppStyles.textStyleSectorSubtextTitleCard,
                  ),
                ],
              )
            else
              ...widget.sector.machines.map((machine) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      const Divider(),
                      CustomMachineItemCard(
                        machineName: machine.name!,
                        machineID: machine.id!,
                        onEditMachine: widget.onEditMachine,
                        onDeleteMachine: widget.onDeleteMachine,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}


