class MachineModel {
  String? name;
  int? id;
  int? sectorId;
  int? creatorId;

  MachineModel({
    this.name = '',
    this.id = -1,
    this.sectorId = -2,
    this.creatorId = -2,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
    name: json['name'] ?? '',
    id: json['id'] ?? -2,
    sectorId: json['sector_id'] ?? -2,
    creatorId: json['creator_id'] ?? -2,
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'sector_id': sectorId,
      'creator_id': creatorId,
    };
  }
}
