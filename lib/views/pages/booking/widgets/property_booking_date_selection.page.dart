import 'package:flutter/material.dart';
import 'package:fuodz/constants/app_colors.dart';
import 'package:fuodz/constants/sizes.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/widgets/base.page.dart';
import 'package:fuodz/widgets/buttons/custom_button.dart';
import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PropertyBookingDateSectionPage extends StatefulWidget {
  PropertyBookingDateSectionPage({
    required this.property,
    this.preselectedDateRange,
    Key? key,
  }) : super(key: key);

  final Property property;
  final DateTimeRange? preselectedDateRange;

  @override
  State<PropertyBookingDateSectionPage> createState() =>
      _PropertyBookingDateSectionPageState();
}

class _PropertyBookingDateSectionPageState
    extends State<PropertyBookingDateSectionPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final ScrollController _scrollController = ScrollController();
  final int monthsToShow = 13;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedDateRange != null) {
      final start = widget.preselectedDateRange!.start;
      final end = widget.preselectedDateRange!.end;
      _startDate = DateTime(start.year, start.month, start.day);
      _endDate = DateTime(end.year, end.month, end.day);
    }
  }

  // Check if a date is available
  bool _isDateAvailable(DateTime date) {
    final now = DateTime.now();
    // Normalize date to ignore time
    final checkDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);

    if (checkDate.isBefore(today)) return false;

    // Check available ranges
    if (widget.property.availableRanges.isEmpty) {
      if (widget.property.availableFrom != null &&
          widget.property.availableTo != null) {
        final availableFrom = DateTime(
          widget.property.availableFrom!.year,
          widget.property.availableFrom!.month,
          widget.property.availableFrom!.day,
        );
        final availableTo = DateTime(
          widget.property.availableTo!.year,
          widget.property.availableTo!.month,
          widget.property.availableTo!.day,
        );
        return !checkDate.isBefore(availableFrom) &&
            !checkDate.isAfter(availableTo);
      }
      return true;
    }

    for (var range in widget.property.availableRanges) {
      // Normalize range dates
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(range.end.year, range.end.month, range.end.day);

      if (!checkDate.isBefore(start) && !checkDate.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  void _onDateSelected(DateTime date) {
    if (!_isDateAvailable(date)) return;

    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Validation: Ensure no unavailable dates in between
        if (date.isBefore(_startDate!)) {
          _startDate = date;
        } else {
          // Check range availability
          bool rangeValid = true;
          DateTime iter = _startDate!.add(Duration(days: 1));
          while (iter.isBefore(date)) {
            if (!_isDateAvailable(iter)) {
              rangeValid = false;
              break;
            }
            iter = iter.add(Duration(days: 1));
          }

          if (rangeValid) {
            _endDate = date;
          } else {
            // If invalid range, just reset property start to new date
            _startDate = date;
          }
        }
      }
    });
  }

  void _saveDateSelection() {
    if (_startDate != null && _endDate != null) {
      final selectedDateRange = DateTimeRange(
        start: _startDate!,
        end: _endDate!,
      );
      Navigator.pop(context, selectedDateRange);
    }
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Select Dates".tr(),
      showAppBar: true,
      showLeadingAction: true,
      body: VStack([
        // Weekday Headers
        _buildWeekdayHeaders(),

        // Calendar List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: monthsToShow,
            itemBuilder: (context, index) {
              final monthDate = Jiffy.now().add(months: index).dateTime;
              return _buildMonthView(monthDate);
            },
          ),
        ),

        // Bottom Bar
        Container(
          padding: EdgeInsets.all(Sizes.paddingSizeDefault),
          decoration: BoxDecoration(
            color: context.cardColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: HStack([
              TextButton(
                onPressed: _clearSelection,
                child: "Clear".tr().text.underline.make(),
              ),
              Spacer(),
              CustomButton(
                title: "Save".tr(),
                onPressed:
                    (_startDate != null && _endDate != null)
                        ? _saveDateSelection
                        : null,
              ).w(150),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _buildWeekdayHeaders() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return HStack(
      days.map((day) {
        return Expanded(
          child: Text(
            day.tr(), // Using tr() in case translations exist
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        );
      }).toList(),
    ).pSymmetric(h: 16, v: 10);
  }

  Widget _buildMonthView(DateTime month) {
    final daysInMonth = Jiffy.parseFromDateTime(month).daysInMonth;
    final firstDayOffset =
        DateTime(month.year, month.month, 1).weekday - 1; // Mon=1 -> 0

    return VStack([
      // Month Title
      Jiffy.parseFromDateTime(month)
          .format(pattern: "MMMM yyyy")
          .text
          .xl
          .bold
          .make()
          .pOnly(top: 20, bottom: 10, left: 16),

      // Calendar Grid
      GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: daysInMonth + firstDayOffset,
        itemBuilder: (context, index) {
          if (index < firstDayOffset) {
            return SizedBox();
          }
          final day = index - firstDayOffset + 1;
          final date = DateTime(month.year, month.month, day);
          return _buildDayItem(date);
        },
      ),
    ]);
  }

  Widget _buildDayItem(DateTime date) {
    final isAvailable = _isDateAvailable(date);
    bool isSelected = false;
    bool isRange = false;

    if (_startDate != null) {
      if (date.isAtSameMomentAs(_startDate!) ||
          (date.year == _startDate!.year &&
              date.month == _startDate!.month &&
              date.day == _startDate!.day)) {
        isSelected = true;
      }
    }

    if (_endDate != null) {
      if (date.isAtSameMomentAs(_endDate!) ||
          (date.year == _endDate!.year &&
              date.month == _endDate!.month &&
              date.day == _endDate!.day)) {
        isSelected = true;
      }
    }

    if (_startDate != null && _endDate != null) {
      // Normalize for range check
      final s = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
      final e = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
      final d = DateTime(date.year, date.month, date.day);
      if (d.isAfter(s) && d.isBefore(e)) {
        isRange = true;
      }
    }

    // Styles
    Color bgColor = Colors.transparent;
    Color textColor =
        isAvailable
            ? context.textTheme.bodyMedium!.color!
            : Colors.grey.shade300;
    BoxDecoration? decoration;

    if (isSelected) {
      bgColor = AppColor.primaryColor;
      textColor = Colors.white;
      decoration = BoxDecoration(color: bgColor, shape: BoxShape.circle);
    } else if (isRange) {
      bgColor = AppColor.primaryColor.withOpacity(0.1);
      textColor = context.textTheme.bodyMedium!.color!;
      decoration = BoxDecoration(color: bgColor, shape: BoxShape.circle);
    } else if (!isAvailable) {
      decoration = BoxDecoration(
        // lineThrough or just grey text
      );
    }

    return GestureDetector(
      onTap: () => _onDateSelected(date),
      child: Container(
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          "${date.day}",
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            decoration: !isAvailable ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
