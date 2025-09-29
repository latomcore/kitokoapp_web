import 'package:flutter/material.dart';

class CardItem extends StatefulWidget {
  final String loanLimit; // Display loan limit
  final String currency; // Display currency
  final bool isSelected; // New parameter for selection state
  final VoidCallback onSelect; // Callback to handle selection

  const CardItem({
    super.key,
    required this.loanLimit,
    required this.currency,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  // State for showing/hiding loan limit
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSelect, // Trigger selection callback on tap
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C6DB2), Color(0xFF3C4B9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: widget.isSelected
              ? Border.all(color: Colors.lightBlue, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan limit and hide/unhide functionality
            Row(
              children: [
                const Text(
                  'Loan Limit:',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHidden = !_isHidden; // Toggle hide/unhide state
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isHidden ? 'Hide' : 'Unhide',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Display loan limit (hidden or visible)
            Text(
              _isHidden ? '••••' : '${widget.currency} ${widget.loanLimit}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
