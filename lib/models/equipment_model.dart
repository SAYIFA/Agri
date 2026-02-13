import 'package:cloud_firestore/cloud_firestore.dart';

class Equipment {
  final String id;
  final String name;
  final String description;
  final String village;
  final double pricePerHour;
  final String ownerId;
  final String ownerName;
  final bool isAvailable;
  final String category;
  final List<String> imageUrls;
  final List<String> availableDays;
  final DateTime? createdAt;
  final double rating;
  final int reviewCount;

  Equipment({
    required this.id,
    required this.name,
    this.description = '',
    required this.village,
    required this.pricePerHour,
    required this.ownerId,
    this.ownerName = '',
    this.isAvailable = true,
    this.category = 'General',
    this.imageUrls = const [],
    this.availableDays = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
    this.createdAt,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  String? get thumbnailUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory Equipment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Handle legacy 'imageUrl' field if 'imageUrls' is empty/missing
    List<String> images = [];
    if (data['imageUrls'] != null) {
      images = List<String>.from(data['imageUrls']);
    } else if (data['imageUrl'] != null) {
      images = [data['imageUrl']];
    }

    return Equipment(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      village: data['village'] ?? '',
      pricePerHour: (data['pricePerHour'] ?? 0).toDouble(),
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      category: data['category'] ?? 'General',
      imageUrls: images,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      availableDays: List<String>.from(
        data['availableDays'] ??
            [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ],
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'village': village,
      'pricePerHour': pricePerHour,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'isAvailable': isAvailable,
      'category': category,
      'imageUrls': imageUrls, // Store as array
      'rating': rating,
      'reviewCount': reviewCount,
      'availableDays': availableDays,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  Equipment copyWith({
    String? id,
    String? name,
    String? description,
    String? village,
    double? pricePerHour,
    String? ownerId,
    String? ownerName,
    bool? isAvailable,
    String? category,
    List<String>? imageUrls,
    List<String>? availableDays,
    DateTime? createdAt,
    double? rating,
    int? reviewCount,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      village: village ?? this.village,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      availableDays: availableDays ?? this.availableDays,
      createdAt: createdAt ?? this.createdAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
