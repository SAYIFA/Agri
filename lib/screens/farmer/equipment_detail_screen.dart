import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../../models/equipment_model.dart';
import '../../models/booking_model.dart';
import '../../models/review_model.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets.dart';

class EquipmentDetailScreen extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetailScreen({super.key, required this.equipment});

  @override
  State<EquipmentDetailScreen> createState() => _EquipmentDetailScreenState();
}

class _EquipmentDetailScreenState extends State<EquipmentDetailScreen> {
  final _firestoreService = FirestoreService();

  final _authService = AuthService();

  DateTime _selectedDate = DateTime.now();
  int _selectedHours = 1;
  bool _isBooking = false;
  Map<DateTime, List<Booking>> _weekBookings = {};

  @override
  void initState() {
    super.initState();
    _loadWeekBookings();
  }

  Future<void> _loadWeekBookings() async {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    final bookings = await _firestoreService.getEquipmentBookingsForWeek(
      widget.equipment.id,
      startOfWeek,
    );
    setState(() => _weekBookings = bookings);
  }

  double get _totalAmount => widget.equipment.pricePerHour * _selectedHours;

  bool _isDayAvailable(DateTime date) {
    final dayName = DateFormat('EEEE').format(date);
    return widget.equipment.availableDays.contains(dayName);
  }

  Future<void> _bookEquipment() async {
    final user = await _authService.getCurrentUserData();
    if (user == null) return;

    setState(() => _isBooking = true);

    try {
      // 1. Process Payment (Simulated/Mocked)
      // Since PaymentService has been removed, we simulate a successful payment here.
      // In a real app, this would be where you navigate to a payment gateway or logic.
      final paymentId = 'MOCK_PAYMENT_${DateTime.now().millisecondsSinceEpoch}';

      final commissionAmount = _totalAmount * 0.10;
      final ownerEarnings = _totalAmount - commissionAmount;

      // 2. Create Booking
      final booking = Booking(
        id: '',
        equipmentId: widget.equipment.id,
        equipmentName: widget.equipment.name,
        farmerId: user.uid,
        farmerName: user.name,
        ownerId: widget.equipment.ownerId,
        ownerName: widget.equipment.ownerName,
        bookingDate: _selectedDate,
        hours: _selectedHours,
        totalAmount: _totalAmount,
        commissionAmount: commissionAmount,
        ownerEarnings: ownerEarnings,
        status: 'pending',
        paymentStatus: 'paid', // Assuming payment is "done" or skipping it
        paymentId: paymentId,
        paymentProvider: 'Mock',
      );

      await _firestoreService.createBooking(booking);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking Confirmed! Payment ID: $paymentId'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eq = widget.equipment;

    return Scaffold(
      appBar: AppBar(title: Text(eq.name)),
      body: LoadingOverlay(
        isLoading: _isBooking,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Equipment header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eq.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                eq.village,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '₹${eq.pricePerHour.toStringAsFixed(0)}/hour',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${eq.rating.toStringAsFixed(1)} (${eq.reviewCount})',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Images Carousel
              if (eq.imageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: eq.imageUrls.length,
                    padEnds: false,
                    controller: PageController(viewportFraction: 0.9),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(eq.imageUrls[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
              // Description
              if (eq.description.isNotEmpty) ...[
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Text(
                    eq.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Owner info
              Text(
                'Equipment Owner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FutureBuilder<UserModel?>(
                future: _firestoreService.getUser(eq.ownerId),
                builder: (context, snapshot) {
                  // While loading or if data missing, show basic info we already have
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GlassCard(
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Loading owner info...',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    );
                  }

                  final owner = snapshot.data;
                  final ownerName = owner?.name ?? eq.ownerName;
                  final ownerPhone = owner?.phone ?? 'Contact Unavailable';

                  return GlassCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.info,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ownerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    ownerPhone,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (owner?.phone != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.call,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Reviews
              if (eq.reviewCount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        // View all reviews
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<Review>>(
                  stream: _firestoreService.getEquipmentReviews(eq.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    // Show top 3 reviews
                    final reviews = snapshot.data!.take(3).toList();
                    return Column(
                      children: reviews.map((review) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.farmerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 14,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        review.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                review.comment,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'MMM d, yyyy',
                                ).format(review.timestamp),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Weekly availability calendar
              Text(
                '7-Day Availability',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildWeekCalendar(),
              const SizedBox(height: 20),
              // Booking section
              Text(
                'Book Equipment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              GlassCard(
                highlighted: true,
                child: Column(
                  children: [
                    // Date picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppColors.accent,
                        ),
                      ),
                      title: const Text(
                        'Select Date',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      subtitle: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted,
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                          _loadWeekBookings();
                        }
                      },
                    ),
                    const Divider(color: AppColors.darkBorder),
                    // Hours selector
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.timer,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Hours',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        IconButton(
                          onPressed: _selectedHours > 1
                              ? () => setState(() => _selectedHours--)
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.darkElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const Icon(Icons.remove, size: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_selectedHours',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _selectedHours < 12
                              ? () => setState(() => _selectedHours++)
                              : null,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.darkElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const Icon(Icons.add, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Total amount
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isDayAvailable(_selectedDate)
                            ? _bookEquipment
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppColors.darkElevated,
                        ),
                        child: Text(
                          _isDayAvailable(_selectedDate)
                              ? 'Book'
                              : 'Not Available on This Day',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final day = startOfWeek.add(Duration(days: index));
          final dayName = DateFormat('EEE').format(day);
          final dayNum = DateFormat('d').format(day);
          final isAvailable = _isDayAvailable(day);
          final isSelected =
              day.day == _selectedDate.day && day.month == _selectedDate.month;
          final dayKey = DateTime(day.year, day.month, day.day);
          final bookingsOnDay = _weekBookings[dayKey] ?? [];
          final hasBookings = bookingsOnDay.isNotEmpty;

          return Expanded(
            child: GestureDetector(
              onTap:
                  isAvailable &&
                      day.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      )
                  ? () {
                      setState(() => _selectedDate = day);
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isAvailable
                      ? Colors.transparent
                      : AppColors.darkElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasBookings)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      )
                    else if (!isAvailable)
                      const Icon(
                        Icons.close,
                        size: 12,
                        color: AppColors.textMuted,
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
