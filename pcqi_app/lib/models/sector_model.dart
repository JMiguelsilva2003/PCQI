import 'dart:convert';

import 'package:pcqi_app/models/machine_model.dart';

class SectorModel {
  String? name;
  String? description;
  int? id;
  List<MachineModel> machines;

  SectorModel({
    this.name = "",
    this.description = "",
    this.id = -2,
    this.machines = const [],
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) => SectorModel(
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    id: json['id'] ?? -2,
   machines: (json["machines"] ?? [])
    .map<MachineModel>((m) => MachineModel.fromJson(m))
    .toList()
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'id': id /*machine list yet to be implemented*/,
    };
  }
}
