import 'package:dio/dio.dart';

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.data});

  final String message;
  final int? statusCode;
  final dynamic data;

  factory ApiException.fromDio(DioException error) {
    final data = error.response?.data;
    String message = 'Something went wrong. Please try again.';
    if (data is Map<String, dynamic>) {
      if (data['detail'] != null) {
        message = data['detail'].toString();
      } else if (data['non_field_errors'] is List && data['non_field_errors'].isNotEmpty) {
        message = data['non_field_errors'].first.toString();
      } else if (data.isNotEmpty) {
        final first = data.values.first;
        if (first is List && first.isNotEmpty) {
          message = first.first.toString();
        } else {
          message = first.toString();
        }
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else if (error.message != null && error.message!.isNotEmpty) {
      message = error.message!;
    }
    return ApiException(
      message: message,
      statusCode: error.response?.statusCode,
      data: data,
    );
  }

  @override
  String toString() => message;
}
