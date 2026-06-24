import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> cart = [];
  double budget = 1000;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  double get total {
    return cart.fold(
      0,
      (sum, item) => sum + (item["price"] * item["quantity"]),
    );
  }

  double get remainingBudget => budget - total;

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(cart));
  }

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');

    if (cartJson != null) {
      setState(() {
        cart.clear();
        cart.addAll(List<Map<String, dynamic>>.from(jsonDecode(cartJson)));
      });
    }
  }

  void addProductFromBarcode(String barcode) {
    final products = {
      "111": {"name": "Milk", "price": 60.0},
      "222": {"name": "Chocolate", "price": 40.0},
      "333": {"name": "Bread", "price": 35.0},
    };

    if (!products.containsKey(barcode)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Product not found")));
      return;
    }

    final product = products[barcode]!;

    final index = cart.indexWhere((item) => item["name"] == product["name"]);

    setState(() {
      if (index >= 0) {
        cart[index]["quantity"]++;
      } else {
        cart.add({
          "name": product["name"],
          "price": product["price"],
          "quantity": 1,
        });
      }
    });

    saveCart();
  }

  void increaseQuantity(int index) {
    setState(() {
      cart[index]["quantity"]++;
    });
    saveCart();
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (cart[index]["quantity"] > 1) {
        cart[index]["quantity"]--;
      } else {
        cart.removeAt(index);
      }
    });
    saveCart();
  }

  void setBudgetDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Set Budget"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter budget amount"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  budget = double.tryParse(controller.text) ?? budget;
                });

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (total / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ScanCart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              setState(() {
                cart.clear();
              });
              saveCart();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome 👋",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Cart Value",
                  style: TextStyle(color: Colors.white),
                ),

                const SizedBox(height: 10),

                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "${cart.length} Items",
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  "Budget: ₹${budget.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.white),
                ),

                Text(
                  remainingBudget >= 0
                      ? "Remaining: ₹${remainingBudget.toStringAsFixed(0)}"
                      : "Exceeded: ₹${(-remainingBudget).toStringAsFixed(0)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                LinearProgressIndicator(value: progress),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: setBudgetDialog,
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text("Set Budget"),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 80),
                        SizedBox(height: 20),
                        Text(
                          "Your cart is empty",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text("Scan a product to begin"),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(
                                  name: item["name"],
                                  price: item["price"],
                                ),
                              ),
                            );
                          },

                          leading: CircleAvatar(child: Text(item["name"][0])),

                          title: Text(item["name"]),

                          subtitle: Text("₹${item["price"]}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  decreaseQuantity(index);
                                },
                              ),

                              Text("${item["quantity"]}"),

                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                onPressed: () {
                                  increaseQuantity(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Checkout Total: ₹${total.toStringAsFixed(0)}",
                        ),
                      ),
                    );
                  },
                  child: Text("Checkout ₹${total.toStringAsFixed(0)}"),
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final barcode = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );

          if (barcode != null) {
            addProductFromBarcode(barcode.toString());
          }
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("Scan"),
      ),
    );
  }
}
