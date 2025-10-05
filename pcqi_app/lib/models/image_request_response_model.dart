class ImageRequestResponseModel {
  String? prediction;
  String? confidence;

  ImageRequestResponseModel({this.prediction = "", this.confidence = ""});

  factory ImageRequestResponseModel.fromJson(Map<String, dynamic> json) =>
      ImageRequestResponseModel(
        prediction: json['prediction'] ?? '',
        confidence: json['confidence'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {'prediction': prediction, 'confidence': confidence};
  }
}
