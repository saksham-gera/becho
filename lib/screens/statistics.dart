import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedTimeline = 'daily';
  DateTime currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Map<String, dynamic> currentData = {
    'earnings': '0',
    'Sales': '0',
    'Commissions': '0',
    'SaleAmount': '0',
    'Clicks': '0',
  };
  Map<String, dynamic> lifetimeStatistics = {
    'earnings': '0',
    'Sales': '0',
    'Commissions': '0',
    'SaleAmount': '0',
    'Clicks': '0',
  };
  bool isLoading = true;

  FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final userId = await _storage.read(key: 'userID');
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    DateTime startDate, endDate;
    if (selectedTimeline == 'daily') {
      startDate = currentDate;
      endDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    } else if (selectedTimeline == 'weekly') {
      startDate = currentDate.subtract(Duration(days: 7));
      endDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    } else if (selectedTimeline == 'monthly') {
      startDate = DateTime(currentDate.year, currentDate.month, 1);
      endDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    } else {
      startDate = currentDate;
      endDate = DateTime(currentDate.year, currentDate.month, currentDate.day + 1);
    }

    final formattedStartDate = formatter.format(startDate);
    final formattedEndDate = formatter.format(endDate);

    final url = Uri.parse(
      'https://bechoserver.vercel.app/commissions?userId=$userId&startDate=$formattedStartDate&endDate=$formattedEndDate',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final commissionData = responseData['commissionData'];
        final lifetimeData = responseData['lifetimeData'];

        setState(() {
          currentData = {
            'earnings': commissionData['total_earnings'].toString(),
            'Sales': commissionData['total_sales_count'].toString(),
            'Commissions': commissionData['total_commission'].toString(),
            'SaleAmount': commissionData['total_sales_amount'].toString(),
            'Clicks': commissionData['total_clicks_count'].toString(),
          };

          lifetimeStatistics = {
            'earnings': lifetimeData['lifetime_earnings'].toString(),
            'Sales': lifetimeData['lifetime_sales_count'].toString(),
            'Commissions': lifetimeData['lifetime_commission'].toString(),
            'SaleAmount': lifetimeData['lifetime_sales_amount'].toString(),
            'Clicks': lifetimeData['lifetime_clicks_count'].toString(),
          };
        });
      } else {
        resetData();
      }
    } catch (error) {
      resetData();
    }

    setState(() {
      isLoading = false;
    });
  }

  void resetData() {
    setState(() {
      currentData = {
        'earnings': '0',
        'Sales': '0',
        'Commissions': '0',
        'SaleAmount': '0',
        'Clicks': '0',
      };
      lifetimeStatistics = {
        'earnings': '0',
        'Sales': '0',
        'Commissions': '0',
        'SaleAmount': '0',
        'Clicks': '0',
      };
    });
  }

  void changeTimeline(String timeline) {
    setState(() {
      selectedTimeline = timeline;
    });
    fetchData();
  }

  void changeDate(bool isNext) {
    setState(() {
      if (isNext && currentDate.isBefore(DateTime.now())) {
        if (selectedTimeline == 'daily') {
          currentDate = currentDate.add(Duration(days: 1));
        } else if (selectedTimeline == 'weekly') {
          currentDate = currentDate.add(Duration(days: 7));
        } else if (selectedTimeline == 'monthly') {
          currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
        }
      } else if (!isNext) {
        if (selectedTimeline == 'daily') {
          currentDate = currentDate.add(Duration(days: -1));
        } else if (selectedTimeline == 'weekly') {
          currentDate = currentDate.add(Duration(days: -7));
        } else if (selectedTimeline == 'monthly') {
          currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
        }
      }
    });

    if (currentDate.isAfter(DateTime.now())) {
      currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    }

    fetchData();
  }

  String calculateTotalEarnings() {
    double total = double.parse(lifetimeStatistics['earnings']!);
    return total.toStringAsFixed(0); // Removes decimals
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings = calculateTotalEarnings();

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
                          'Lifetime Earnings',
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
                        buildSummaryColumn('Sales', lifetimeStatistics['Sales']!),
                        buildSummaryColumn('Commissions', lifetimeStatistics['Commissions']!),
                        buildSummaryColumn('Sales Amount', lifetimeStatistics['SaleAmount']!),
                        buildSummaryColumn('Clicks', lifetimeStatistics['Clicks']!),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildTimelineButton('weekly'),
                  buildTimelineButton('daily'),
                  buildTimelineButton('monthly'),
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
                    '${currentDate.day}/${currentDate.month}/${currentDate.year}',
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
              if(isLoading)
                Center(child: CircularProgressIndicator())
              else
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    buildStatCard('Total Sales Count', currentData['Sales']!, 'Goal met', true),
                    buildStatCard('Total Commissions', currentData['Commissions']!, 'Goal met', true),
                    buildStatCard('Total Sale Amount', currentData['SaleAmount']!, 'Goal met', true),
                    buildStatCard('Total Clicks Count', currentData['Clicks']!, 'Goal met', true),
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
          timeline.capitalize(),
          style: TextStyle(
            color: selectedTimeline == timeline ? Colors.black : Color(0xFF6E6E73),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget buildWideStatCard(String title, String value, String description, bool isPositive) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
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
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              size: 32,
            ),
          ],
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}