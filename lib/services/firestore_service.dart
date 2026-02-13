import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =====================
  // EQUIPMENT OPERATIONS
  // =====================

  // Add new equipment
  Future<String> addEquipment(Equipment equipment) async {
    print('FirestoreService: Adding equipment for owner ${equipment.ownerId}');
    try {
      final docRef = await _firestore
          .collection('equipment')
          .add(equipment.toFirestore())
          .timeout(const Duration(seconds: 10));
      print('FirestoreService: Equipment added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('FirestoreService: Error adding equipment: $e');
      rethrow;
    }
  }

  // Update equipment
  Future<void> updateEquipment(String id, Map<String, dynamic> data) async {
    await _firestore.collection('equipment').doc(id).update(data);
  }

  // Delete equipment
  Future<void> deleteEquipment(String id) async {
    await _firestore.collection('equipment').doc(id).delete();
  }

  // Get all available equipment
  Stream<List<Equipment>> getAvailableEquipment() {
    return _firestore
        .collection('equipment')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Equipment.fromFirestore(doc)).toList(),
        );
  }

  // Get all equipment (for admin)
  Stream<List<Equipment>> getAllEquipment() {
    return _firestore
        .collection('equipment')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Equipment.fromFirestore(doc)).toList(),
        );
  }

  // Get equipment by owner
  Stream<List<Equipment>> getEquipmentByOwner(String ownerId) {
    return _firestore
        .collection('equipment')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Equipment.fromFirestore(doc)).toList(),
        );
  }

  // Get single equipment
  Future<Equipment?> getEquipment(String id) async {
    final doc = await _firestore.collection('equipment').doc(id).get();
    if (!doc.exists) return null;
    return Equipment.fromFirestore(doc);
  }

  // =====================
  // BOOKING OPERATIONS
  // =====================

  // Create a booking
  Future<String> createBooking(Booking booking) async {
    print(
      'DEBUG: Creating booking: Farmer=${booking.farmerId}, Owner=${booking.ownerId}, Eq=${booking.equipmentId}',
    );
    try {
      final docRef = await _firestore
          .collection('bookings')
          .add(booking.toFirestore());
      print('DEBUG: Booking created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('DEBUG: Error creating booking: $e');
      rethrow;
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    String status,
    String paymentStatus, {
    String? cancellationReason,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'paymentStatus': paymentStatus,
    };
    if (cancellationReason != null) {
      data['cancellationReason'] = cancellationReason;
    }
    print('DEBUG: Updating booking $bookingId status to $status');
    try {
      await _firestore.collection('bookings').doc(bookingId).update(data);
      print('DEBUG: Booking $bookingId updated successfully');
    } catch (e) {
      print('DEBUG: Error updating booking: $e');
      rethrow;
    }
  }

  // Get bookings for a farmer
  Stream<List<Booking>> getFarmerBookings(String farmerId) {
    print('DEBUG: Fetching bookings for farmer: $farmerId');
    return _firestore
        .collection('bookings')
        .where('farmerId', isEqualTo: farmerId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Farmer bookings found: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        })
        .handleError((e) {
          print('DEBUG: Error fetching farmer bookings: $e');
          // If index is missing, this will print the link to create it.
          return <Booking>[];
        });
  }

  // Get pending bookings for an equipment owner (Requests)
  Stream<List<Booking>> getOwnerPendingBookings(String ownerId) {
    print('DEBUG: Fetching pending bookings for owner: $ownerId');
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'pending')
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Pending Owner bookings found: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        })
        .handleError((e) {
          print('DEBUG: Error querying pending owner bookings: $e');
          return <Booking>[];
        });
  }

  // Get bookings for an equipment owner
  Stream<List<Booking>> getOwnerBookings(String ownerId) {
    print('DEBUG: Fetching bookings for owner: $ownerId');
    return _firestore
        .collection('bookings')
        .where('ownerId', isEqualTo: ownerId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: Owner bookings found: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => Booking.fromFirestore(doc))
              .toList();
        })
        .handleError((e) {
          print('DEBUG: Error fetching owner bookings: $e');
          return <Booking>[];
        });
  }

  // Get all bookings (for admin)
  Stream<List<Booking>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
        );
  }

  // Get bookings for a specific equipment on a specific date
  Future<List<Booking>> getEquipmentBookingsForDate(
    String equipmentId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection('bookings')
        .where('equipmentId', isEqualTo: equipmentId)
        .where(
          'bookingDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('bookingDate', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: ['pending', 'approved'])
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  // Get bookings for equipment over a date range (for calendar view)
  Future<Map<DateTime, List<Booking>>> getEquipmentBookingsForWeek(
    String equipmentId,
    DateTime startDate,
  ) async {
    final endDate = startDate.add(const Duration(days: 7));

    final snapshot = await _firestore
        .collection('bookings')
        .where('equipmentId', isEqualTo: equipmentId)
        .where(
          'bookingDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where('bookingDate', isLessThan: Timestamp.fromDate(endDate))
        .where('status', whereIn: ['pending', 'approved'])
        .get();

    final bookings = snapshot.docs
        .map((doc) => Booking.fromFirestore(doc))
        .toList();

    final Map<DateTime, List<Booking>> grouped = {};
    for (final booking in bookings) {
      final dateKey = DateTime(
        booking.bookingDate.year,
        booking.bookingDate.month,
        booking.bookingDate.day,
      );
      grouped[dateKey] ??= [];
      grouped[dateKey]!.add(booking);
    }

    return grouped;
  }

  // =====================
  // USER OPERATIONS
  // =====================

  // Get user by ID
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Get all users (for admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Get user count by role
  Future<int> getUserCountByRole(String role) async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.length;
  }

  // Delete user (admin only)
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  // =====================
  // ADMIN ANALYTICS
  // =====================

  Future<Map<String, dynamic>> getAdminAnalytics() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final equipmentSnapshot = await _firestore.collection('equipment').get();
    final bookingsSnapshot = await _firestore.collection('bookings').get();

    int totalFarmers = 0;
    int totalOwners = 0;
    double totalRevenue = 0;
    int pendingBookings = 0;
    int approvedBookings = 0;
    int cancelledBookings = 0;

    for (final doc in usersSnapshot.docs) {
      final data = doc.data();
      if (data['role'] == 'farmer') totalFarmers++;
      if (data['role'] == 'owner') totalOwners++;
    }

    for (final doc in bookingsSnapshot.docs) {
      final data = doc.data();
      if (data['status'] == 'approved' || data['status'] == 'completed') {
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();
      }
      if (data['status'] == 'pending') pendingBookings++;
      if (data['status'] == 'approved') approvedBookings++;
      if (data['status'] == 'cancelled') cancelledBookings++;
    }

    return {
      'totalUsers': usersSnapshot.docs.length,
      'totalFarmers': totalFarmers,
      'totalOwners': totalOwners,
      'totalEquipment': equipmentSnapshot.docs.length,
      'totalBookings': bookingsSnapshot.docs.length,
      'pendingBookings': pendingBookings,
      'approvedBookings': approvedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
    };
  }

  // =====================
  // REVIEW OPERATIONS
  // =====================

  // Add a review for equipment
  Future<void> addReview(Review review) async {
    // 1. Add review to subcollection
    await _firestore
        .collection('equipment')
        .doc(review.equipmentId)
        .collection('reviews')
        .add(review.toFirestore());

    // 2. Update average rating and count on equipment
    final equipmentRef = _firestore
        .collection('equipment')
        .doc(review.equipmentId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(equipmentRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] ?? 0).toDouble();
      final currentCount = (data['reviewCount'] ?? 0).toInt();

      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;

      transaction.update(equipmentRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });
    });
  }

  // Get reviews for specific equipment
  Stream<List<Review>> getEquipmentReviews(String equipmentId) {
    return _firestore
        .collection('equipment')
        .doc(equipmentId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList(),
        );
  }
}
