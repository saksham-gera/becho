import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  CartItem(
                    imageUrl: 'https://via.placeholder.com/60x60.png?text=Xbox+Series+X',
                    title: 'Xbox series X',
                    subtitle: '1 TB',
                    price: 570.00,
                  ),
                  CartItem(
                    imageUrl: 'https://via.placeholder.com/60x60.png?text=Wireless+Controller',
                    title: 'Wireless Controller',
                    subtitle: 'Blue',
                    price: 77.00,
                  ),
                  CartItem(
                    imageUrl: 'https://via.placeholder.com/60x60.png?text=Razer+Kaira+Pro',
                    title: 'Razer Kaira Pro',
                    subtitle: 'Green',
                    price: 153.00,
                  ),
                ],
              ),
            ),
            PromoCodeSection(),
            const SizedBox(height: 16),
            TotalSection(),
            const SizedBox(height: 16),
            CheckoutButton(),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final double price;

  const CartItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.error,
              size: 60,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "\$$price",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.black),
                onPressed: () {},
              ),
              const Text('1', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PromoCodeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Promo code applied',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.green),
              ),
            ],
          ),
          const Text(
            'ADJ3AK',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class TotalSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TotalRow(label: "Subtotal:", amount: "\$800.00"),
        TotalRow(label: "Delivery Fee:", amount: "\$5.00"),
        TotalRow(label: "Discount:", amount: "40%"),
      ],
    );
  }
}

class TotalRow extends StatelessWidget {
  final String label;
  final String amount;

  const TotalRow({
    Key? key,
    required this.label,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          Text(amount, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CheckoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text(
        "Checkout for \$480.00",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}