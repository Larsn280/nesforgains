import 'package:flutter/material.dart';

class CustomSearchDropdownlist extends StatefulWidget {
  final TextEditingController controller;
  final String defaulttext;
  final List<String> listitems;

  const CustomSearchDropdownlist({
    super.key,
    required this.controller,
    required this.defaulttext,
    required this.listitems,
  });

  @override
  State<CustomSearchDropdownlist> createState() =>
      CustCustomSearchDropdownlist();
}

class CustCustomSearchDropdownlist extends State<CustomSearchDropdownlist> {
  final _formKey = GlobalKey<FormState>();
  List<String> filteredItems = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredItems = widget.listitems;

    widget.controller.addListener(() {
      setState(() {
        filteredItems = widget.listitems
            .where((item) => item
                .toLowerCase()
                .contains(widget.controller.text.toLowerCase()))
            .toList();
      });
    });

    _focusNode.addListener(() {
      setState(() {}); // Rebuild UI when focus changes
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the FocusNode
    super.dispose();
  }

  Color _toggleCheckCircleColor() {
    if (_focusNode.hasFocus || widget.controller.text.isEmpty) {
      return Colors.transparent;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 12.0),
      decoration: const BoxDecoration(color: Colors.black),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: (value) {
                widget.controller.text = value;
              },
              decoration: InputDecoration(
                hintText: widget.defaulttext,
                hintStyle: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                ),
                suffixIcon: Icon(
                  Icons.check_circle,
                  color: _toggleCheckCircleColor(),
                ),
                border: InputBorder.none,
                enabledBorder:
                    InputBorder.none, // Removes the underline when not focused
                focusedBorder:
                    InputBorder.none, // Removes the underline when focused
              ),
              style: const TextStyle(
                fontSize: 13.0,
              ),
            ),
            if (widget.controller.text.isNotEmpty && _focusNode.hasFocus)
              Column(
                children: filteredItems.map<Widget>((item) {
                  return GestureDetector(
                    onTap: () {
                      widget.controller.text = item.toString();
                      _focusNode.unfocus();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(item),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
