import 'package:flutter/material.dart';
import 'package:rango/models/order.dart';

class ManageOrder extends StatelessWidget {
  final Order order;
  final bool isEdit;

  ManageOrder({
    this.order,
    @required this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              isEdit ? "Edite a quentinha" : "E aí, o que tem hoje?",
            ),
            Card(
              child: Row(
                children: [
                  Icon(Icons.photo),
                  if (order == null)
                    Column(
                      children: [
                        Text("Nome do prato"),
                        Text("Descrição"),
                        Text("Valor"),
                        Text("Quantidade disponível"),
                      ],
                    ),
                  if (order != null)
                    Column(
                      children: [
                        Text(order.quentinha.name),
                        if (order.quentinha.description != null &&
                            order.quentinha.description != "")
                          Text(order.quentinha.description),
                        Text(order.quentinha.price.toString()),
                        Text("2"),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
