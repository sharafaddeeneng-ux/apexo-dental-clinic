import 'package:apexo/features/appointments/appointment_model.dart';
import 'package:apexo/features/appointments/tooth_clinical_record.dart';
import 'package:apexo/services/localization/locale.dart';
import 'package:apexo/features/settings/settings_stores.dart' show DF;
import 'package:fluent_ui/fluent_ui.dart';

/// Edits the dated diagnosis/treatment entries belonging to one tooth in one visit.
class ToothClinicalRecordsEditor extends StatefulWidget {
  const ToothClinicalRecordsEditor({
    super.key,
    required this.appointment,
    required this.tooth,
    this.onChanged,
  });

  final Appointment appointment;
  final String tooth;
  final VoidCallback? onChanged;

  @override
  State<ToothClinicalRecordsEditor> createState() =>
      _ToothClinicalRecordsEditorState();
}

class _ToothClinicalRecordsEditorState
    extends State<ToothClinicalRecordsEditor> {
  late final TextEditingController _diagnosis =
      TextEditingController();
  late final TextEditingController _treatment =
      TextEditingController();
  late final TextEditingController _notes = TextEditingController();

  List<ToothClinicalRecord> get _records =>
      [...?widget.appointment.toothClinicalRecords[widget.tooth]]
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

  bool get _hasInput =>
      _diagnosis.text.trim().isNotEmpty ||
      _treatment.text.trim().isNotEmpty ||
      _notes.text.trim().isNotEmpty;

  @override
  void dispose() {
    _diagnosis.dispose();
    _treatment.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _addRecord() {
    if (!_hasInput) return;
    widget.appointment.addToothClinicalRecord(
      tooth: widget.tooth,
      diagnosis: _diagnosis.text,
      treatment: _treatment.text,
      notes: _notes.text,
    );
    _diagnosis.clear();
    _treatment.clear();
    _notes.clear();
    setState(() {});
    widget.onChanged?.call();
  }

  void _deleteRecord(String id) {
    if (!widget.appointment.removeToothClinicalRecord(widget.tooth, id)) {
      return;
    }
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final records = _records;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(FluentIcons.health, size: 15, color: theme.accentColor),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  txt('toothClinicalRecords'),
                  style: theme.typography.bodyStrong,
                ),
              ),
              Text(
                '${records.length}',
                style: theme.typography.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                txt('noToothClinicalRecords'),
                style: theme.typography.caption,
                textAlign: TextAlign.center,
              ),
            )
          else
            ...records.map((record) => _recordTile(context, record)),
          const SizedBox(height: 8),
          InfoLabel(
            label: txt('diagnosis'),
            child: TextBox(
              controller: _diagnosis,
              maxLines: 2,
              placeholder: txt('diagnosis'),
            ),
          ),
          const SizedBox(height: 6),
          InfoLabel(
            label: txt('treatmentPerformed'),
            child: TextBox(
              controller: _treatment,
              maxLines: 2,
              placeholder: txt('treatmentPerformed'),
            ),
          ),
          const SizedBox(height: 6),
          InfoLabel(
            label: txt('notes'),
            child: TextBox(
              controller: _notes,
              maxLines: 2,
              placeholder: txt('toothRecordNotes'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(
              onPressed: _hasInput ? _addRecord : null,
              child: ButtonContent(FluentIcons.add, txt('addToothRecord')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordTile(BuildContext context, ToothClinicalRecord record) {
    final theme = FluentTheme.of(context);
    final details = <String>[
      if (record.diagnosis.trim().isNotEmpty)
        '${txt('diagnosis')}: ${record.diagnosis}',
      if (record.treatment.trim().isNotEmpty)
        '${txt('treatmentPerformed')}: ${record.treatment}',
      if (record.notes.trim().isNotEmpty)
        '${txt('notes')}: ${record.notes}',
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsetsDirectional.fromSTEB(9, 7, 5, 7),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DF.full(record.recordedAt.toLocal()),
                  style: theme.typography.caption?.copyWith(
                    color: theme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                for (final detail in details)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(detail, style: theme.typography.caption),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(FluentIcons.delete, size: 13),
            onPressed: () => _deleteRecord(record.id),
          ),
        ],
      ),
    );
  }
}
