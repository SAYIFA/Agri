import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/equipment_model.dart';
import '../../widgets/common_widgets.dart';

class OwnerEquipmentScreen extends StatefulWidget {
  const OwnerEquipmentScreen({super.key});

  @override
  State<OwnerEquipmentScreen> createState() => _OwnerEquipmentScreenState();
}

class _OwnerEquipmentScreenState extends State<OwnerEquipmentScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  void _showAddEditDialog({Equipment? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final villageController = TextEditingController(
      text: existing?.village ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.pricePerHour.toStringAsFixed(0) ?? '',
    );
    String category = existing?.category ?? 'General';
    bool isAvailable = existing?.isAvailable ?? true;
    List<String> availableDays = List<String>.from(
      existing?.availableDays ??
          [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ],
    );

    // Image state removed
    bool isSaving = false;

    final categories = [
      'General',
      'Tractor',
      'Harvester',
      'Plough',
      'Seeder',
      'Sprayer',
      'Irrigation',
    ];
    final allDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.darkBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    existing != null ? 'Edit Equipment' : 'Add Equipment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),

                  // Image Section Removed
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Equipment Name',
                      hintText: 'e.g., John Deere Tractor',
                      prefixIcon: Icon(Icons.agriculture),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Describe the equipment',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: villageController,
                    decoration: const InputDecoration(
                      labelText: 'Village/Location',
                      hintText: 'Equipment location',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price Per Hour (₹)',
                      hintText: 'e.g., 500',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Category dropdown
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    dropdownColor: AppColors.darkElevated,
                    items: categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => category = val ?? 'General');
                    },
                  ),
                  const SizedBox(height: 14),
                  // Available days
                  const Text(
                    'Available Days',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: allDays.map((day) {
                      final isSelected = availableDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              availableDays.add(day);
                            } else {
                              availableDays.remove(day);
                            }
                          });
                        },
                        backgroundColor: AppColors.darkElevated,
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkBorder,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Availability toggle
                  SwitchListTile(
                    title: const Text('Available for Booking'),
                    subtitle: Text(
                      isAvailable ? 'Listed publicly' : 'Hidden from farmers',
                      style: TextStyle(
                        color: isAvailable
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    value: isAvailable,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setDialogState(() => isAvailable = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final village = villageController.text.trim();
                            final price =
                                double.tryParse(priceController.text) ?? 0;

                            if (name.isEmpty || village.isEmpty || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please fill in all required fields',
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setDialogState(() => isSaving = true);

                            try {
                              print('DEBUG: Starting equipment save...');
                              final user = await _authService
                                  .getCurrentUserData();

                              if (user == null) {
                                print('DEBUG: User is null, cannot save.');
                                if (ctx.mounted) {
                                  setDialogState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'User session not found. Please login again.',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                                return;
                              }
                              print('DEBUG: User authenticated: ${user.uid}');

                              if (user.role != 'owner') {
                                print(
                                  'DEBUG: User is not an owner: ${user.role}',
                                );
                                if (ctx.mounted) {
                                  setDialogState(() => isSaving = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Only owners can add equipment.',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                                return;
                              }

                              // Upload new images logic removed
                              List<String> finalImageUrls = [];
                              if (existing != null) {
                                finalImageUrls = existing.imageUrls;
                              }

                              if (existing != null) {
                                print(
                                  'DEBUG: Updating existing equipment ${existing.id}...',
                                );
                                await _firestoreService
                                    .updateEquipment(existing.id, {
                                      'name': name,
                                      'description': descController.text.trim(),
                                      'village': village,
                                      'pricePerHour': price,
                                      'category': category,
                                      'isAvailable': isAvailable,
                                      'availableDays': availableDays,
                                      'imageUrls': finalImageUrls,
                                    });
                                print('DEBUG: Update successful.');
                              } else {
                                print('DEBUG: Creating new equipment...');
                                final equipment = Equipment(
                                  id: '', // ID generated by Firestore
                                  name: name,
                                  description: descController.text.trim(),
                                  village: village,
                                  pricePerHour: price,
                                  ownerId: user.uid,
                                  ownerName: user.name,
                                  isAvailable: isAvailable,
                                  category: category,
                                  availableDays: availableDays,
                                  imageUrls: finalImageUrls,
                                );
                                final newId = await _firestoreService
                                    .addEquipment(equipment);
                                print(
                                  'DEBUG: Equipment created with ID: $newId',
                                );
                              }

                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Equipment saved successfully!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            } catch (e, stack) {
                              print('DEBUG: Error saving equipment: $e');
                              print(stack);
                              if (ctx.mounted) {
                                setDialogState(() => isSaving = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            existing != null
                                ? 'Update Equipment'
                                : 'Add Equipment',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Equipment'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Equipment'),
      ),
      body: StreamBuilder<List<Equipment>>(
        stream: _firestoreService.getEquipmentByOwner(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final equipment = snapshot.data ?? [];

          if (equipment.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.agriculture,
              title: 'No Equipment Listed',
              subtitle: 'Add your first equipment to start receiving bookings',
              action: ElevatedButton.icon(
                onPressed: () => _showAddEditDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Equipment'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: equipment.length,
            itemBuilder: (context, index) {
              final eq = equipment[index];
              return GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            image: eq.thumbnailUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(eq.thumbnailUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: eq.thumbnailUrl == null
                              ? const Icon(
                                  Icons.agriculture,
                                  color: AppColors.primary,
                                  size: 26,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eq.name,
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
                                    Icons.location_on,
                                    size: 13,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    eq.village,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkElevated,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      eq.category,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${eq.pricePerHour.toStringAsFixed(0)}/hr',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusBadge(
                              status: eq.isAvailable
                                  ? 'Available'
                                  : 'Unavailable',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.darkBorder, height: 1),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddEditDialog(existing: eq),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.info,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.darkCard,
                                title: const Text('Delete Equipment?'),
                                content: Text(
                                  'Are you sure you want to delete "${eq.name}"?',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await _firestoreService.deleteEquipment(eq.id);
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
