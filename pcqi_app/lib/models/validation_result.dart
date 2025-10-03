class ValidationResult {
  String? message;

  bool shouldThrowValidationError = true;
  // true = field is not valid; false, field is valid

  ValidationResult({
    required this.message,
    this.shouldThrowValidationError = true,
  });
}
