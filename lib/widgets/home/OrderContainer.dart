import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/screens/main/home/ClientProfile.dart';

class OrderContainer extends StatefulWidget {
  final Order pedido;
  final void Function({bool value}) reservadoOnChange;
  final void Function({bool value}) vendidoOnChange;

  OrderContainer(
    this.pedido,
    this.reservadoOnChange,
    this.vendidoOnChange,
  );

  @override
  _OrderContainerState createState() => _OrderContainerState();
}

class _OrderContainerState extends State<OrderContainer> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.04.wp),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: widget.pedido.vendida ? Colors.grey : Color(0xFFF9B152),
          child: ConstrainedBox(
            constraints: new BoxConstraints(
              minHeight: 0.12.hp,
              minWidth: 0.8.wp,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 0.4.wp,
                  margin: EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => pushNewScreen(
                          context,
                          screen: ClientProfile(widget.pedido.cliente),
                        ),
                        child: AutoSizeText(
                          widget.pedido.cliente.name,
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 29.nsp,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: widget.pedido.quentinhas.length,
                        itemBuilder: (ctx, index) => AutoSizeText(
                          '${widget.pedido.quentinhas[index].quantidade}x ${widget.pedido.quentinhas[index].quentinha.name}',
                          style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 26.nsp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2),
                      AutoSizeText(
                        'Valor total: R\$${widget.pedido.valorTotal}',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 26.nsp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 0.06.wp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Theme(
                            data:
                                ThemeData(unselectedWidgetColor: Colors.white),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                checkColor: widget.pedido.vendida
                                    ? Colors.grey
                                    : Color(0xFFF9B152),
                                activeColor: Colors.white,
                                value: widget.pedido.reservada,
                                onChanged: (valor) =>
                                    widget.reservadoOnChange(value: valor),
                              ),
                            ),
                          ),
                          Text(
                            "Reservado",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.005.hp),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Theme(
                            data:
                                ThemeData(unselectedWidgetColor: Colors.white),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                checkColor: widget.pedido.vendida
                                    ? Colors.grey
                                    : Color(0xFFF9B152),
                                activeColor: Colors.white,
                                value: widget.pedido.vendida,
                                onChanged: (valor) =>
                                    widget.vendidoOnChange(value: valor),
                              ),
                            ),
                          ),
                          Text(
                            "Vendido",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
