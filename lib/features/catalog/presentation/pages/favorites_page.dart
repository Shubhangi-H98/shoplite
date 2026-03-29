import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // Mocking Favorite List
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Mock count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
              title: const Text("Favorite Product Title", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("₹1,299", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {}, // Remove from favorites logic
              ),
            ),
          );
        },
      ),
    );
  }
}