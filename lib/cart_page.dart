import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'product.dart';
import 'detail_page.dart';
import 'get_cart_id.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    getCartId(_loadData);
  }

  //List<dynamic> _products = [];
  String nextPage = "";
  int loadedPage = 1;

  List<Result> _allProducts = [];
  double cenaSpolu = 0;

  void _removeItem(String id) {
    setState(() => _allProducts.removeWhere((item) => item.id == id));
  }

  void _placeOrder() {
    getCartIdPlaceOrder(_placeOrderHttp);
    setState(() {
      _allProducts = [];
    });
  }

  void _placeOrderHttp(String idCart) async {
    var res = await http.post(
      Uri.parse(
          'http://10.0.2.2/holes/dia_eshop/web/Admin/index.php?action=objednat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(
        <String, String>{'id_cart': idCart},
      ),
    );

    print(res.body);
  }

  void _loadData(String cartId) async {
    var url = Uri(
      scheme: "http",
      host: "10.0.2.2",
      path: "/holes/dia_eshop/web/Admin/index.php",
      queryParameters: {"action": "kosik", "cart_id": cartId},
    );

    var res = await http.get(url);
    var json = convert.jsonDecode(res.body) as Map<String, dynamic>;

    var products;

    if (json['results'] != null) {
      products = Product.fromJson(json);
    }

    nextPage = "stop";

    setState(() {
      if (json['results'] != null) {
        _allProducts = products.results;

        cenaSpolu = json['cena_spolu'].toDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showActions: false,
      ),
      body: _allProducts.isEmpty
          ? Container(
              margin: const EdgeInsets.only(top: 150),
              child: Image.asset('assets/files/empty_cart.png'),
            )
          : ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Shopping Cart",
                            style: TextStyle(fontSize: 26),
                          ),
                        ),
                        Text(
                          _allProducts.length.toString() + " items ",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "(" + cenaSpolu.toString() + "€)",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _allProducts.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CartItem(
                      removeItem: _removeItem,
                      productDetail: _allProducts[index],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.teal),
                      ),
                      onPressed: () => _placeOrder(),
                      child: const Text(
                        'Place order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Result productDetail;
  final ValueChanged<String> removeItem;

  const CartItem({
    Key? key,
    required this.productDetail,
    required this.removeItem,
  }) : super(key: key);

  void _removeFromCart(String idProduct) {
    getCartIdRemoveFromCart(_removeFromCartHttp, idProduct);
  }

  void _removeFromCartHttp(String idProduct, String idCart) async {
    final res = await http.post(
      Uri.parse(
          'http://10.0.2.2/holes/dia_eshop/web/Admin/index.php?action=odstranit_z_kosika'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: convert.jsonEncode(<String, String>{
        'id_product': idProduct,
        'id_cart': idCart,
      }),
    );

    if (res.body == "1") {
      removeItem(idProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<DetailPage>(
          builder: (BuildContext context) =>
              DetailPage(productDetail: productDetail),
        ),
      ),
      child: Container(
        height: 100,
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(5),
              child: Image.network(
                'http://10.0.2.2/holes/dia_eshop/files/products/' +
                    productDetail.image,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(7),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        productDetail.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Text(
                          "Price: ",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          productDetail.price + "€",
                          style: TextStyle(fontSize: 18, color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Text(
                          "Velkost: ",
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        Text(
                          "L",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 5),
                child: IconButton(
                  onPressed: () => _removeFromCart(productDetail.id),
                  color: Colors.teal,
                  icon: const Icon(Icons.close, size: 30),
                  tooltip: 'Delete item from cart',
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      ),
    );
  }
}
