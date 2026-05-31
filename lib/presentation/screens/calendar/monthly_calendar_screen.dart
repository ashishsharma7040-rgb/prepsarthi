// lib/presentation/screens/calendar/monthly_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/local/isar/isar_service.dart';
import '../../../data/local/isar/schemas/schemas.dart';

// Provider that loads plan entries for a given month range
final _calendarEntriesProvider =
    FutureProvider.family<Map<DateTime, List<PlanEntrySchema>>, DateTimeRange>(
  (ref, range) async {
    final db = IsarService.db;
    final entries = await db.planEntrySchemas
        .filter()
        .plannedDateGreaterThan(range.start.subtract(const Duration(days: 1)))
        .and()
        .plannedDateLessThan(range.end.add(const Duration(days: 1)))
        .findAll();

    final map = <DateTime, List<PlanEntrySchema>>{};
    for (final e in entries) {
      final key =
          DateTime(e.plannedDate.year, e.plannedDate.month, e.plannedDate.day);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  },
);

// Provider for study logs grouped by date
final _calendarLogsProvider =
    FutureProvider.family<Map<DateTime, List<StudyLogSchema>>, DateTimeRange>(
  (ref, range) async {
    final db = IsarService.db;
    final logs = await db.studyLogSchemas
        .filter()
        .timestampGreaterThan(range.start)
        .and()
        .timestampLessThan(range.end)
        .findAll();

    final map = <DateTime, List<StudyLogSchema>>{};
    for (final l in logs) {
      final key =
          DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      map.putIfAbsent(key, () => []).add(l);
    }
    return map;
  },
);

class MonthlyCalendarScreen extends ConsumerStatefulWidget {
  const MonthlyCalendarScreen({super.key});

  @override
  ConsumerState<MonthlyCalendarScreen> createState() =>
      _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState
    extends ConsumerState<MonthlyCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  DateTimeRange get _visibleRange => DateTimeRange(
        start: DateTime(_focusedDay.year, _focusedDay.month - 1, 1),
        end: DateTime(_focusedDay.year, _focusedDay.month + 2, 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? DarkColors.primary : LightColors.primary;

    final planAsync = ref.watch(_calendarEntriesProvider(_visibleRange));
    final logsAsync = ref.watch(_calendarLogsProvider(_visibleRange));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calendar', style: theme.textTheme.headlineLarge),
                  Row(
                    children: [
                      _FormatToggle(
                        current: _format,
                        onChanged: (f) => setState(() => _format = f),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Calendar ───────────────────────────────────────────────────
            planAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (planMap) => logsAsync.when(
                loading: () => _buildCalendar(
                    context, planMap, {}, accent, isDark),
                error: (_, __) => _buildCalendar(
                    context, planMap, {}, accent, isDark),
                data: (logsMap) => _buildCalendar(
                    context, planMap, logsMap, accent, isDark),
              ),
            ),

            // ── Selected Day Detail ────────────────────────────────────────
            if (_selectedDay != null)
              Expanded(
                child: planAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (planMap) => logsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (logsMap) {
                      final dayKey = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                      );
                      final entries = planMap[dayKey] ?? [];
                      final logs = logsMap[dayKey] ?? [];
                      return _DayDetail(
                        day: _selectedDay!,
                        entries: entries,
                        logs: logs,
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              )
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
    BuildContext context,
    Map<DateTime, List<PlanEntrySchema>> planMap,
    Map<DateTime, List<StudyLogSchema>> logsMap,
    Color accent,
    bool isDark,
  ) {
    return TableCalendar(
      firstDay: DateTime(2024),
      lastDay: DateTime(2032),
      focusedDay: _focusedDay,
      calendarFormat: _format,
      selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
      },
      onFormatChanged: (f) => setState(() => _format = f),
      eventLoader: (day) {
        final key = DateTime(day.year, day.month, day.day);
        final plan = planMap[key] ?? [];
        final logs = logsMap[key] ?? [];
        return [...plan, ...logs];
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: accent.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: accent, width: 1.5),
        ),
        todayTextStyle: TextStyle(
          color: accent,
          fontWeight: FontWeight.w700,
        ),
        selectedDecoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        markerDecoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        markerSize: 5,
        defaultTextStyle: TextStyle(
          color: isDark ? DarkColors.onSurface : LightColors.onSurface,
        ),
        weekendTextStyle: TextStyle(
          color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
        ),
        // Custom day builder is set via builders below
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: Theme.of(context).textTheme.headlineSmall!,
        leftChevronIcon: Icon(Icons.chevron_left,
            color: isDark ? DarkColors.onSurface : LightColors.onSurface),
        rightChevronIcon: Icon(Icons.chevron_right,
            color: isDark ? DarkColors.onSurface : LightColors.onSurface),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: isDark ? DarkColors.onSurfaceVariant : LightColors.onSurfaceVariant,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        // Custom marker builder showing subject color dots
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          final key = DateTime(day.year, day.month, day.day);
          final planEvents =
              planMap[key]?.take(3).toList() ?? [];
          if (planEvents.isEmpty) return const SizedBox.shrink();

          return Positioned(
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: planEvents.map((e) {
                final entry = e as PlanEntrySchema;
                return Container(
                  width: 5, height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _subjectColor(entry.subjectName, isDark),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Color _subjectColor(String subject, bool isDark) {
    switch (subject) {
      case 'Physics': return isDark ? DarkColors.physics : LightColors.physics;
      case 'Chemistry': return isDark ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics': return isDark ? DarkColors.mathematics : LightColors.mathematics;
      default: return isDark ? DarkColors.biology : LightColors.biology;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Detail Panel (shown below calendar)
// ─────────────────────────────────────────────────────────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime day;
  final List<PlanEntrySchema> entries;
  final List<StudyLogSchema> logs;
  final bool isDark;

  const _DayDetail({
    required this.day,
    required this.entries,
    required this.logs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = isSameDay(day, DateTime.now());
    final totalPlanned = entries.fold(0.0, (s, e) => s + e.plannedHours);
    final totalLogged = logs.fold(0.0, (s, l) => s + l.hoursStudied);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isToday
                    ? '🔥 Today – ${DateFormat('d MMM').format(day)}'
                    : DateFormat('EEEE, d MMMM').format(day),
                style: theme.textTheme.titleLarge,
              ),
              if (totalLogged > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: LightColors.learned.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${totalLogged.toStringAsFixed(1)}h logged',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: LightColors.learned, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ),

        if (entries.isEmpty && logs.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📭', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'No sessions planned or logged for this day',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    labelStyle: theme.textTheme.labelLarge,
                    tabs: [
                      Tab(text: 'Plan (${entries.length})'),
                      Tab(text: 'Logged (${logs.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Plan tab
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: entries.length,
                          itemBuilder: (_, i) => _PlanEntryRow(
                            entry: entries[i],
                            isDark: isDark,
                          ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.1),
                        ),

                        // Logged tab
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                          itemCount: logs.length,
                          itemBuilder: (_, i) => _LogRow(
                            log: logs[i],
                            isDark: isDark,
                          ).animate(delay: (i * 50).ms).fadeIn().slideY(begin: 0.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanEntryRow extends StatelessWidget {
  final PlanEntrySchema entry;
  final bool isDark;
  const _PlanEntryRow({required this.entry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _subjectColor(entry.subjectName, isDark);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.status == 'completed'
              ? LightColors.learned.withOpacity(0.4)
              : (isDark ? DarkColors.outline : LightColors.outline),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.chapterName,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${entry.subjectName} • ${entry.plannedHours}h',
                  style: theme.textTheme.bodySmall),
            ],
          )),
          if (entry.isRevision)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LightColors.revised.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Rev.', style: theme.textTheme.labelSmall
                  ?.copyWith(color: LightColors.revised)),
            ),
          const SizedBox(width: 8),
          Icon(
            entry.status == 'completed'
                ? Icons.check_circle : Icons.radio_button_unchecked,
            color: entry.status == 'completed'
                ? LightColors.learned
                : (isDark ? DarkColors.outline : LightColors.outline),
            size: 20,
          ),
        ],
      ),
    );
  }

  Color _subjectColor(String s, bool d) {
    switch (s) {
      case 'Physics': return d ? DarkColors.physics : LightColors.physics;
      case 'Chemistry': return d ? DarkColors.chemistry : LightColors.chemistry;
      case 'Mathematics': return d ? DarkColors.mathematics : LightColors.mathematics;
      default: return d ? DarkColors.biology : LightColors.biology;
    }
  }
}

class _LogRow extends StatelessWidget {
  final StudyLogSchema log;
  final bool isDark;
  const _LogRow({required this.log, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (emoji, color) = _tagInfo(log.activityTag);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceCard : LightColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? DarkColors.outline : LightColors.outline, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(log.chapterName,
                  style: theme.textTheme.labelLarge,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('${log.subjectName} • ${log.hoursStudied}h',
                  style: theme.textTheme.bodySmall),
            ],
          )),
          Text(
            DateFormat('h:mm a').format(log.timestamp),
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  (String, Color) _tagInfo(String tag) {
    switch (tag) {
      case 'learned': return ('✅', LightColors.learned);
      case 'revised': return ('🔄', LightColors.revised);
      case 'tested': return ('🧪', LightColors.tested);
      case 'pyq': return ('📝', LightColors.pyqDone);
      case 'notes': return ('📒', LightColors.notesMade);
      default: return ('📚', LightColors.primary);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FormatToggle extends StatelessWidget {
  final CalendarFormat current;
  final ValueChanged<CalendarFormat> onChanged;
  final bool isDark;

  const _FormatToggle({
    required this.current,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (CalendarFormat.month, 'Month'),
      (CalendarFormat.twoWeeks, '2 Wks'),
      (CalendarFormat.week, 'Week'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surfaceVariant : LightColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final sel = current == item.$1;
          final accent = isDark ? DarkColors.primary : LightColors.primary;
          return GestureDetector(
            onTap: () => onChanged(item.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.$2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: sel ? Colors.white : null,
                  fontWeight: sel ? FontWeight.w700 : null,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
