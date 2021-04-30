import 'package:rango/models/client.dart';
import 'package:rango/models/meals.dart';
import 'package:rango/models/order.dart';

final List<Client> clients = [
  Client(email: 'gabriel@email.com', name: 'Gabriel', phone: "(21)123456789"),
  Client(
      email: "guilherme@email.com", name: 'Guilherme', phone: "(21)123456789"),
  Client(email: 'rebeca@email.com', name: 'Rebeca', phone: "(21)123456789")
];

final List<Meal> quentinhas = [
  Meal(
      name: "Moqueca de banana da terra",
      description: 'Moqueca bem gostosa feita na hora e com banana fresca',
      price: 10,
      sellerId: '1',
      picture:
          "https://conteudo.imguol.com.br/c/entretenimento/02/2020/03/31/moqueca-de-peixe-1585666205541_v2_900x506.jpg.webp",
      sellerName: 'Quentinha Top'),
  Meal(
      name: "Lasanha",
      description: 'Lasanha com bastante molho e recheio, massa natural',
      price: 10,
      picture:
          "https://img.itdg.com.br/tdg/images/recipes/000/000/876/324587/324587_original.jpg?mode=crop&width=710&height=400",
      sellerId: '1',
      sellerName: 'Quentinha Top'),
];

final List<Order> pedidos = [
  Order(
    cliente: clients[0],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
    orderId: 1,
  ),
  Order(
    cliente: clients[1],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
    orderId: 2,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 3,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 4,
  ),
  Order(
    cliente: clients[1],
    quentinha: quentinhas[0],
    reservada: false,
    vendida: false,
    orderId: 5,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 6,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 7,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 8,
  ),
  Order(
    cliente: clients[2],
    quentinha: quentinhas[1],
    reservada: false,
    vendida: false,
    orderId: 9,
  ),
];
