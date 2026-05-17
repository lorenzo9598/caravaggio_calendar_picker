import 'calendar_picker_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Defines how dates can be selected in [CDatePicker].
enum CustomDatePickerMode {
  single,
  multiple,
  range,
}

/// Calendar widget with single, multiple, or range date selection.
class CDatePicker extends StatefulWidget {
  const CDatePicker({
    super.key,
    required this.mode,
    required this.onChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.initialSelectedDates,
    this.weekDays,
    this.allowPastDates = false,
  });

  final CustomDatePickerMode mode;
  final ValueChanged<List<DateTime>> onChanged;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<DateTime>? initialSelectedDates;
  final List<String>? weekDays;

  /// When false (default), dates before today are disabled.
  final bool allowPastDates;

  @override
  State<CDatePicker> createState() => _CDatePickerState();
}

class _CDatePickerState extends State<CDatePicker> {
  late DateTime _currentMonth;
  late List<DateTime> _selectedDates;
  late bool _awaitingRangeEnd;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDates = (widget.initialSelectedDates ?? []).map(_normalize).toList();
    if (widget.mode == CustomDatePickerMode.range) {
      _awaitingRangeEnd = _selectedDates.length < 2;
    } else {
      _awaitingRangeEnd = false;
    }
  }

  DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> _datesBetween(DateTime start, DateTime end) {
    final from = start.isBefore(end) ? start : end;
    final to = start.isBefore(end) ? end : start;
    final dates = <DateTime>[];
    for (var d = from; !d.isAfter(to); d = d.add(const Duration(days: 1))) {
      dates.add(d);
    }
    return dates;
  }

  DateTime? get _rangeStart =>
      widget.mode == CustomDatePickerMode.range && _selectedDates.isNotEmpty ? _selectedDates.first : null;

  DateTime? get _rangeEnd {
    if (widget.mode != CustomDatePickerMode.range || _selectedDates.isEmpty || _awaitingRangeEnd) {
      return null;
    }
    return _selectedDates.last;
  }

  bool _isInRange(DateTime date) {
    final normalizedDate = _normalize(date);
    final start = _rangeStart;
    if (start == null) return false;
    final end = _rangeEnd ?? start;
    return !normalizedDate.isBefore(start) && !normalizedDate.isAfter(end);
  }

  bool _isRangeStart(DateTime date) {
    final start = _rangeStart;
    return start != null && _isSameDay(_normalize(date), start);
  }

  bool _isRangeEnd(DateTime date) {
    final end = _rangeEnd;
    return end != null && _isSameDay(_normalize(date), end);
  }

  void _onDateTap(DateTime date) {
    setState(() {
      final normalizedDate = _normalize(date);

      switch (widget.mode) {
        case CustomDatePickerMode.single:
          _selectedDates = [normalizedDate];
        case CustomDatePickerMode.multiple:
          if (_selectedDates.any((d) => _isSameDay(d, normalizedDate))) {
            _selectedDates.removeWhere((d) => _isSameDay(d, normalizedDate));
          } else {
            _selectedDates.add(normalizedDate);
          }
          _selectedDates.sort((a, b) => a.compareTo(b));
        case CustomDatePickerMode.range:
          if (_awaitingRangeEnd && _selectedDates.length == 1) {
            final anchor = _selectedDates.first;
            _selectedDates = _isSameDay(anchor, normalizedDate) ? [normalizedDate] : _datesBetween(anchor, normalizedDate);
            _awaitingRangeEnd = false;
          } else {
            _selectedDates = [normalizedDate];
            _awaitingRangeEnd = true;
          }
      }

      widget.onChanged(List.from(_selectedDates));
    });
  }

  bool _isDateSelected(DateTime date) {
    if (widget.mode == CustomDatePickerMode.range) {
      return _isInRange(date);
    }
    final normalizedDate = _normalize(date);
    return _selectedDates.any((d) => _isSameDay(d, normalizedDate));
  }

  bool _isDateEnabled(DateTime date) {
    final normalizedDate = _normalize(date);

    if (!widget.allowPastDates) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (normalizedDate.isBefore(today)) {
        return false;
      }
    }

    if (widget.firstDate != null) {
      final firstDate = _normalize(widget.firstDate!);
      if (normalizedDate.isBefore(firstDate)) {
        return false;
      }
    }

    if (widget.lastDate != null) {
      final lastDate = _normalize(widget.lastDate!);
      if (normalizedDate.isAfter(lastDate)) {
        return false;
      }
    }

    return true;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    int firstWeekday = firstDay.weekday;
    firstWeekday = firstWeekday == 7 ? 0 : firstWeekday - 1;

    final days = <DateTime>[];

    final previousMonth = DateTime(month.year, month.month - 1);
    final daysInPreviousMonth = DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    for (int i = firstWeekday - 1; i >= 0; i--) {
      days.add(DateTime(previousMonth.year, previousMonth.month, daysInPreviousMonth - i));
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    final remainingDays = 42 - days.length;
    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = CalendarPickerLocalizations.of(context);
    final days = _getDaysInMonth(_currentMonth);
    final today = DateTime.now();
    final weekDays = widget.weekDays ?? localizations.weekDays;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy', localizations.localeCode).format(_currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Table(
            children: [
              for (int week = 0; week < 6; week++)
                TableRow(
                  children: [
                    for (int day = 0; day < 7; day++)
                      Builder(
                        builder: (context) {
                          final dateIndex = week * 7 + day;
                          if (dateIndex >= days.length) {
                            return const SizedBox.shrink();
                          }
                          final date = days[dateIndex];
                          final isCurrentMonthDay = date.month == _currentMonth.month;
                          final isInRange = widget.mode == CustomDatePickerMode.range && _isInRange(date);
                          final isRangeEndpoint = widget.mode == CustomDatePickerMode.range &&
                              (_isRangeStart(date) || _isRangeEnd(date));
                          final isSelected = widget.mode == CustomDatePickerMode.range
                              ? isRangeEndpoint
                              : _isDateSelected(date);
                          final isRangeMiddle = isInRange && !isRangeEndpoint;
                          final isEnabled = _isDateEnabled(date);
                          final isToday = isCurrentMonthDay &&
                              date.year == today.year &&
                              date.month == today.month &&
                              date.day == today.day;
                          final primary = Theme.of(context).primaryColor;

                          return GestureDetector(
                            onTap: isEnabled ? () => _onDateTap(date) : null,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primary
                                    : isRangeMiddle
                                        ? primary.withValues(alpha: 0.18)
                                        : isToday
                                            ? primary.withValues(alpha: 0.1)
                                            : Colors.transparent,
                                borderRadius: widget.mode == CustomDatePickerMode.range && isInRange
                                    ? BorderRadius.horizontal(
                                        left: _isRangeStart(date) ? const Radius.circular(20) : Radius.zero,
                                        right: _isRangeEnd(date) ? const Radius.circular(20) : Radius.zero,
                                      )
                                    : null,
                                shape: widget.mode == CustomDatePickerMode.range && isInRange
                                    ? BoxShape.rectangle
                                    : BoxShape.circle,
                                border: isToday && !isInRange
                                    ? Border.all(
                                        color: primary,
                                        width: 2,
                                        strokeAlign: BorderSide.strokeAlignOutside,
                                      )
                                    : null,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isInRange || isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : !isCurrentMonthDay
                                            ? Colors.grey.shade300
                                            : !isEnabled
                                                ? Colors.grey.shade400
                                                : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
            ],
          ),
        ),
        if (widget.mode == CustomDatePickerMode.range && _selectedDates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _awaitingRangeEnd
                    ? '${DateFormat('dd/MM/yyyy', localizations.localeCode).format(_rangeStart!)} — ${localizations.selectEndDate}'
                    : '${DateFormat('dd/MM/yyyy', localizations.localeCode).format(_rangeStart!)} – ${DateFormat('dd/MM/yyyy', localizations.localeCode).format(_rangeEnd ?? _rangeStart!)} (${_selectedDates.length} ${localizations.daysLabel})',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
        if (widget.mode == CustomDatePickerMode.multiple && _selectedDates.isNotEmpty) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedDates.map((date) {
                final normalizedDate = _normalize(date);
                return Chip(
                  key: ValueKey('${normalizedDate.year}-${normalizedDate.month}-${normalizedDate.day}'),
                  label: Text(DateFormat('dd/MM', localizations.localeCode).format(date)),
                  onDeleted: () {
                    setState(() {
                      _selectedDates = _selectedDates.where((d) => !_isSameDay(d, normalizedDate)).toList();
                      widget.onChanged(List.from(_selectedDates));
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
