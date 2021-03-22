import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';

final List<Client> clients = [
  Client(email: 'gabriel@email.com', name: 'Gabriel'),
  Client(email: "guilherme@email.com", name: 'Guilherme'),
  Client(email: 'rebeca@email.com', name: 'Rebeca')
];

final List<Meal> quentinhas = [
  Meal(
      name: "Moqueca de banana da terra",
      description: '',
      price: 10,
      sellerId: '1',
      sellerName: 'Quentinha Top'),
  Meal(
      name: "Lasanha",
      description: '',
      price: 10,
      sellerId: '1',
      sellerName: 'Quentinha Top'),
];

final List<Order> pedidos = [
  Order(
    cliente: clients[0],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[1],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[1],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
  ),
];
