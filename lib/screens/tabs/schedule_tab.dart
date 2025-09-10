import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<ScheduleItem> _scheduleItems = [
    ScheduleItem(
      title: 'Water Tomato Plants',
      description: 'Check soil moisture and water if needed',
      time: DateTime.now().add(const Duration(hours: 2)),
      category: ScheduleCategory.watering,
      isCompleted: false,
    ),
    ScheduleItem(
      title: 'Apply Fertilizer',
      description: 'Apply nitrogen-rich fertilizer to corn field',
      time: DateTime.now().add(const Duration(days: 1)),
      category: ScheduleCategory.fertilizing,
      isCompleted: false,
    ),
    ScheduleItem(
      title: 'Pest Inspection',
      description: 'Check for aphids and other pests',
      time: DateTime.now().add(const Duration(days: 2)),
      category: ScheduleCategory.inspection,
      isCompleted: false,
    ),
    ScheduleItem(
      title: 'Harvest Lettuce',
      description: 'Harvest mature lettuce heads',
      time: DateTime.now().add(const Duration(days: 3)),
      category: ScheduleCategory.harvesting,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        // Custom App Bar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          snap: true,
          expandedHeight: 80,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'schedule',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'FunnelDisplay',
                                color: Colors.white,
                                letterSpacing: -0.8,
                              ),
                            ),
                            Text(
                              'plan your farming activities',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Add new schedule item
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1FBA55).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1FBA55).withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(
                            Icons.add_outlined,
                            color: const Color(0xFF1FBA55),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Today',
                        value: '2',
                        subtitle: 'Tasks',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'This Week',
                        value: '8',
                        subtitle: 'Tasks',
                        color: const Color(0xFF1FBA55),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Completed',
                        value: '15',
                        subtitle: 'This month',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCalendar(),
              ),

              const SizedBox(height: 32),

              // Schedule List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Upcoming Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'FunnelDisplay',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tasks
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: _scheduleItems
                      .map((item) => _buildScheduleItem(item))
                      .toList(),
                ),
              ),

              const SizedBox(height: 100), // Bottom padding
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'FunnelDisplay',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    final timeText = _formatTime(item.time);
    final dayText = _formatDay(item.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Row(
        children: [
          // Category icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.category.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.category.icon,
              color: item.category.color,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$dayText • $timeText',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Checkbox
          Checkbox(
            value: item.isCompleted,
            onChanged: (value) {
              setState(() {
                item.isCompleted = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: const Color(0xFF1FBA55),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDay(DateTime time) {
    final now = DateTime.now();
    final difference = time.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 7) {
      const days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[time.weekday - 1];
    }

    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: SizedBox(
        height: 260, // Reduced height to prevent overflow
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          daysOfWeekHeight: 20,
          rowHeight: 32,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'FunnelDisplay',
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            weekendStyle: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          calendarStyle: CalendarStyle(
            // Default day styling
            defaultTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            weekendTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            outsideTextStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),

            // Selected day styling
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF1FBA55),
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),

            // Today styling
            todayDecoration: BoxDecoration(
              color: const Color(0xFF1FBA55).withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1FBA55), width: 1.5),
            ),
            todayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),

            // Marker styling for days with tasks
            markersMaxCount: 3,
            markerDecoration: const BoxDecoration(
              color: Color(0xFFFF9800),
              shape: BoxShape.circle,
            ),
            markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
            markerSizeScale: 0.2,

            // Cell padding
            cellMargin: const EdgeInsets.all(1),
            cellPadding: const EdgeInsets.all(4),

            // Row decoration
            rowDecoration: const BoxDecoration(),
            tableBorder: const TableBorder(),
          ),
          eventLoader: (day) {
            // Show markers for days that have scheduled tasks
            return _scheduleItems
                .where((item) => isSameDay(item.time, day))
                .toList();
          },
        ),
      ),
    );
  }
}

class ScheduleItem {
  final String title;
  final String description;
  final DateTime time;
  final ScheduleCategory category;
  bool isCompleted;

  ScheduleItem({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.isCompleted,
  });
}

enum ScheduleCategory {
  watering(Icons.water_drop_outlined, Color(0xFF2196F3)),
  fertilizing(Icons.eco_outlined, Color(0xFF4CAF50)),
  inspection(Icons.search_outlined, Color(0xFFFF9800)),
  harvesting(Icons.agriculture_outlined, Color(0xFF9C27B0)),
  planting(Icons.park_outlined, Color(0xFF8BC34A));

  const ScheduleCategory(this.icon, this.color);
  final IconData icon;
  final Color color;
}
