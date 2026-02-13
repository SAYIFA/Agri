import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String equipmentId;
  final String equipmentName;
  final String farmerId;
  final String farmerName;
  final String ownerId;
  final String ownerName;
  final DateTime bookingDate;
  final int hours;
  final double totalAmount;
  final double commissionAmount; // Platform fee
  final double ownerEarnings; // Amount for owner
  final String status; // 'pending', 'approved', 'cancelled', 'completed'
  final String paymentStatus; // 'paid', 'refunded', 'failed'
  final DateTime? createdAt;
  final String? cancellationReason;
  final String? paymentId;
  final String? paymentProvider;
  final String? refundId;

  Booking({
    required this.id,
    required this.equipmentId,
    this.equipmentName = '',
    required this.farmerId,
    this.farmerName = '',
    required this.ownerId,
    this.ownerName = '',
    required this.bookingDate,
    required this.hours,
    required this.totalAmount,
    this.commissionAmount = 0.0,
    this.ownerEarnings = 0.0,
    this.status = 'pending',
    this.paymentStatus = 'paid',
    this.createdAt,
    this.cancellationReason,
    this.paymentId,
    this.paymentProvider,
    this.refundId,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      equipmentId: data['equipmentId'] ?? '',
      equipmentName: data['equipmentName'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      hours: data['hours'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      commissionAmount: (data['commissionAmount'] ?? 0).toDouble(),
      ownerEarnings: (data['ownerEarnings'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'paid',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      cancellationReason: data['cancellationReason'],
      paymentId: data['paymentId'],
      paymentProvider: data['paymentProvider'],
      refundId: data['refundId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'equipmentId': equipmentId,
      'equipmentName': equipmentName,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'hours': hours,
      'totalAmount': totalAmount,
      'commissionAmount': commissionAmount,
      'ownerEarnings': ownerEarnings,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'cancellationReason': cancellationReason,
      'paymentId': paymentId,
      'paymentProvider': paymentProvider,
      'refundId': refundId,
    };
  }

  Booking copyWith({
    String? id,
    String? equipmentId,
    String? equipmentName,
    String? farmerId,
    String? farmerName,
    String? ownerId,
    String? ownerName,
    DateTime? bookingDate,
    int? hours,
    double? totalAmount,
    double? commissionAmount,
    double? ownerEarnings,
    String? status,
    String? paymentStatus,
    DateTime? createdAt,
    String? cancellationReason,
    String? paymentId,
    String? paymentProvider,
    String? refundId,
  }) {
    return Booking(
      id: id ?? this.id,
      equipmentId: equipmentId ?? this.equipmentId,
      equipmentName: equipmentName ?? this.equipmentName,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      bookingDate: bookingDate ?? this.bookingDate,
      hours: hours ?? this.hours,
      totalAmount: totalAmount ?? this.totalAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      ownerEarnings: ownerEarnings ?? this.ownerEarnings,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      paymentId: paymentId ?? this.paymentId,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      refundId: refundId ?? this.refundId,
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
}
