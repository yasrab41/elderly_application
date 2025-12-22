import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/app_theme.dart';
import '../data/health_database_helper.dart';
import '../models/health_record.dart';

class HealthTrackingScreen extends StatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  State<HealthTrackingScreen> createState() => _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends State<HealthTrackingScreen> {
  // Current Selection State
  String _selectedMetric = 'bp';
  String _timeRange = 'Week';
  bool _isLoading = true;
  List<HealthRecord> _records = [];

  // --- UPDATED METRICS MAP WITH SPECIFIC LABELS & HINTS ---
  final Map<String, dynamic> _metrics = {
    'bp': {
      'label': AppStrings.bloodPressure,
      'unit': AppStrings.unitBP,
      'icon': Icons.favorite,
      'color': Colors.redAccent,
      'normalRange': '90-120 mmHg',
      'minNormal': 90,
      'maxNormal': 120,
      // Specific Dialog Text
      'inputLabel': 'Systolic', // Special case for BP
      'hintText': '120',
    },
    'sugar': {
      'label': AppStrings.bloodSugar,
      'unit': AppStrings.unitSugar,
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'normalRange': '70-100 mg/dL',
      'minNormal': 70,
      'maxNormal': 100,
      'inputLabel': 'Blood Sugar (mg/dL)',
      'hintText': 'Enter blood sugar',
    },
    'weight': {
      'label': AppStrings.weight,
      'unit': AppStrings.unitWeight,
      'icon': Icons.monitor_weight,
      'color': Colors.purple,
      'normalRange': '60-80 kg',
      'minNormal': 60,
      'maxNormal': 80,
      'inputLabel': 'Weight (kg)',
      'hintText': 'Enter weight',
    },
    'sleep': {
      'label': AppStrings.sleep,
      'unit': AppStrings.unitSleep,
      'icon': Icons.bedtime,
      'color': Colors.indigo,
      'normalRange': '7-9 hours',
      'minNormal': 7,
      'maxNormal': 9,
      'inputLabel': 'Sleep (hours)',
      'hintText': 'Enter sleep',
    },
    'heart': {
      'label': AppStrings.heartRate,
      'unit': AppStrings.unitHeart,
      'icon': Icons.favorite_border,
      'color': Colors.pink,
      'normalRange': '60-100 bpm',
      'minNormal': 60,
      'maxNormal': 100,
      'inputLabel': 'Heart Rate (bpm)',
      'hintText': 'Enter heart rate',
    },
    'steps': {
      'label': AppStrings.steps,
      'unit': AppStrings.unitSteps,
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'normalRange': '8000-10000 steps',
      'minNormal': 8000,
      'maxNormal': 15000,
      'inputLabel': 'Steps (count)',
      'hintText': 'Enter steps',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await HealthDatabaseHelper.instance
          .readRecords(user.uid, _selectedMetric);
      setState(() {
        _records = data;
        _isLoading = false;
      });
    }
  }

  void _changeMetric(String key) {
    setState(() => _selectedMetric = key);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the currently selected metric data
    final metric = _metrics[_selectedMetric];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(AppStrings.healthTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        // 2. REMOVED: The top-right action button is no longer needed
        actions: const [],
      ),

      // 3. UX CHANGE: Use Column to layout content above the fixed button
      body: Column(
        children: [
          // Scrollable Content (Takes up all remaining space)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetricGrid(),
                          const SizedBox(height: 25),
                          _buildDashboardCard(metric),
                          const SizedBox(height: 25),
                          Text("Recent History",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 15),
                          _buildHistoryList(),
                          // Add padding at bottom so list isn't hidden by button
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),

          // 4. FIXED BOTTOM BUTTON
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50], // Match background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () => _showAddRecordDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                // Icon provides visual cue for "Add"
                // icon: const Icon(Icons.add_circle_outline, size: 25),
                // Text dynamically updates based on selection
                label: Text(
                  "Add ${metric['label']}",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: _metrics.entries.map((e) {
        final isSelected = _selectedMetric == e.key;
        return GestureDetector(
          onTap: () => _changeMetric(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white,
              border: Border.all(
                  color: isSelected ? e.value['color'] : Colors.grey.shade200,
                  width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: e.value['color'].withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]
                  : [
                      BoxShadow(
                          color: Colors.grey.shade100,
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: e.value['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(e.value['icon'], color: e.value['color'], size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  e.value['label'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDashboardCard(Map<String, dynamic> metric) {
    HealthRecord? latestRecord = _records.isNotEmpty ? _records.first : null;
    HealthRecord? previousRecord = _records.length > 1 ? _records[1] : null;

    double? latestVal = latestRecord?.value1;
    double? latestVal2 = latestRecord?.value2;

    // Trend Calculation
    double difference = 0;
    bool isTrendingUp = false;
    if (latestRecord != null && previousRecord != null) {
      difference = latestRecord.value1 - previousRecord.value1;
      isTrendingUp = difference > 0;
    }

    // Status Calculation
    bool isNormal = true;
    if (latestVal != null) {
      isNormal =
          latestVal >= metric['minNormal'] && latestVal <= metric['maxNormal'];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: metric['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(metric['icon'],
                          color: metric['color'], size: 30),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(metric['label'],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          const Text("Latest Reading",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (latestVal != null) ...[
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _selectedMetric == 'bp'
                                      ? '${latestVal.toInt()}/${latestVal2?.toInt()}'
                                      : '${latestVal.toStringAsFixed(latestVal.truncateToDouble() == latestVal ? 0 : 1)}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                                TextSpan(
                                    text: ' ${metric['unit']}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(isNormal ? "Normal" : "Attention",
                              style: TextStyle(
                                  color:
                                      isNormal ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ] else
                          const Text("--",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey))
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Normal: ${metric['normalRange']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    if (latestRecord != null && previousRecord != null)
                      Row(
                        children: [
                          Icon(
                            isTrendingUp
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color:
                                isTrendingUp ? Colors.redAccent : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            difference.abs().toStringAsFixed(1),
                            style: TextStyle(
                                color: isTrendingUp
                                    ? Colors.redAccent
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          )
                        ],
                      )
                  ],
                ),
              ],
            ),
          ),

          // Time Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [AppStrings.week, AppStrings.month, AppStrings.year]
                  .map((range) {
                final active = _timeRange == range;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _timeRange = range),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                          color: active ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: active
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300)),
                      child: Text(
                        range,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: active ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text("Progress Chart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: _records.isEmpty
                ? Center(
                    child: Text(AppStrings.noData,
                        style: TextStyle(color: Colors.grey[400])))
                : Padding(
                    padding:
                        const EdgeInsets.only(right: 24, left: 12, bottom: 20),
                    child: _buildLineChart(metric['color']),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(Color color) {
    // 1. Determine the Cutoff Date based on selection
    final now = DateTime.now();
    DateTime cutoffDate;

    if (_timeRange == 'Week') {
      cutoffDate = now.subtract(const Duration(days: 7));
    } else if (_timeRange == 'Month') {
      cutoffDate = now.subtract(const Duration(days: 30));
    } else if (_timeRange == 'Year') {
      cutoffDate = now.subtract(const Duration(days: 365));
    } else {
      cutoffDate = now.subtract(const Duration(days: 7));
    }

    // 2. Filter records dynamically
    // Keep records newer than the cutoff, then sort Oldest -> Newest
    List<HealthRecord> chartData =
        _records.where((r) => r.timestamp.isAfter(cutoffDate)).toList();

    // Sort logic: Ensure the graph draws from left (old) to right (new)
    chartData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Handle empty data case safely
    if (chartData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No data for this period",
              style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    List<FlSpot> spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value1);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              // 3. Dynamic Interval: Avoid label overlapping
              interval: _getInterval(chartData.length),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < chartData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      // 4. Dynamic Date Format
                      _getDateFormat(chartData[index].timestamp),
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: _getMinY(chartData) * 0.9,
        maxY: _getMaxY(chartData) * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            // Only show dots if we have a small amount of data (cleaner look)
            dotData: FlDotData(show: chartData.length < 15),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER METHODS ---

  // Formats date based on view (e.g., "Mon" for Week, "Jan" for Year)
  String _getDateFormat(DateTime date) {
    if (_timeRange == 'Week') {
      return DateFormat('E').format(date); // Mon, Tue
    } else if (_timeRange == 'Month') {
      return DateFormat('d').format(date); // 1, 5, 22
    } else {
      return DateFormat('MMM').format(date); // Jan, Feb
    }
  }

  // Calculates interval to prevent text overlapping
  double _getInterval(int length) {
    if (length <= 7) return 1; // Show all labels
    if (length <= 15) return 2; // Show every 2nd label
    return (length / 5).ceilToDouble(); // Show roughly 5 labels total
  }

  double _getMaxY(List<HealthRecord> data) {
    if (data.isEmpty) return 100;
    double max = 0;
    for (var r in data) {
      if (r.value1 > max) max = r.value1;
    }
    return max;
  }

  double _getMinY(List<HealthRecord> data) {
    if (data.isEmpty) return 0;
    double min = data.first.value1;
    for (var r in data) {
      if (r.value1 < min) min = r.value1;
    }
    return min;
  }

  Widget _buildHistoryList() {
    if (_records.isEmpty) return const SizedBox();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _records.length > 10 ? 10 : _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        final metric = _metrics[_selectedMetric];
        bool isNormal = record.value1 >= metric['minNormal'] &&
            record.value1 <= metric['maxNormal'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              _selectedMetric == 'bp'
                  ? '${record.value1.toInt()}/${record.value2?.toInt()} ${metric['unit']}'
                  : '${record.value1.toInt()} ${metric['unit']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy  at HH:mm').format(record.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                if (record.note != null && record.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Note: ${record.note}",
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 12),
                    ),
                  ),
              ],
            ),
            trailing: Text(
              isNormal ? "Normal" : "Attention",
              style: TextStyle(
                  color: isNormal
                      ? Colors.green
                      : Colors.red, // Updated to Red for Attention per image
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  // --- UPDATED ADD RECORD DIALOG ---
  void _showAddRecordDialog(BuildContext context) {
    final TextEditingController val1Controller = TextEditingController();
    final TextEditingController val2Controller = TextEditingController();
    final TextEditingController noteController =
        TextEditingController(); // Added Note Controller
    final metric = _metrics[_selectedMetric];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add ${metric['label']} Record',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20))
              ],
            ),
            const SizedBox(height: 20),

            // --- DYNAMIC INPUT FIELDS ---
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric['inputLabel'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black87)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: val1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: metric['hintText'],
                          hintStyle:
                              TextStyle(color: Colors.grey[400], fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedMetric == 'bp') ...[
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Diastolic",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: val2Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "80",
                            hintStyle: TextStyle(
                                color: Colors.grey[400], fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              ],
            ),

            // --- NEW NOTE FIELD ---
            const SizedBox(height: 20),
            const Text("Note (Optional)",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3, // Taller field for notes
              decoration: InputDecoration(
                hintText: "Add any notes...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () async {
                  if (val1Controller.text.isNotEmpty) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final newRecord = HealthRecord(
                      userId: user.uid,
                      type: _selectedMetric,
                      value1: double.tryParse(val1Controller.text) ?? 0,
                      value2: _selectedMetric == 'bp'
                          ? double.tryParse(val2Controller.text)
                          : null,
                      timestamp: DateTime.now(),
                      note: noteController.text, // Saving the Note
                    );

                    await HealthDatabaseHelper.instance.create(newRecord);
                    Navigator.pop(ctx);
                    _loadData();
                  }
                },
                child: const Text('Add Record',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
