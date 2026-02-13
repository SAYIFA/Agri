import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

import '../../models/booking_model.dart';
import '../../widgets/common_widgets.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    final uid = authService.currentUser?.uid ?? '';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Requests'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Others'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Pending (Optimized Query)
            _BookingStreamList(
              stream: firestoreService.getOwnerPendingBookings(uid),
              emptyIcon: Icons.inbox,
              emptyTitle: 'No Pending Requests',
              emptySubtitle: 'New booking requests will appear here',
              showActions: true,
              firestoreService: firestoreService,
            ),
            // Tab 2: Approved (Filter client-side for now)
            _BookingStreamList(
              stream: firestoreService.getOwnerBookings(uid),
              filter: (b) => b.status == 'approved',
              emptyIcon: Icons.check_circle_outline,
              emptyTitle: 'No Approved Bookings',
              emptySubtitle: 'Approved bookings will appear here',
              showActions: true,
              firestoreService: firestoreService,
            ),
            // Tab 3: Others (Filter client-side)
            _BookingStreamList(
              stream: firestoreService.getOwnerBookings(uid),
              filter: (b) => b.status != 'pending' && b.status != 'approved',
              emptyIcon: Icons.history,
              emptyTitle: 'No Past Bookings',
              emptySubtitle: 'Cancelled and completed bookings appear here',
              showActions: false,
              firestoreService: firestoreService,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingStreamList extends StatelessWidget {
  final Stream<List<Booking>> stream;
  final bool Function(Booking)? filter;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final bool showActions;
  final FirestoreService firestoreService;

  const _BookingStreamList({
    required this.stream,
    this.filter,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.showActions,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var bookings = snapshot.data ?? [];
        if (filter != null) {
          bookings = bookings.where(filter!).toList();
        }

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
              highlighted: showActions && booking.status == 'pending',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.info,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.farmerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              booking.equipmentName,
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
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today,
                        text: DateFormat('MMM d').format(booking.bookingDate),
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(icon: Icons.timer, text: '${booking.hours}h'),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.currency_rupee,
                        text: '₹${booking.totalAmount.toStringAsFixed(0)}',
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      if (booking.ownerEarnings > 0)
                        _InfoChip(
                          icon: Icons.account_balance_wallet,
                          text:
                              'Earn: ₹${booking.ownerEarnings.toStringAsFixed(0)}',
                          color: AppColors.success,
                        ),
                    ],
                  ),
                  if (showActions) ...[
                    const SizedBox(height: 14),
                    if (booking.status == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await firestoreService.updateBookingStatus(
                                  booking.id,
                                  'cancelled',
                                  'refunded',
                                  cancellationReason: 'Rejected by owner',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await firestoreService.updateBookingStatus(
                                  booking.id,
                                  'approved',
                                  'paid',
                                );
                              },
                              child: const Text('Approve'),
                            ),
                          ),
                        ],
                      ),
                    if (booking.status == 'approved')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await firestoreService.updateBookingStatus(
                              booking.id,
                              'completed',
                              'paid',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Mark as Completed'),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _InfoChip({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
