import 'package:flutter/material.dart';

class CustomDropdownlist<T> extends StatefulWidget {
  final bool closedropdowns;
  final List<T> dropdownitems;
  final String defaultdropdowntext;

  const CustomDropdownlist(
      {super.key,
      required this.closedropdowns,
      required this.dropdownitems,
      required this.defaultdropdowntext});

  @override
  CustomDropdownlistState createState() => CustomDropdownlistState();
}

class CustomDropdownlistState extends State<CustomDropdownlist> {
  bool _isdropdownshowing = false;
  String _selecteditem = '';

  @override
  Widget build(BuildContext context) {
    return _selecteditem.isEmpty
        ? GestureDetector(
            onTap: () {
              setState(() {
                _isdropdownshowing = !_isdropdownshowing;
              });
            },
            child: !_isdropdownshowing
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: Row(
                      children: [
                        Text(widget.defaultdropdowntext,
                            style: const TextStyle(color: Colors.white)),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.dropdownitems.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selecteditem = item.toString();
                              _isdropdownshowing = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              item.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          )
        : _buildInputBox();
  }

  Widget _buildInputBox() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.circular(30.0)),
      child: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.cancel),
              Text('Input for $_selecteditem',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0)),
              GestureDetector(
                onTap: () {
                  setState(
                    () {
                      _selecteditem = '';
                      _isdropdownshowing = false;
                    },
                  );
                },
                child: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
