import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../providers/psalm_provider.dart';
import 'psalm_detail_screen.dart';

class PsalmLibraryScreen extends StatefulWidget {
  const PsalmLibraryScreen({super.key});

  @override
  State<PsalmLibraryScreen> createState() => _PsalmLibraryScreenState();
}

class _PsalmLibraryScreenState extends State<PsalmLibraryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psalmProv = context.watch<PsalmProvider>();
    final psalms = psalmProv.filteredPsalms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('መጽሐፈ መዝሙር ዘዳዊት (፻፶፩)'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Minimalist Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => psalmProv.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'በግዕዝ፣ በአማርኛ ወይም በቁጥር ይፈልጉ...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          psalmProv.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.goldMuted, width: 1.0),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  label: 'ሁሉም (፻፶፩)',
                  filter: PsalmFilterType.all,
                  current: psalmProv.activeFilter,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  label: 'ምልክት ያለባቸው',
                  filter: PsalmFilterType.bookmarked,
                  current: psalmProv.activeFilter,
                  icon: Icons.bookmark_rounded,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  label: 'በሂደት ላይ',
                  filter: PsalmFilterType.inProgress,
                  current: psalmProv.activeFilter,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  context,
                  label: 'የተጠናቀቁ',
                  filter: PsalmFilterType.mastered,
                  current: psalmProv.activeFilter,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Psalms List (Modern Orthodox Minimalism)
          Expanded(
            child: psalms.isEmpty
                ? Center(
                    child: Text(
                      'ምንም መዝሙር አልተገኘም',
                      style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: psalms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final psalm = psalms[index];
                      return _buildPsalmCard(context, psalm, psalmProv, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required PsalmFilterType filter,
    required PsalmFilterType current,
    IconData? icon,
  }) {
    final isSelected = filter == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.goldDark,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<PsalmProvider>().setFilter(filter),
      selectedColor: isDark ? AppColors.goldDark : AppColors.navyPrimary,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.warmCard,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textPrimaryDark : AppColors.navyPrimary),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.transparent : (isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  Widget _buildPsalmCard(
    BuildContext context,
    dynamic psalm,
    PsalmProvider prov,
    bool isDark,
  ) {
    final primaryTitle = psalm.titleGeez.isNotEmpty ? psalm.titleGeez : psalm.titleAmharic;
    final subtitle = psalm.titleAmharic != primaryTitle ? psalm.titleAmharic : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            prov.openPsalm(psalm.number);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PsalmDetailScreen(psalmNumber: psalm.number),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Quiet Fidel Numeral Badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.navySurface : AppColors.warmCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      psalm.ethiopicNumber,
                      style: const TextStyle(
                        fontFamily: 'Noto Serif Ethiopic',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.manuscriptCrimson,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Ge'ez Primary Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primaryTitle,
                        style: TextStyle(
                          fontFamily: 'Noto Serif Ethiopic',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '${psalm.versesCount} ጥቅሶች • በግዕዝ ያንብቡ',
                        style: const TextStyle(fontSize: 11, color: AppColors.goldDark),
                      ),
                    ],
                  ),
                ),

                // Bookmark Icon
                IconButton(
                  icon: Icon(
                    psalm.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 18,
                    color: psalm.isBookmarked ? AppColors.goldDark : AppColors.textMutedLight,
                  ),
                  onPressed: () => prov.toggleBookmark(psalm.number),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
