import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get upcomingBookings => _bookings.where((b) => b.isUpcoming).toList();
  List<BookingModel> get pastBookings => _bookings.where((b) => b.isPast).toList();

  Future<void> fetchMyBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _bookingService.getMyBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(int id) async {
    try {
      await _bookingService.cancelBooking(id);
      _bookings.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> acceptBooking(int id) async {
    try {
      await _bookingService.acceptBooking(id);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: 'confirmed');
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectBooking(int id) async {
    try {
      await _bookingService.rejectBooking(id);
      final index = _bookings.indexWhere((b) => b.id == id);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: 'rejected');
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder(int bookingId) async {
    return await _bookingService.createOrder(bookingId);
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    return await _bookingService.verifyPayment(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  Future<List<dynamic>> getPaymentHistory() async {
    return await _bookingService.getPaymentHistory();
  }

  Future<List<dynamic>> getSessionHistory() async {
    return await _bookingService.getSessionHistory();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}