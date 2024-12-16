import 'package:flutter/material.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedTimeline = 'Daily';
  DateTime currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  // Dummy data for a month (30 days)
  final Map<DateTime, Map<String, String>> dailyData = {
    for (int i = 1; i <= 30; i++)
      DateTime(2024, 12, i): {
        'Sales': (1200 + i * 10).toString(),
        'Commissions': (150 + i).toString(),
        'SaleAmount': (10000 + i * 50).toString(),
        'Clicks': '${10 + i}K'
      }
  };

  // Helper to get data for the current timeline
  Map<String, String> getCurrentData() {
    final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    if (selectedTimeline == 'Daily') {
      return dailyData[normalizedDate] ?? {'Sales': '0', 'Commissions': '0', 'SaleAmount': '0', 'Clicks': '0'};
    } else if (selectedTimeline == 'Weekly') {
      final startOfWeek = normalizedDate.subtract(Duration(days: normalizedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));

      int totalSales = 0, totalCommissions = 0, totalSaleAmount = 0, totalClicks = 0;

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        if (dailyData[date] != null) {
          totalSales += int.parse(dailyData[date]!['Sales'] ?? '0');
          totalCommissions += int.parse(dailyData[date]!['Commissions'] ?? '0');
          totalSaleAmount += int.parse(dailyData[date]!['SaleAmount'] ?? '0');
          totalClicks += int.parse(dailyData[date]!['Clicks']!.replaceAll('K', '')) * 1000;
        }
      }

      return {
        'Sales': totalSales.toString(),
        'Commissions': totalCommissions.toString(),
        'SaleAmount': totalSaleAmount.toString(),
        'Clicks': '${(totalClicks / 1000).round()}K'
      };
    } else if (selectedTimeline == 'Monthly') {
      final month = currentDate.month;
      final year = currentDate.year;

      int totalSales = 0, totalCommissions = 0, totalSaleAmount = 0, totalClicks = 0;

      dailyData.forEach((date, data) {
        if (date.month == month && date.year == year) {
          totalSales += int.parse(data['Sales'] ?? '0');
          totalCommissions += int.parse(data['Commissions'] ?? '0');
          totalSaleAmount += int.parse(data['SaleAmount'] ?? '0');
          totalClicks += int.parse(data['Clicks']!.replaceAll('K', '')) * 1000;
        }
      });

      return {
        'Sales': totalSales.toString(),
        'Commissions': totalCommissions.toString(),
        'SaleAmount': totalSaleAmount.toString(),
        'Clicks': '${(totalClicks / 1000).round()}K'
      };
    }

    return {'Sales': '0', 'Commissions': '0', 'SaleAmount': '0', 'Clicks': '0'};
  }

  int calculateTotalEarnings(Map<String, String> data) {
    return int.parse(data['Sales']!) + int.parse(data['Commissions']!);
  }

  String getFormattedDate() {
    if (selectedTimeline == 'Daily') {
      return '${currentDate.day}/${currentDate.month}/${currentDate.year}';
    } else if (selectedTimeline == 'Weekly') {
      final startOfWeek = currentDate.subtract(Duration(days: currentDate.weekday - 1));
      final endOfWeek = startOfWeek.add(Duration(days: 6));
      return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
    } else if (selectedTimeline == 'Monthly') {
      return '${currentDate.month}/${currentDate.year}';
    }
    return '';
  }

  void changeTimeline(String timeline) {
    setState(() {
      selectedTimeline = timeline;
    });
  }

  void changeDate(bool isNext) {
    setState(() {
      if (selectedTimeline == 'Daily') {
        currentDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + (isNext ? 1 : -1),
        );
      } else if (selectedTimeline == 'Weekly') {
        currentDate = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day + (isNext ? 7 : -7),
        );
      } else if (selectedTimeline == 'Monthly') {
        currentDate = DateTime(
          currentDate.year,
          currentDate.month + (isNext ? 1 : -1),
          1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentData = getCurrentData();
    final totalEarnings = calculateTotalEarnings(currentData);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF323236),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$$totalEarnings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildSummaryColumn('Sales', currentData['Sales']!),
                        buildSummaryColumn('Commissions', currentData['Commissions']!),
                        buildSummaryColumn('Sale Amount', currentData['SaleAmount']!),
                        buildSummaryColumn('Clicks', currentData['Clicks']!),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildTimelineButton('Weekly'),
                  buildTimelineButton('Daily'),
                  buildTimelineButton('Monthly'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, color: Color(0xFF6E6E73)),
                    onPressed: () => changeDate(false),
                  ),
                  Text(
                    getFormattedDate(),
                    style: TextStyle(
                      color: Color(0xFF6E6E73),
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, color: Color(0xFF6E6E73)),
                    onPressed: () => changeDate(true),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    buildStatCard('Sales', currentData['Sales']!, 'Goal met', true),
                    buildStatCard('Commissions', currentData['Commissions']!, 'Goal met', true),
                    buildStatCard('Sale Amount', currentData['SaleAmount']!, 'Goal met', true),
                    buildStatCard('Clicks', currentData['Clicks']!, 'Goal met', true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Color(0xFF6E6E73), fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildTimelineButton(String timeline) {
    return GestureDetector(
      onTap: () => changeTimeline(timeline),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: selectedTimeline == timeline ? Color(0xFFB9FF39) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          timeline,
          style: TextStyle(
            color: selectedTimeline == timeline ? Colors.black : Color(0xFF6E6E73),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value, String description, bool isPositive) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Color(0xFF6E6E73), fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}