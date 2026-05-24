import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:repeater/models/schedule_entry.dart';
import 'package:repeater/screens/home/schedule_details_screen.dart';

class ScheduleListTile extends StatelessWidget {
  const ScheduleListTile({
    super.key,
    this.editable = true,
    required this.scheduleEntry,
  });

  final bool editable;
  final ScheduleEntry scheduleEntry;

  @override
  Widget build(BuildContext context) {
    final juzNumber = scheduleEntry.juzNumber;
    final maqraNumbers = scheduleEntry.maqraNumbers.join(', ');
    final reviewType = scheduleEntry.reviewType;
    final fraction =
        (scheduleEntry.fraction == null) ? '' : ' · ${scheduleEntry.fraction}';
    final text = '$reviewType | Juz $juzNumber · Maqra $maqraNumbers$fraction';
    final date =
        '${DateFormat.yMMMd().format(scheduleEntry.startDate)} · ${DateFormat.jm().format(scheduleEntry.startDate)}';

    final textStyle = TextStyle(
      decoration: scheduleEntry.isCompleted ? TextDecoration.lineThrough : null,
    );

    return ListTile(
      title: Text(text, style: textStyle),
      subtitle: Text(date, style: textStyle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (scheduleEntry.isCompleted)
            const Icon(
              Icons.check,
              color: Colors.green,
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ScheduleDetailsScreen(
              scheduleEntry: scheduleEntry,
              editable: editable,
            ),
          ),
        );
      },
    );
  }
}
