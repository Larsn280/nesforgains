import 'package:flutter/material.dart';

class CustomDropdownlist extends StatefulWidget {
  final String defaultText;
  final TextEditingController controller;
  bool multiselectList;
  final List<String> selectList;

  CustomDropdownlist({
    super.key,
    required this.defaultText,
    required this.controller,
    required this.multiselectList,
    required this.selectList,
  });

  @override
  _CustomDropdownlistState createState() => _CustomDropdownlistState();
}

class _CustomDropdownlistState extends State<CustomDropdownlist> {
  bool _isDropdownVisible = false; // Flag to control dropdown visibility

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDropdownVisible =
              !_isDropdownVisible; // Toggle dropdown visibility
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.black54, // Background color
        ),
        child: Column(
          children: [
            // Show the first container only if the dropdown is not visible
            if (!_isDropdownVisible)
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Align items to space out
                children: [
                  // Text or default text aligned to the left
                  Text(
                    widget.controller.text.isEmpty
                        ? widget.defaultText
                        : widget.controller.text,
                    style: const TextStyle(color: Colors.white),
                  ),
                  widget.controller.text.isEmpty
                      ? // Arrow icon aligned to the right
                      const Icon(Icons.arrow_drop_down, color: Colors.white)
                      : const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            // The dropdown list that appears below the container
            if (_isDropdownVisible) // Show dropdown only when the flag is true
              Container(
                width: double.infinity, // Make the dropdown take up full width
                decoration: BoxDecoration(
                  color: Colors.black87, // Dropdown background color
                  // border: Border.all(color: Colors.white),
                  // borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.selectList.map<Widget>((String value) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          widget.controller.text =
                              value; // Update the controller text
                          _isDropdownVisible =
                              false; // Hide dropdown after selection
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
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
