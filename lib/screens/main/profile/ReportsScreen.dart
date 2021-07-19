import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText('Relatório',
            style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor, fontSize: 40.nsp)),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 0.06.wp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    title: Column(
                      children: [
                        AutoSizeText(
                          'Total recebido',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontSize: 32.nsp,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: AutoSizeText(
                              'R\$ 1.239,50',
                              style: GoogleFonts.montserrat(
                                fontSize: 42.nsp,
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    title: Column(
                      children: [
                        AutoSizeText(
                          'Número de clientes',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontSize: 32.nsp,
                          ),
                        ),
                        Expanded(
                            child: Center(
                              child: AutoSizeText(
                                '100',
                                style: GoogleFonts.montserrat(
                                  fontSize: 60.nsp,
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    title: Column(
                      children: [
                        AutoSizeText(
                          'Quentinhas vendidas',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontSize: 32.nsp,
                          ),
                        ),
                        Expanded(
                            child: Center(
                              child: AutoSizeText(
                                '134',
                                style: GoogleFonts.montserrat(
                                  fontSize: 60.nsp,
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    title: Column(
                      children: [
                        AutoSizeText(
                          'Quentinha mais vendida',
                          style: GoogleFonts.montserrat(
                            color: Theme.of(context).accentColor,
                            fontSize: 32.nsp,
                          ),
                        ),
                        Expanded(
                            child: Center(
                              child: AutoSizeText(
                                'Arroz com Feijão',
                                style: GoogleFonts.montserrat(
                                  fontSize: 42.nsp,
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SfCartesianChart(
              zoomPanBehavior: ZoomPanBehavior(
                enablePanning: true,
                enablePinching: true,
                zoomMode: ZoomMode.x
              ),
              primaryXAxis: DateTimeAxis(
                autoScrollingDelta: 7,
                dateFormat: DateFormat('d MMMM', 'pt_BR')
              ),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(locale: 'pt_BR'),
                //interval: 1,
                minimum: 28,
                maximum: 71,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                format: 'point.x\npoint.y'
              ),
              series: <SplineSeries<ChartData, DateTime>>[
                SplineSeries<ChartData, DateTime>(
                  enableTooltip: true,
                  dataSource: <ChartData>[
                    ChartData(DateTime.now(), 35),
                    ChartData(DateTime.now().add(Duration(days: 1)), 28),
                    ChartData(DateTime.now().add(Duration(days: 2)), 34),
                    ChartData(DateTime.now().add(Duration(days: 3)), 32),
                    ChartData(DateTime.now().add(Duration(days: 4)), 40),
                    ChartData(DateTime.now().add(Duration(days: 8)), 70),
                    ChartData(DateTime.now().add(Duration(days: 9)), 70),
                    ChartData(DateTime.now().add(Duration(days: 10)), 70),
                    ChartData(DateTime.now().add(Duration(days: 11)), 70),
                    ChartData(DateTime.now().add(Duration(days: 12)), 70),
                    ChartData(DateTime.now().add(Duration(days: 13)), 70),
                    ChartData(DateTime.now().add(Duration(days: 14)), 70),
                    ChartData(DateTime.now().add(Duration(days: 15)), 70),
                    ChartData(DateTime.now().add(Duration(days: 16)), 70),
                    ChartData(DateTime.now().add(Duration(days: 17)), 70),
                  ],
                  xValueMapper: (ChartData sales, _) => sales.time,
                  yValueMapper: (ChartData sales, _) => sales.total,
                  markerSettings: MarkerSettings(
                    isVisible: true
                  )
                )
              ],
            ),
          ]
        )
      ),
    );
  }
}

class ChartData {
  ChartData(this.time, this.total);
  final DateTime time;
  final int total;
}
