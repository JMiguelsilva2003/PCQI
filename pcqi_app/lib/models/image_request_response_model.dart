class ImageRequestResponseModel {
  String? status;
  String? currentPrediction;
  String? confidence;

  ImageRequestResponseModel({
    this.status = "",
    this.currentPrediction = "",
    this.confidence = "",
  });

  factory ImageRequestResponseModel.fromJson(Map<String, dynamic> json) =>
      ImageRequestResponseModel(
        status: json['status'] ?? '',
        currentPrediction: json['current_prediction'] ?? '',
        confidence: json['confidence'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'current_prediction': currentPrediction,
      'confidence': confidence,
    };
  }
}
