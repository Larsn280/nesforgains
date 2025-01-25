import 'package:flutter/material.dart';

class CustomSearchDropdownlist extends StatefulWidget {
  final String? errormessage;
  final bool isnumeric;
  final TextEditingController controller;
  final bool hasboarder;
  final String defaulttext;
  final List<String> listitems;

  const CustomSearchDropdownlist({
    super.key,
    required this.errormessage,
    required this.isnumeric,
    required this.controller,
    required this.hasboarder,
    required this.defaulttext,
    required this.listitems,
  });

  @override
  State<CustomSearchDropdownlist> createState() =>
      CustCustomSearchDropdownlist();
}

class CustCustomSearchDropdownlist extends State<CustomSearchDropdownlist> {
  final _controller = TextEditingController();
  List<String> _filteredItems = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.listitems;

    _controller.addListener(() {
      setState(() {
        _filteredItems = widget.listitems
            .where((item) =>
                item.toLowerCase().contains(_controller.text.toLowerCase()))
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

  double _checkIfDouble() {
    String input = _controller.text;

    double? doublevalue = double.tryParse(input) ?? 0;
    int? intvalue = int.tryParse(input) ?? 0;
    double? finalvalue = 0.0;

    if (doublevalue != 0) {
      finalvalue = doublevalue;
    }
    if (intvalue != 0) {
      finalvalue = double.tryParse('$intvalue.${0}');
    }

    return finalvalue!;
  }

  Color _toggleCheckCircleColor() {
    if (_focusNode.hasFocus || _controller.text.isEmpty) {
      return Colors.transparent;
    }
    if (widget.isnumeric && _checkIfDouble() == 0) {
      return Colors.transparent;
    }
    setState(() {
      widget.controller.text = _controller.text;
    });
    return Colors.green;
  }

  BoxDecoration _isboardershowing() {
    if (widget.hasboarder == true) {
      return BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 1.0));
    }
    return const BoxDecoration(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 12.0),
          decoration: _isboardershowing(),
          child: Column(
            children: [
              TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (value) {
                  _controller.text = value;
                },
                decoration: InputDecoration(
                  hintText: widget.defaulttext,
                  hintStyle: const TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey,
                  ),
                  suffixIcon: Icon(
                    Icons.check_circle,
                    size: 23.0,
                    color: _toggleCheckCircleColor(),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder
                      .none, // Removes the underline when not focused
                  focusedBorder:
                      InputBorder.none, // Removes the underline when focused
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
              if (_controller.text.isNotEmpty && _focusNode.hasFocus)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 100, // Set the maximum height here
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _filteredItems.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            _controller.text = item.toString();
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
                )
            ],
          ),
        ),
        if (widget.isnumeric &&
            _checkIfDouble() == 0.0 &&
            widget.errormessage != null &&
            !_focusNode.hasFocus)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.errormessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ),
        if (!widget.isnumeric &&
            widget.controller.text.isEmpty &&
            widget.errormessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.errormessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12.0),
            ),
          ),
      ],
    );
  }
}
