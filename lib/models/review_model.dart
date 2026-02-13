import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String equipmentId;
  final String farmerId;
  final String farmerName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.equipmentId,
    required this.farmerId,
    required this.farmerName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      equipmentId: data['equipmentId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'equipmentId': equipmentId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
