import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Store/ReportController.dart';

class PieChartCategory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State {
  int touchedIndex;
  List colors = [royalblue, limegreen, color1, violet, hotpink, Colors.grey];
  final ReportController manager = Get.put(ReportController());
  var formatter = NumberFormat("#,##0.00", "en_US");
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
            width: 180
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                    pieTouchData:
                        PieTouchData(touchCallback: (pieTouchResponse) {
                      setState(() {
                        final desiredTouch = pieTouchResponse.touchInput
                                is! PointerExitEvent &&
                            pieTouchResponse.touchInput is! PointerUpEvent;
                        if (desiredTouch &&
                            pieTouchResponse.touchedSection != null) {
                          touchedIndex = pieTouchResponse
                              .touchedSection.touchedSectionIndex;
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    }),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius:  80,
                    sections: showingSections()),
              ),
            ),
          ),
          const SizedBox(
            width: 200,
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
                itemCount: manager.categorySale.length,
                itemBuilder: (context, index) {
                  return Indicator(
                    color: colors[index],
                    text: manager.categorySale[index].category_name,
                    isSquare: true,
                  );
                }),
          ),

        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    if(manager.categorySale.length>5){
      manager.cleanPieChart();
    }
    return List.generate(manager.categorySale.length, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 15;
      final double radius = isTouched ? 120 : 80;
      return PieChartSectionData(
        color: colors[i],
        value: manager.categorySale[i].percentage < 2? 2: manager.categorySale[i].percentage,
        title: manager.categorySale[i].percentage.toStringAsFixed(2) + '%',
        radius: radius,
        badgePositionPercentageOffset: 1.5,
        badgeWidget: Text(formatter.format(manager.categorySale[i].total) + " THB",style: h4,),
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}
