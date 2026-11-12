import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/ethiopic_numerals.dart';
import '../../data/models/psalm_note.dart';
import '../providers/psalm_provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psalmProv = context.watch<PsalmProvider>();
    final notes = psalmProv.allNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('የግል ማስታወሻና ነጸብራቅ (Journal)'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context, psalmProv),
        backgroundColor: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
        foregroundColor: isDark ? AppColors.navyDeep : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('አዲስ ማስታወሻ'),
      ),
      body: notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 48,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ምንም የተቀመጠ የግል ማስታወሻ የለም',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'መዝሙራትን ሲያነቡ ወይም ሲያጠኑ መንፈሳዊ ማስታወሻዎን እዚህ ያስቀምጡ',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = notes[index];
                return _buildNoteCard(context, note, psalmProv, isDark);
              },
            ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    PsalmNote note,
    PsalmProvider prov,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.parchmentSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.warmCardBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : AppColors.warmCard,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'መዝሙር ${EthiopicNumerals.toEthiopic(note.psalmNumber)} (${note.psalmNumber})',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Ethiopic',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.goldMuted : AppColors.navyPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.dangerRose,
                onPressed: () {
                  if (note.id != null) {
                    prov.deleteNote(note.id!);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (note.reflection != null && note.reflection!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.04) : AppColors.warmCard,
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: AppColors.goldDark, width: 3),
                ),
              ),
              child: Text(
                'ነጸብራቅ: ${note.reflection!}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormat('MMMM d, yyyy - hh:mm a').format(note.createdAt),
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, PsalmProvider prov) {
    final psalmCtrl = TextEditingController(text: '1');
    final contentCtrl = TextEditingController();
    final reflectionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'አዲስ ማስታወሻ አስቀምጥ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: psalmCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'የመዝሙር ቁጥር (Psalm Number)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ማስታወሻ (Note)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reflectionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'መንፈሳዊ ነጸብራቅ / ጸሎት (Reflection)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final num = int.tryParse(psalmCtrl.text) ?? 1;
                    if (contentCtrl.text.trim().isNotEmpty) {
                      prov.addNote(
                        psalmNumber: num,
                        content: contentCtrl.text.trim(),
                        reflection: reflectionCtrl.text.trim().isNotEmpty ? reflectionCtrl.text.trim() : null,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('አስቀምጥ (Save)'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
