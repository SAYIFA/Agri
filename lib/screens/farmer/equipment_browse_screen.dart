import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import '../../models/equipment_model.dart';
import '../../widgets/common_widgets.dart';
import 'equipment_detail_screen.dart';

class EquipmentBrowseScreen extends StatefulWidget {
  const EquipmentBrowseScreen({super.key});

  @override
  State<EquipmentBrowseScreen> createState() => _EquipmentBrowseScreenState();
}

class _EquipmentBrowseScreenState extends State<EquipmentBrowseScreen> {
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Tractor',
    'Harvester',
    'Plough',
    'Seeder',
    'Sprayer',
    'Irrigation',
    'General',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Equipment'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search equipment or village...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          // Category chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: AppColors.darkElevated,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.darkBorder,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Equipment list
          Expanded(
            child: StreamBuilder<List<Equipment>>(
              stream: _firestoreService.getAvailableEquipment(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var equipment = snapshot.data ?? [];

                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  equipment = equipment.where((e) {
                    final query = _searchQuery.toLowerCase();
                    return e.name.toLowerCase().contains(query) ||
                        e.village.toLowerCase().contains(query) ||
                        e.category.toLowerCase().contains(query);
                  }).toList();
                }

                // Filter by category
                if (_selectedCategory != 'All') {
                  equipment = equipment
                      .where((e) => e.category == _selectedCategory)
                      .toList();
                }

                if (equipment.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.agriculture,
                    title: 'No Equipment Found',
                    subtitle: 'Try adjusting your search or category filter',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: equipment.length,
                  itemBuilder: (context, index) {
                    final item = equipment[index];
                    return _EquipmentCard(
                      equipment: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EquipmentDetailScreen(equipment: item),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final VoidCallback onTap;

  const _EquipmentCard({required this.equipment, required this.onTap});

  IconData get _categoryIcon {
    switch (equipment.category.toLowerCase()) {
      case 'tractor':
        return Icons.agriculture;
      case 'harvester':
        return Icons.content_cut;
      case 'plough':
        return Icons.landscape;
      case 'seeder':
        return Icons.grass;
      case 'sprayer':
        return Icons.water_drop;
      case 'irrigation':
        return Icons.water;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          // Equipment icon
          Container(
            width: 80, // Increased size
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              image: equipment.thumbnailUrl != null
                  ? DecorationImage(
                      image: NetworkImage(equipment.thumbnailUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: equipment.thumbnailUrl == null
                ? Icon(_categoryIcon, color: AppColors.primary, size: 36)
                : null,
          ),
          const SizedBox(width: 14),
          // Equipment info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
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
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      equipment.village,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        equipment.category,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${equipment.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '(${equipment.reviewCount})',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 12,
                      color: AppColors.darkBorder,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'by ${equipment.ownerName}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${equipment.pricePerHour.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                '/hour',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
