class AdminMachineCommandModel {
  String? command;
  String? message;
  String? detail;

  AdminMachineCommandModel({this.command, this.message, this.detail});

  factory AdminMachineCommandModel.fromJson(Map<String, dynamic> json) =>
      AdminMachineCommandModel(
        command: json['command'] ?? '',
        message: json['message'] ?? '',
        detail: json['detail'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {'command': command, 'message': message, 'detail': detail};
  }
}
