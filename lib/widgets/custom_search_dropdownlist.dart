import 'package:flutter/material.dart';

class CustomSearchDropdownList extends StatefulWidget {
  final String? errorMessage;
  final bool isNumeric;
  final TextEditingController controller;
  final bool hasBorder;
  final String defaultText;
  final List<String> listItems;
  final ValueChanged<String?>? onErrorChanged;

  const CustomSearchDropdownList({
    super.key,
    required this.errorMessage,
    required this.isNumeric,
    required this.controller,
    required this.hasBorder,
    required this.defaultText,
    required this.listItems,
    this.onErrorChanged,
  });

  @override
  State<CustomSearchDropdownList> createState() =>
      _CustomSearchDropdownListState();
}

class _CustomSearchDropdownListState extends State<CustomSearchDropdownList> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<String> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.listItems;

    _searchController.addListener(() {
      setState(() {
        _filteredItems = widget.listItems
            .where((item) => item
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });

    _focusNode.addListener(() {
      setState(() {}); // Trigger rebuild when focus changes
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double _parseInputToDouble() {
    final input = _searchController.text;
    final doubleValue = double.tryParse(input);
    final intValue = int.tryParse(input);

    if (doubleValue != null) {
      return doubleValue;
    }
    if (intValue != null) {
      return intValue.toDouble();
    }
    return 0.0;
  }

  Color _getCheckCircleColor() {
    if (_focusNode.hasFocus || _searchController.text.isEmpty) {
      return Colors.transparent;
    }
    if (widget.isNumeric && _parseInputToDouble() == 0) {
      return Colors.transparent;
    }
    if (!widget.isNumeric && _searchController.text.length < 2) {
      return Colors.transparent;
    }
    widget.controller.text = _searchController.text;

    return Colors.green;
  }

  BoxDecoration _getBorderDecoration() {
    if (widget.hasBorder) {
      return BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 1.0),
      );
    }
    return const BoxDecoration(color: Colors.black);
  }

  void _validateInput() {
    if (widget.isNumeric && _parseInputToDouble() == 0.0) {
      widget.onErrorChanged?.call('Vänligen ange giltigt vikt');
    } else if (!widget.isNumeric && _searchController.text.length < 2) {
      widget.onErrorChanged?.call('Vänligen ange mins två tecken');
    } else if (widget.isNumeric && _parseInputToDouble() != 0.0) {
      widget.controller.text = _searchController.text;
      widget.onErrorChanged?.call(null);
    } else {
      widget.onErrorChanged?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 12.0),
      decoration: _getBorderDecoration(),
      child: Column(
        children: [
          TextFormField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (_) => _validateInput(),
            decoration: InputDecoration(
              hintText: widget.defaultText,
              hintStyle: const TextStyle(
                fontSize: 13.0,
                color: Colors.grey,
              ),
              suffixIcon: Icon(
                Icons.check_circle,
                size: 23.0,
                color: _getCheckCircleColor(),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 13.0,
              color: Colors.white,
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
          if (_searchController.text.isNotEmpty && _focusNode.hasFocus)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: SingleChildScrollView(
                child: Column(
                  children: _filteredItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        _searchController.text = item;
                        widget.onErrorChanged?.call(null);
                        _focusNode.unfocus();
                      },
                      child: SizedBox(
                        height: 25,
                        width: MediaQuery.of(context).size.width,
                        child: Text(item),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
