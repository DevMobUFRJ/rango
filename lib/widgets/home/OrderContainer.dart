import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:rango/models/order.dart';
import 'package:rango/resources/repository.dart';
import 'package:rango/screens/main/home/ClientProfile.dart';
import 'package:rango/utils/string_formatters.dart';

class OrderContainer extends StatefulWidget {
  final Order pedido;

  OrderContainer(this.pedido);

  @override
  _OrderContainerState createState() => _OrderContainerState();
}

class _OrderContainerState extends State<OrderContainer> {
  void _cancelOrder() {
    final String cancelText = widget.pedido.status != 'sold'
        ? 'Deseja realmente cancelar esta reserva?'
        : 'Deseja apagar esse pedido permanentemente do histórico?';
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 0.1.wp),
        backgroundColor: Color(0xFFF9B152),
        actionsPadding: EdgeInsets.all(10),
        contentPadding: EdgeInsets.only(
          top: 20,
          left: 24,
          right: 24,
          bottom: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              //TODO Chamar firestore para cancelar, fazer através de uma transaction para incrementar quantity caso status: reserved ou sold
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Sim',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontSize: 34.nsp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Não',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                color: Colors.white,
                fontSize: 34.nsp,
              ),
            ),
          ),
        ],
        title: Text(
          'Cancelando reserva',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 38.ssp,
          ),
        ),
        content: Text(
          cancelText,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 28.nsp,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0.04.wp),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: widget.pedido.status == 'sold' ? Colors.grey : Color(0xFFF9B152),
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
                              //TODO Mudar pra pegar o client pelo id
                              screen: ClientProfile(widget.pedido.clientId),
                              withNavBar: false,
                            ),
                            child: AutoSizeText(
                              widget.pedido.clientName,
                              overflow: TextOverflow.ellipsis,
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
                          AutoSizeText(
                            '${widget.pedido.quantity}x ${widget.pedido.mealName}',
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 26.nsp,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          AutoSizeText(
                            'Valor total: ${intToCurrency(widget.pedido.quantity * widget.pedido.price)}',
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
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.white),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    checkColor: widget.pedido.status == 'sold'
                                        ? Colors.grey
                                        : Color(0xFFF9B152),
                                    activeColor: Colors.white,
                                    value: widget.pedido.status == 'reserved' || widget.pedido.status == 'sold',
                                    onChanged: (reserved) async {
                                      try {
                                        await Repository.instance.reserveOrderTransaction(widget.pedido);
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 20),
                                              child: Text(
                                                e.toString(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            backgroundColor: Theme.of(context).errorColor,
                                          ),
                                        );
                                      }
                                    },
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
                                data: ThemeData(
                                    unselectedWidgetColor: Colors.white),
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    checkColor: widget.pedido.status == 'sold'
                                        ? Colors.grey
                                        : Color(0xFFF9B152),
                                    activeColor: Colors.white,
                                    value: widget.pedido.status == 'sold',
                                    onChanged: (sold) {
                                      if (sold) Repository.instance.sellOrder(widget.pedido.id);
                                    },
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.red[400],
              ),
              child: GestureDetector(
                onTap: () => _cancelOrder(),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}