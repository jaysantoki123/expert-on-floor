import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ExpertAvailabilityScreen extends StatefulWidget {
  const ExpertAvailabilityScreen({super.key});

  @override
  State<ExpertAvailabilityScreen> createState() => _ExpertAvailabilityScreenState();
}

class _ExpertAvailabilityScreenState extends State<ExpertAvailabilityScreen> {
  bool _vacationMode = false;
  final Color primaryGreen = const Color(0xFF0F8C43);
  final Color bgLight = const Color(0xFFFAFBFA);

  DateTime _currentDate = DateTime.now();
  final List<DateTime> _blockedDates = [];
  final List<DateTime> _extraAvailableDates = [];

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return monthNames[month - 1];
  }

  Future<void> _showAddAvailabilityDialog() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow slightly past for testing, usually now
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryGreen,
                onPrimary: Colors.white,
                onSurface: AppColors.ink,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          // Check if it already exists, if so ignore
          if (!_extraAvailableDates.any((d) =>
              d.year == pickedDate.year &&
              d.month == pickedDate.month &&
              d.day == pickedDate.day)) {
            _extraAvailableDates.add(pickedDate);
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added availability on ${pickedDate.day}/${pickedDate.month}/${pickedDate.year} at ${pickedTime.format(context)}'),
              backgroundColor: primaryGreen,
            ),
          );
        }
      }
    }
  }

  Future<void> _showBlockDateDialog() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFD32F2F),
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (!_blockedDates.any((d) =>
            d.year == pickedDate.year &&
            d.month == pickedDate.month &&
            d.day == pickedDate.day)) {
          _blockedDates.add(pickedDate);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Blocked date: ${pickedDate.day}/${pickedDate.month}/${pickedDate.year}'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, 'Availability', 'Manage your calendar and slots'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vacation Mode Card
                _buildVacationModeCard(),
                const SizedBox(height: 24),

                // Weekly Schedule
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Weekly Schedule",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.settings, color: primaryGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Bulk Edit",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildWeeklyScheduleCard(),
                const SizedBox(height: 24),

                // Specific Dates
                const Text(
                  "Specific Dates",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCalendarCard(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 24),

                // Info Box
                _buildInfoBox(),
                const SizedBox(height: 80), // Padding for FAB
              ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAvailabilityDialog,
        backgroundColor: primaryGreen,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildVacationModeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F3E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.beach_access, color: primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vacation Mode",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Temporarily hide your profile\nfrom search",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _vacationMode,
            activeColor: primaryGreen,
            onChanged: (val) {
              setState(() {
                _vacationMode = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildScheduleRow("Mon", "09:00 AM - 05:00 PM", isOdd: false),
          _buildScheduleRow("Tue", "09:00 AM - 05:00 PM", isOdd: true),
          _buildScheduleRow("Wed", "09:00 AM - 12:00 PM", isOdd: false),
          _buildScheduleRow("Thu", "Off", isOdd: true),
          _buildScheduleRow("Fri", "10:00 AM - 04:00 PM", isOdd: false),
          _buildScheduleRow("Sat", "Off", isOdd: true),
          _buildScheduleRow("Sun", "Off", isOdd: false, isLast: true),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String time, {required bool isOdd, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isOdd ? bgLight : Colors.white,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink.withValues(alpha: 0.8),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            time,
            style: TextStyle(
              fontSize: 13,
              color: time == "Off" ? AppColors.muted : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    // Calculate calendar dates dynamically
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final daysInCurrentMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    final firstWeekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)
    
    final daysInPreviousMonth = DateTime(_currentDate.year, _currentDate.month, 0).day;

    List<Map<String, dynamic>> calendarDates = [];

    // Previous month days
    final int prevMonthDaysToFill = firstWeekday - 1;
    for (int i = prevMonthDaysToFill - 1; i >= 0; i--) {
      calendarDates.add({
        'day': '${daysInPreviousMonth - i}',
        'isCurrentMonth': false,
        'date': DateTime(_currentDate.year, _currentDate.month - 1, daysInPreviousMonth - i),
      });
    }

    // Current month days
    for (int i = 1; i <= daysInCurrentMonth; i++) {
      final date = DateTime(_currentDate.year, _currentDate.month, i);
      String? highlight;
      
      if (_extraAvailableDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
        highlight = 'green';
      } else if (_blockedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day)) {
        highlight = 'red';
      }

      // Hardcode initial highlights if lists are empty (just for demo purposes)
      if (_extraAvailableDates.isEmpty && _blockedDates.isEmpty && _currentDate.year == 2023 && _currentDate.month == 10) {
         if (i == 3) highlight = 'green';
         if (i == 9) highlight = 'red';
      }

      calendarDates.add({
        'day': '$i',
        'isCurrentMonth': true,
        'date': date,
        'highlight': highlight,
      });
    }

    // Next month days to complete 5 or 6 rows (35 or 42 days)
    final remainingDays = (calendarDates.length > 35 ? 42 : 35) - calendarDates.length;
    for (int i = 1; i <= remainingDays; i++) {
      calendarDates.add({
        'day': '$i',
        'isCurrentMonth': false,
        'date': DateTime(_currentDate.year, _currentDate.month + 1, i),
      });
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_getMonthName(_currentDate.month)} ${_currentDate.year}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.chevron_left, color: AppColors.muted, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(Icons.chevron_right, color: AppColors.muted, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysOfWeek
                .map((day) => SizedBox(
                      width: 24,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: calendarDates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final data = calendarDates[index];
              final isCurrentMonth = data['isCurrentMonth'] as bool;
              final day = data['day'] as String;
              final highlight = data['highlight'] as String?;

              Color bgColor = Colors.transparent;
              Color textColor = isCurrentMonth ? AppColors.ink : AppColors.muted.withValues(alpha: 0.5);

              if (highlight == 'green') {
                bgColor = const Color(0xFFE2F3E9);
                textColor = primaryGreen;
              } else if (highlight == 'red') {
                bgColor = const Color(0xFFFFEAEA);
                textColor = const Color(0xFFD32F2F);
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: highlight != null ? FontWeight.bold : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _showAddAvailabilityDialog,
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              "Add Availability",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _showBlockDateDialog,
            icon: const Icon(Icons.block, color: Color(0xFFD32F2F), size: 20),
            label: const Text(
              "Block Dates",
              style: TextStyle(
                color: Color(0xFFD32F2F),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.line.withValues(alpha: 0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryGreen, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Changes to your weekly schedule will apply to all future weeks unless specific date exceptions are made.",
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.ink,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
