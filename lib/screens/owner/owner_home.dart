import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/common_widgets.dart';
import '../auth/login_screen.dart';
import 'owner_equipment_screen.dart';
import 'owner_bookings_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _OwnerDashboard(),
    OwnerEquipmentScreen(),
    OwnerBookingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_outlined),
              activeIcon: Icon(Icons.agriculture),
              label: 'Equipment',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerDashboard extends StatelessWidget {
  const _OwnerDashboard();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriShare · Owner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<UserModel?>(
        stream: authService.userDataStream(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userSnap.data;
          if (user == null) return const SizedBox();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Hello, ${user.name}! 🔧',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your equipment and bookings',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                // Quick stats
                StreamBuilder(
                  stream: firestoreService.getEquipmentByOwner(user.uid),
                  builder: (context, eqSnap) {
                    final equipmentCount = eqSnap.data?.length ?? 0;
                    return StreamBuilder(
                      stream: firestoreService.getOwnerBookings(user.uid),
                      builder: (context, bookSnap) {
                        final bookings = bookSnap.data ?? [];
                        final pendingCount = bookings
                            .where((b) => b.status == 'pending')
                            .length;
                        final totalEarnings = bookings
                            .where(
                              (b) =>
                                  b.status == 'approved' ||
                                  b.status == 'completed',
                            )
                            .fold<double>(
                              0,
                              (sum, b) =>
                                  sum +
                                  (b.ownerEarnings > 0
                                      ? b.ownerEarnings
                                      : b.totalAmount),
                            );

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Equipment',
                                    value: '$equipmentCount',
                                    icon: Icons.agriculture,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: StatCard(
                                    title: 'Pending',
                                    value: '$pendingCount',
                                    icon: Icons.schedule,
                                    color: AppColors.warning,
                                    subtitle: 'Requests',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            StatCard(
                              title: 'Total Earnings',
                              value: '₹${totalEarnings.toStringAsFixed(0)}',
                              icon: Icons.trending_up,
                              color: AppColors.success,
                              subtitle: 'From bookings',
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Recent pending bookings
                Text(
                  'Pending Requests',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                StreamBuilder(
                  stream: firestoreService.getOwnerBookings(user.uid),
                  builder: (context, bookSnap) {
                    final bookings = (bookSnap.data ?? [])
                        .where((b) => b.status == 'pending')
                        .take(3)
                        .toList();

                    if (bookings.isEmpty) {
                      return const GlassCard(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                  size: 36,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'All caught up!',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No pending booking requests',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: bookings.map((booking) {
                        return GlassCard(
                          highlighted: true,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.schedule,
                                  color: AppColors.warning,
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
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${booking.equipmentName} · ${booking.hours}h',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${booking.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (booking.commissionAmount > 0)
                                    Text(
                                      'Earn: ₹${booking.ownerEarnings.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
