import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';
import 'package:siangkong_mpos/Store/ReportController.dart';

class LineChartSample1 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  bool isShowingMainData;
  double touchedValue;
  final ReportController manager = Get.put(ReportController());
double yInterval;
  @override
  void initState() {
    super.initState();
    touchedValue = -1;
    isShowingMainData = true;
    manager.setBargraph();
  }

  double _maxY;

  double _minY;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              royalblue,
              hotpink,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 37,
                ),
                const Text(
                  'Sor Siangkong Shop',
                  style: TextStyle(
                      color: limegreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  DateFormat("MMMM").format(manager.dt) + ", " +
                      DateFormat("yyyy").format(manager.dt) + " Sales",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 37,
                ),
                manager.netEarning!=0?Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                    child: FutureBuilder<LineChartData>(
                      future: sampleData1(),
                      builder: (context, snapshot)  {
                        if(snapshot.hasData){
                          return LineChart(
                              snapshot.data
                          );
                        }else if(snapshot.hasError){
                          return Center(child: Text("Error"));
                        }else{
                          return CircularProgressIndicator();
                        }
                      }
                    ),
                  ),
                ):Center(child: Text("No Record")),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Future<LineChartData>sampleData1() async{
    _maxY = manager.daySales
        .reduce((value, element) => value > element ? value : element) / 1000;
    _minY = manager.daySales
        .reduce((value, element) => value < element ? value : element) / 1000;
    yInterval = _maxY == 0 ? 1 : ((_maxY - _minY) / 12).ceilToDouble();
    return LineChartData(
      lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (LineChartBarData barData,
              List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              final FlSpot spot = barData.spots[spotIndex];
              if (spot.x == 0 || spot.x == 6) {
                return null;
              }
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.blue, strokeWidth: 4),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                        radius: 8,
                        color: Colors.white,
                        strokeWidth: 5,
                        strokeColor: color1);
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueAccent,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;

                  return LineTooltipItem(
                    'Date: ${flSpot.x.toInt()}/${manager.dt
                        .month} \nTotal Sales: ${flSpot.y} k \n ${manager
                        .transactions[flSpot.x.toInt() - 1]} transactions',
                    const TextStyle(color: Colors.white,fontSize: 12),
                  );
                }).toList();
              }),
          touchCallback: (LineTouchResponse lineTouch) {
            final desiredTouch = lineTouch.touchInput is! PointerExitEvent &&
                lineTouch.touchInput is! PointerUpEvent;

            if (desiredTouch && lineTouch.lineBarSpots != null) {
              final value = lineTouch.lineBarSpots[0].x;

              if (value == 0 || value == 6) {
                setState(() {
                  touchedValue = -1;
                });
                return null;
              }

              setState(() {
                touchedValue = value;
              });
            } else {
              setState(() {
                touchedValue = -1;
              });
            }
          }),
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            getTextStyles: (value) =>
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            margin: 12,
            getTitles: (value) {
              return value.toInt().toString() + "/" +
                  manager.dt.month.toString();
            },
          interval: manager.daysInMonth ==30? 4.9 :3
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) =>
          const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          getTitles: (value) {

            return '${value}k';

          },
          interval: yInterval,
          margin: 6,
          reservedSize: 40,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 4,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 1,
      maxX: (manager.daysInMonth +1).toDouble(),
      maxY: _maxY.ceilToDouble(),
      minY: _minY.ceilToDouble(),
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    List<FlSpot> spots = [];
    for (var i = 0; i < manager.daySales.length; i++) {
      spots.add(
          FlSpot((i + 1).toDouble(), (manager.daySales[i] / 1000).toDouble()));
    }


    final LineChartBarData lineChartBarData1 = LineChartBarData(

      spots: spots,
      isCurved: false,
      colors: [
        limegreen,
      ],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      lineChartBarData1,

    ];
  }


}
