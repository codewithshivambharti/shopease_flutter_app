import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/models.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext ctx) {
    final p = ctx.watch<OrderProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.orders.isEmpty
              ? const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No orders yet',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Your orders will appear here',
                          style: TextStyle(color: Colors.grey))
                    ]))
              : RefreshIndicator(
                  onRefresh: p.fetchOrders,
                  child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: p.orders.length,
                      itemBuilder: (c, i) => _OrderCard(order: p.orders[i]))),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});
  Color get _sc {
    switch (order.status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final op = ctx.read<OrderProvider>();
    return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(order.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12))
                ]),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: _sc.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(order.status.displayName,
                        style: TextStyle(
                            color: _sc,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
              ]),
              const Divider(height: 20),
              ...order.items.take(2).map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Text('${i.quantity}x ',
                        style: const TextStyle(color: Colors.grey)),
                    Expanded(
                        child: Text(i.productName,
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('₹${i.totalPrice.toStringAsFixed(0)}'),
                  ]))),
              if (order.items.length > 2)
                Text('+${order.items.length - 2} more',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('₹${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(ctx).colorScheme.primary,
                          fontSize: 16)),
                  Text('via ${order.paymentMethod}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11))
                ]),
                if (order.status == OrderStatus.confirmed ||
                    order.status == OrderStatus.pending)
                  TextButton(
                      onPressed: () => showDialog(
                          context: ctx,
                          builder: (c) => AlertDialog(
                                  title: const Text('Cancel Order?'),
                                  content: const Text('Cancel this order?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(c),
                                        child: const Text('No')),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        onPressed: () {
                                          op.cancelOrder(order.id);
                                          Navigator.pop(c);
                                        },
                                        child: const Text('Cancel Order'))
                                  ])),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Cancel')),
              ]),
            ])));
  }
}
