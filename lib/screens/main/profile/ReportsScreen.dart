import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rango/models/order.dart';
import 'package:rango/models/seller.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/utils/string_formatters.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportsScreen extends StatelessWidget {
  final Seller seller;

  ReportsScreen(this.seller);

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
        child: SingleChildScrollView(
          child: StreamBuilder(
            stream: Repository.instance.getSoldOrdersFromSeller(seller.id),
            builder: (context, AsyncSnapshot<QuerySnapshot<Order>> ordersSnapshot) {
              int totalReceived = 0;
              int totalClients = 0;
              int mealsSold = 0;
              String mostSoldMeal = '-';

              if (!ordersSnapshot.hasData || ordersSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 0.5.hp,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                );
              }

              if (ordersSnapshot.data.docs.isNotEmpty) {
                totalReceived = ordersSnapshot.data.docs
                    .map((e) => e.data().quantity * e.data().price)
                    .fold(0, (p, c) => p + c);

                totalClients = ordersSnapshot.data.docs
                    .map((e) => e.data().clientId)
                    .toSet()
                    .length;

                mealsSold = ordersSnapshot.data.docs
                    .map((e) => e.data().quantity)
                    .fold(0, (p, c) => p + c);

                Map<String, int> mealsMap = {};
                ordersSnapshot.data.docs
                    .forEach((e) => mealsMap.update(
                    e.data().mealName,
                        (x) => x + e.data().quantity,
                    ifAbsent: () => e.data().quantity
                ));
                mostSoldMeal = mealsMap.entries.reduce((curr, next) => curr.value.compareTo(next.value) > 0 ? curr : next).key;
              }

              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      physics: NeverScrollableScrollPhysics(),
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
                                        intToCurrency(totalReceived),
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
                                        totalClients.toString(),
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
                                        mealsSold.toString(),
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
                                        mostSoldMeal,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 34.nsp,
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
                    Card(
                      child: _buildChart(context, ordersSnapshot.data.docs),
                    ),
                  ]
              );
            },
          ),
        )
      ),
    );
  }

  Widget _buildChart(context, List<QueryDocumentSnapshot<Order>> orders) {
    if (orders.isNotEmpty) {
      Map<DateTime, double> chartMap = {};

      orders.forEach((e) {
        var orderTime = e.data().requestedAt.toDate();
        return chartMap.update(
            DateTime(orderTime.year, orderTime.month, orderTime.day),
                (x) => x + (e.data().quantity * e.data().price)/100,
            ifAbsent: () => (e.data().quantity * e.data().price)/100
        );
      });

      double minTotal = chartMap.values.reduce(min);
      double maxTotal = chartMap.values.reduce(max);

      return SfCartesianChart(
        title: ChartTitle(
            text: 'Total recebido por dia',
            alignment: ChartAlignment.near,
            textStyle: GoogleFonts.montserrat(
              color: Theme.of(context).accentColor,
              fontSize: 30.nsp,
            )
        ),
        zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true,
            enablePinching: true,
            zoomMode: ZoomMode.x
        ),
        margin: EdgeInsets.only(top: 20, right: 20, bottom: 10, left: 20),
        primaryXAxis: DateTimeAxis(
            autoScrollingDelta: 7,
            dateFormat: DateFormat('d MMMM', 'pt_BR'),
            edgeLabelPlacement: EdgeLabelPlacement.hide,
            plotOffset: 10
        ),
        primaryYAxis: NumericAxis(
            numberFormat: NumberFormat.simpleCurrency(locale: 'pt_BR'),
            plotOffset: 10,
            minimum: minTotal,
            maximum: maxTotal
        ),
        tooltipBehavior: TooltipBehavior(
            enable: true,
            duration: 5000,
            header: '',
            format: 'point.x\npoint.y'
        ),
        series: <SplineSeries<MapEntry<DateTime, double>, DateTime>>[
          SplineSeries<MapEntry<DateTime, double>, DateTime>(
              enableTooltip: true,
              dataSource: <MapEntry<DateTime, double>>[
                ...chartMap.entries
              ],
              xValueMapper: (MapEntry<DateTime, double> sales, _) => sales.key,
              yValueMapper: (MapEntry<DateTime, double> sales, _) => sales.value,
              markerSettings: MarkerSettings(
                  isVisible: true
              )
          )
        ],
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              'Total recebido por dia',
              textAlign: TextAlign.left,
              style: GoogleFonts.montserrat(
                color: Theme.of(context).accentColor,
                fontSize: 32.nsp,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: AutoSizeText(
                  'Venda sua primeira quentinha para começar a mostrar este gráfico!',
                  style: GoogleFonts.montserrat(
                    fontSize: 30.nsp,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}