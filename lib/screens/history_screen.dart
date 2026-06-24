import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {"date": "20 Jun 2026", "total": 250.0, "items": 4},
      {"date": "18 Jun 2026", "total": 480.0, "items": 7},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Shopping History")),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text("₹${order["total"]}"),
              subtitle: Text("${order["items"]} items"),
              trailing: Text(order["date"].toString()),
            ),
          );
        },
      ),
    );
  }
}
