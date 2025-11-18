class AdminMachineCommandModel {
  String? command;
  String? message;

  AdminMachineCommandModel({this.command, this.message});

  factory AdminMachineCommandModel.fromJson(Map<String, dynamic> json) =>
      AdminMachineCommandModel(
        command: json['command'] ?? '',
        message: json['message'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {'command': command, 'message': message};
  }
}
