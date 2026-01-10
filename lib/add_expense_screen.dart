import 'package:flutter/material.dart';
import 'theme/neo_colors.dart';
import 'widgets/neo_button.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = "Food & Dining";
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _categories = [
    {"icon": "🍕", "name": "Food & Dining"},
    {"icon": "🚌", "name": "Transport"},
    {"icon": "🎬", "name": "Entertainment"},
    {"icon": "🛍️", "name": "Shopping"},
    {"icon": "📚", "name": "Education"},
    {"icon": "💊", "name": "Healthcare"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NeoColors.white,
                        border: Border.all(color: NeoColors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: NeoColors.black,
                            offset: const Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, color: NeoColors.black),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Add Expense",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: NeoColors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for centering
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Amount Input
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: NeoColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NeoColors.black, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: NeoColors.black,
                            offset: const Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "AMOUNT",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: NeoColors.gray,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "₹",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: NeoColors.orange,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: NeoColors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: "0",
                                    hintStyle: TextStyle(color: Color(0xFFE9ECEF)),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Categories
                    const Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat["name"];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat["name"]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? NeoColors.blue : NeoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: NeoColors.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoColors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat["icon"], style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(
                                  cat["name"],
                                  style: TextStyle(
                                    color: isSelected ? NeoColors.white : NeoColors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: NeoColors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: NeoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NeoColors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoColors.black,
                            offset: Offset(4, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _descController,
                        style: const TextStyle(
                          color: NeoColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: "What was this for?",
                          hintStyle: TextStyle(color: NeoColors.gray),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Save Button
                    NeoButton(
                      text: "Save Expense",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: NeoColors.green,
                      textColor: NeoColors.white,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
