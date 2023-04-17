import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class GaugeChart extends StatelessWidget {
  final List<charts.Series<GaugeSegment, String>> seriesList;
  final bool animate;
  final String mode;
  final int data;

  const GaugeChart(this.seriesList,
      {required this.animate, required this.mode, required this.data});

  factory GaugeChart.generateChart(String m, int d) {
    return GaugeChart(
      _createData(m, d),
      // Disable animations for image tests.
      animate: true,
      mode: m,
      data: d,
    );
  }

  @override
  Widget build(BuildContext context) {
    return charts.PieChart<String>(seriesList,
        animate: animate,
        defaultRenderer: charts.ArcRendererConfig(
            arcWidth: MediaQuery.of(context).size.width ~/ 30,
            startAngle: 4 / 5 * 3.1415,
            arcLength: 7 / 5 * 3.1415));
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<GaugeSegment, String>> _createData(
      String mode, int value) {
    late Color dataColor;
    if (mode == "P") {
      dataColor = Colors.pink;
    } else if (mode == "F") {
      dataColor = Colors.orangeAccent;
    } else if (mode == "C") {
      dataColor = Colors.blueAccent;
    }

    late List<GaugeSegment> data = [];

    if (value > 0) {
      data.add(GaugeSegment(
          'data', value, charts.ColorUtil.fromDartColor(dataColor)));
      if (100 - value > 0) {
        data.add(GaugeSegment(
            'max', 100 - value, charts.ColorUtil.fromDartColor(Colors.grey)));
      }
    }

    return [
      charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => segment.color,
        data: data,
      )
    ];
  }
}

/// Sample data type.
class GaugeSegment {
  final String segment;
  final int size;
  final charts.Color color;

  GaugeSegment(this.segment, this.size, this.color);
}
