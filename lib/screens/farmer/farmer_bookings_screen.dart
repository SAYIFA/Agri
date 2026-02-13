import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../../models/booking_model.dart';
import '../../widgets/common_widgets.dart';
import '../../models/review_model.dart';

class FarmerBookingsScreen extends StatelessWidget {
  const FarmerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    final uid = authService.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Applications'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: StreamBuilder<List<Booking>>(
          stream: firestoreService.getFarmerBookings(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allBookings = snapshot.data ?? [];
            final applications = allBookings
                .where((b) => b.status == 'pending')
                .toList();
            final history = allBookings
                .where((b) => b.status != 'pending')
                .toList();

            return TabBarView(
              children: [
                _FarmerBookingList(
                  bookings: applications,
                  emptyIcon: Icons.hourglass_empty,
                  emptyTitle: 'No Pending Applications',
                  emptySubtitle: 'Your booking requests will appear here',

                  firestoreService: firestoreService,
                ),
                _FarmerBookingList(
                  bookings: history,
                  emptyIcon: Icons.history,
                  emptyTitle: 'No Booking History',
                  emptySubtitle: 'Your past bookings will appear here',

                  firestoreService: firestoreService,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FarmerBookingList extends StatelessWidget {
  final List<Booking> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  final FirestoreService firestoreService;

  const _FarmerBookingList({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyStateWidget(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.equipmentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Owner: ${booking.ownerName}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.darkBorder, height: 1),
              const SizedBox(height: 14),
              // Details row
              Row(
                children: [
                  _DetailItem(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat(
                      'MMM d, yyyy',
                    ).format(booking.bookingDate),
                  ),
                  _DetailItem(
                    icon: Icons.timer,
                    label: 'Hours',
                    value: '${booking.hours}h',
                  ),
                  _DetailItem(
                    icon: Icons.currency_rupee,
                    label: 'Amount',
                    value: '₹${booking.totalAmount.toStringAsFixed(0)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Payment status
              Row(
                children: [
                  StatusBadge(status: booking.paymentStatus),
                  const Spacer(),
                  if (booking.isPending)
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.darkCard,
                            title: const Text('Cancel Booking?'),
                            content: const Text(
                              'The amount will be refunded to your wallet.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('No'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                child: const Text('Cancel Booking'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Refund wallet logic removed
                          // Update booking
                          await firestoreService.updateBookingStatus(
                            booking.id,
                            'cancelled',
                            'refunded',
                            cancellationReason: 'Cancelled by farmer',
                          );
                        }
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  if (booking.status == 'completed')
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showRatingDialog(context, booking, firestoreService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.star, size: 16),
                      label: const Text('Rate'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingDialog(
    BuildContext context,
    Booking booking,
    FirestoreService firestoreService,
  ) {
    // ... Existing implementation of rating dialog moved here or just kept in main class if static?
    // Since I am inside a stateless widget, I need to copy the method or access it.
    // The previous implementation had it in the main class.
    // I will redefine it here or move it.
    // To minimize code duplication I will try to call the one in main class, but main class logic was replaced.
    // So I MUST include the method body here.
    // I will copy the _showRatingDialog method here.
    final commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          title: Text('Rate ${booking.equipmentName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How was your experience?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => rating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Leave a comment...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.darkBorder),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final review = Review(
                  id: '',
                  equipmentId: booking.equipmentId,
                  farmerId: booking.farmerId,
                  farmerName: booking.farmerName,
                  rating: rating,
                  comment: commentController.text.trim(),
                  timestamp: DateTime.now(),
                );
                await firestoreService.addReview(review);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review submitted!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
