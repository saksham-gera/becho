import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Daily',
                    style: TextStyle(
                      color: Color(0xFF6E6E73),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Color(0xFFB9FF39),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Weekly',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Monthly',
                    style: TextStyle(
                      color: Color(0xFF6E6E73),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Jun 9, 2024 - Jun 15, 2024',
                  style: TextStyle(
                    color: Color(0xFF6E6E73),
                    fontSize: 14,
                  ),
                ),
              ),
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
                    Text(
                      'Physical Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total for the week',
                      style: TextStyle(
                        color: Color(0xFF6E6E73),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildSummaryColumn('Steps', '67 735'),
                        buildSummaryColumn('Calories burned', '28 735'),
                        buildSummaryColumn('Training time', '8h 37min'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    buildStatCard(
                        'Steps', '8 796', 'Goal is 8 000 steps', true),
                    buildStatCard(
                        'Calories', '700', 'Goal is 850 calories', false),
                    buildStatCard(
                        'Heart rate', '75 bpm', 'Goal met', true),
                    buildStatCard('Sleep hours', '6h 50m', 'Goal is 8h', false),
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

  Widget buildStatCard(String title, String value, String description,
      bool isPositive) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositive ? Color(0xFFB9FF39) : Color(0xFFFF4B4B),
                ),
              ],
            ),
            Spacer(),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Color(0xFF6E6E73), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}