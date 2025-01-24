import 'package:flutter/material.dart';

class CustomDropdownlistnew extends StatefulWidget {
  final TextEditingController controller;
  final bool hasboarder;
  final String defaulttext;
  final List<String> listitems;

  const CustomDropdownlistnew({
    super.key,
    required this.controller,
    required this.hasboarder,
    required this.defaulttext,
    required this.listitems,
  });

  @override
  State<CustomDropdownlistnew> createState() => CustomDropdownlistnewState();
}

class CustomDropdownlistnewState extends State<CustomDropdownlistnew> {
  bool isdropdiwnshowing = false;

  BoxDecoration _isboardershowing() {
    if (widget.hasboarder == true) {
      return BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white, width: 1.0));
    }
    return const BoxDecoration(color: Colors.black);
  }

  void _toggledropdown() {
    setState(() {
      isdropdiwnshowing = !isdropdiwnshowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: _isboardershowing(),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              _toggledropdown();
            },
            child: Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 13.0),
                width: MediaQuery.of(context).size.width,
                child: widget.controller.text.isEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.defaulttext,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.controller.text),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        ],
                      )),
          ),
          if (isdropdiwnshowing)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 100, // Set the maximum height here
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: widget.listitems.map<Widget>((item) {
                    return GestureDetector(
                      onTap: () {
                        widget.controller.text = item;
                        _toggledropdown();
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
