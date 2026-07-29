import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'input_theme.dart';

enum DatePickerModeType {
  dayMonthYear,
  monthYear,
  yearOnly,
}

class CustomInputDate extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String label;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DatePickerModeType mode;
  final FormFieldValidator<String>? validator;

  const CustomInputDate({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.minDate,
    this.maxDate,
    this.mode = DatePickerModeType.dayMonthYear,
    this.validator,
  });

  @override
  State<CustomInputDate> createState() => _CustomInputDateState();
}

class _CustomInputDateState extends State<CustomInputDate> {
  late final TextEditingController _controller;

  static final DateTime _defaultMinDate = DateTime(1900);
  static final DateTime _defaultMaxDate = DateTime(2100);

  DateTime get _effectiveMinDate => widget.minDate ?? _defaultMinDate;
  DateTime get _effectiveMaxDate => widget.maxDate ?? _defaultMaxDate;

  DateTime get _initialDate {
    var candidate = widget.selectedDate ?? DateTime.now();
    if (candidate.isBefore(_effectiveMinDate)) candidate = _effectiveMinDate;
    if (candidate.isAfter(_effectiveMaxDate)) candidate = _effectiveMaxDate;
    return candidate;
  }

  DatePickerMode get _initialPickerMode =>
      widget.mode == DatePickerModeType.dayMonthYear
          ? DatePickerMode.day
          : DatePickerMode.year;

  String _format(DateTime? date) {
    if (date == null) return '';
    return switch (widget.mode) {
      DatePickerModeType.yearOnly => DateFormat('yyyy').format(date),
      DatePickerModeType.monthYear => DateFormat('MM/yyyy').format(date),
      DatePickerModeType.dayMonthYear => DateFormat('dd/MM/yyyy').format(date),
    };
  }

  DateTime _normalize(DateTime picked) {
    return switch (widget.mode) {
      DatePickerModeType.yearOnly => DateTime(picked.year),
      DatePickerModeType.monthYear => DateTime(picked.year, picked.month),
      DatePickerModeType.dayMonthYear => picked,
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.selectedDate));
  }

  @override
  void didUpdateWidget(CustomInputDate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.mode != widget.mode) {
      _controller.text = _format(widget.selectedDate);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _initialDate,
      firstDate: _effectiveMinDate,
      lastDate: _effectiveMaxDate,
      initialDatePickerMode: _initialPickerMode,
    );
    if (picked != null && mounted) {
      widget.onDateSelected(_normalize(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      readOnly: true,
      onTap: _showPicker,
      controller: _controller,
      validator: widget.validator,
      style: TextStyle(color: colors.onSurface),
      decoration: inputDecoration(
        colors: colors,
        label: widget.label,
        suffixIcon:
            Icon(Icons.calendar_today_rounded, color: colors.primary),
      ),
    );
  }
}
