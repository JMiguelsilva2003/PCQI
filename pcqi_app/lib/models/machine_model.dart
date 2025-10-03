class MachineModel {
  String? name;
  int? id;
  int? ownerId;
  int? currentSpeedPpm;

  MachineModel({
    this.name = '',
    this.id = -1,
    this.ownerId = -2,
    this.currentSpeedPpm = -2,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) => MachineModel(
    name: json['name'] ?? '',
    id: json['id'] ?? -2,
    ownerId: json['owner_id'] ?? -2,
    currentSpeedPpm: json['current_speed_ppm'] ?? -2,
  );

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'owner_id': ownerId,
      'current_speed_ppm': currentSpeedPpm,
    };
  }
}
