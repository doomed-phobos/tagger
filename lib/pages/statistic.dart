import 'package:flutter/material.dart';
import 'package:tagger/db/database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticItem {
  final String name;
  final int count;

  StatisticItem(this.name, this.count);
}

class StatisticPage extends StatelessWidget {
  final Database _database;

  const StatisticPage(this._database, {super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _database.get_tags_count(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        final chartData = data.entries
            .map((e) => StatisticItem(e.key, e.value))
            .toList();

        final chartHeight = (chartData.length * 30).toDouble();

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: SizedBox(
            height: chartHeight,

            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                maximumLabelWidth: 60,

                labelIntersectAction: AxisLabelIntersectAction.wrap,

                labelStyle: const TextStyle(fontSize: 11),
              ),

              primaryYAxis: NumericAxis(),

              tooltipBehavior: TooltipBehavior(enable: true),

              series: <CartesianSeries>[
                BarSeries<StatisticItem, String>(
                  name: "Tags",
                  color: Colors.blue,
                  dataSource: chartData,
                  xValueMapper: (StatisticItem item, _) => item.name,
                  yValueMapper: (StatisticItem item, _) => item.count,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
