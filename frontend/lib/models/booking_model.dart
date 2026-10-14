import 'package:intl/intl.dart';

class BookingModel {
  final int id;
  final int learnerId;
  final int expertId;
  final String sessionType;
  final String date;
  final String timeSlot;
  final int durationMinutes;
  final String topic;
  final String status;
  final String bookingStatus;
  final String paymentStatus;
  final String? paymentId;
  final int amount;
  final String? razorpayOrderId;
  final String? learnerName;
  final String? learnerProfileImage;
  final String? expertName;
  final String? expertProfileImage;

  BookingModel({
    required this.id,
    required this.learnerId,
    required this.expertId,
    required this.sessionType,
    required this.date,
    required this.timeSlot,
    required this.durationMinutes,
    required this.topic,
    required this.status,
    required this.bookingStatus,
    required this.paymentStatus,
    this.paymentId,
    required this.amount,
    this.razorpayOrderId,
    this.learnerName,
    this.learnerProfileImage,
    this.expertName,
    this.expertProfileImage,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final learnerObj = json['learner'] as Map<String, dynamic>?;
    final expertObj = json['expert'] as Map<String, dynamic>?;

    return BookingModel(
      id: json['id'] ?? 0,
      learnerId: json['learnerId'] ?? 0,
      expertId: json['expertId'] ?? 0,
      sessionType: json['sessionType'] ?? 'video',
      date: json['date'] ?? '',
      timeSlot: json['timeSlot'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      topic: json['topic'] ?? '',
      status: json['status'] ?? 'pending_payment',
      bookingStatus: json['bookingStatus'] ?? json['booking_status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'UNPAID',
      paymentId: json['paymentId'] ?? json['payment_id'],
      amount: json['amount'] ?? 0,
      razorpayOrderId: json['razorpayOrderId'],
      learnerName: learnerObj?['name'] ?? 'Learner',
      learnerProfileImage: learnerObj?['profileImage'],
      expertName: expertObj?['name'] ?? 'Expert',
      expertProfileImage: expertObj?['profileImage'],
    );
  }

  bool get isUpcoming {
    try {
      final sessionDateTime = _parseSessionDateTime();
      return sessionDateTime.isAfter(DateTime.now());
    } catch (_) {
      return true;
    }
  }

  bool get isPast {
    return !isUpcoming;
  }

  DateTime _parseSessionDateTime() {
    // Parse date and timeSlot into DateTime
    final parts = date.split('-');
    if (parts.length != 3) return DateTime.now().add(const Duration(days: 1));
    
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    final day = int.tryParse(parts[2]) ?? DateTime.now().day;
    
    final timeParts = timeSlot.split(':');
    final hour = timeParts.length > 0 ? int.tryParse(timeParts[0]) ?? 0 : 0;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    
    return DateTime(year, month, day, hour, minute);
  }

  BookingModel copyWith({
    int? id,
    int? learnerId,
    int? expertId,
    String? sessionType,
    String? date,
    String? timeSlot,
    int? durationMinutes,
    String? topic,
    String? status,
    String? bookingStatus,
    String? paymentStatus,
    String? paymentId,
    int? amount,
    String? razorpayOrderId,
    String? learnerName,
    String? learnerProfileImage,
    String? expertName,
    String? expertProfileImage,
  }) {
    return BookingModel(
      id: id ?? this.id,
      learnerId: learnerId ?? this.learnerId,
      expertId: expertId ?? this.expertId,
      sessionType: sessionType ?? this.sessionType,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      amount: amount ?? this.amount,
      razorpayOrderId: razorpayOrderId ?? this.razorpayOrderId,
      learnerName: learnerName ?? this.learnerName,
      learnerProfileImage: learnerProfileImage ?? this.learnerProfileImage,
      expertName: expertName ?? this.expertName,
      expertProfileImage: expertProfileImage ?? this.expertProfileImage,
    );
  }
}
