import 'dart:convert';
import '../core/exceptions/app_exceptions.dart';
import '../core/network/api_client.dart';
import '../models/booking_model.dart';
import '../utils/api_constants.dart';

class BookingService {
  final _apiClient = ApiClient();

  Future<Map<String, dynamic>> createBooking({
    required int expertId,
    required String sessionType,
    required String date,
    required String timeSlot,
    required int durationMinutes,
    required String topic,
  }) async {
    final relativeUrl = ApiConstants.createBookingUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {
        'expertId': expertId,
        'sessionType': sessionType,
        'date': date,
        'timeSlot': timeSlot,
        'durationMinutes': durationMinutes,
        'topic': topic,
      },
    );

    final responseBody = jsonDecode(response.body);
    return responseBody['data'] ?? {};
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final relativeUrl = ApiConstants.verifyPaymentUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      },
    );

    final responseBody = jsonDecode(response.body);
    return responseBody['data'] ?? {};
  }

  Future<List<BookingModel>> getMyBookings() async {
    final relativeUrl = ApiConstants.myBookingsUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    final List<dynamic> data = responseBody['data'] ?? [];
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<void> cancelBooking(int id) async {
    final relativeUrl = ApiConstants.cancelBookingUrl(id).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.patch(relativeUrl);
  }

  Future<List<dynamic>> getPaymentHistory() async {
    final relativeUrl = ApiConstants.paymentHistoryUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    return responseBody['data'] ?? [];
  }

  Future<List<dynamic>> getSessionHistory() async {
    final relativeUrl = ApiConstants.sessionHistoryUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.get(relativeUrl);

    final responseBody = jsonDecode(response.body);
    return responseBody['data'] ?? [];
  }

  Future<Map<String, dynamic>> createOrder(int bookingId) async {
    final relativeUrl = ApiConstants.createOrderUrl.replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.post(
      relativeUrl,
      body: {
        'bookingId': bookingId,
      },
    );

    final responseBody = jsonDecode(response.body);
    return responseBody['data'] ?? {};
  }

  Future<void> acceptBooking(int id) async {
    final relativeUrl = ApiConstants.acceptBookingUrl(id).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.patch(relativeUrl);
  }

  Future<void> rejectBooking(int id) async {
    final relativeUrl = ApiConstants.rejectBookingUrl(id).replaceFirst(ApiConstants.baseUrl, '');
    final response = await _apiClient.patch(relativeUrl);
  }
}