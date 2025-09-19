import 'package:flutter/material.dart';

class PacksPage extends StatefulWidget {
  const PacksPage({super.key});

  @override
  State<PacksPage> createState() => _PacksPageState();
}

class _PacksPageState extends State<PacksPage> {
  String? selectedCategory = "COMBO"; // default dropdown value
  final TextEditingController searchController = TextEditingController();

  // Example pack data (you can replace this with your JSON)
  final List<Map<String, dynamic>> packs = [
    {
      "title": "HD Odia Economy",
      "prices": [
        {"price": "₹ 226.0", "duration": "1 month"},
        {"price": "₹ 676.0", "duration": "3 months"},
        {"price": "₹ 1176.0", "duration": "6 months"},
      ],
    },
    {
      "title": "Bengali Basic",
      "prices": [
        {"price": "₹ 234.0", "duration": "1 month"},
        {"price": "₹ 704.0", "duration": "3 months"},
        {"price": "₹ 1234.0", "duration": "6 months"},
      ],
    },
    {
      "title": "Odia Basic",
      "prices": [
        {"price": "₹ 236.0", "duration": "1 month"},
        {"price": "₹ 686.0", "duration": "3 months"},
        {"price": "₹ 1240.0", "duration": "6 months"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Row(
          children: [
            Image.asset("assets/images/sundirect.png", height: 30),
            const SizedBox(width: 10),
            const Text("Sun Direct"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ["COMBO", "BASE", "ADDON"].map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 10),

            // Search Box
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // re-build UI when searching
              },
              decoration: InputDecoration(
                hintText: "Search by amount or name...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),

            // Packs List
            Expanded(
              child: ListView(
                children: packs
                    .where((pack) =>
                pack["title"]
                    .toString()
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                    pack["prices"].any((p) =>
                        p["price"]
                            .toString()
                            .contains(searchController.text)))
                    .map((pack) {
                  return PackSection(
                    title: pack["title"],
                    prices: List<Map<String, String>>.from(pack["prices"]),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> prices;

  const PackSection({
    super.key,
    required this.title,
    required this.prices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: prices.map((p) {
            return Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text(
                        p["price"]!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(p["duration"]!),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
