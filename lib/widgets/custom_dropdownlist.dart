import 'package:flutter/material.dart';
import 'package:nesforgains/models/selected_exercise.dart';

class CustomDropdownlist<T> extends StatefulWidget {
  final bool closedropdowns;
  final List<T> dropdownitems;
  final Map<String, Map<String, dynamic>> inputboxitems;
  final String defaultdropdowntext;

  const CustomDropdownlist(
      {super.key,
      required this.closedropdowns,
      required this.dropdownitems,
      required this.inputboxitems,
      required this.defaultdropdowntext});

  @override
  CustomDropdownlistState createState() => CustomDropdownlistState();
}

class CustomDropdownlistState extends State<CustomDropdownlist> {
  bool _isdropdownshowing = false;
  String _selecteditem = '';
  List<String> allValues = [];

  void _changedropdownstate(String isdropdownshowing) {
    setState(() {
      widget.inputboxitems[isdropdownshowing]?['isSelected'] =
          !widget.inputboxitems[isdropdownshowing]?['isSelected'];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _selecteditem.isEmpty
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _isdropdownshowing = !_isdropdownshowing;
                  });
                },
                child: Container(
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
                ),
              )
            : _buildInputBox(),
        if (_isdropdownshowing)
          Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        item.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInputBox() {
    if (allValues.isEmpty) {
      allValues.add(_selecteditem);
    }
    return Container(
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
                      allValues = [];
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
          ),
          const SizedBox(
            height: 12.0,
          ),
          Column(
            children: widget.inputboxitems.entries.map((entry) {
              return GestureDetector(
                onTap: () {
                  _changedropdownstate(entry.key);
                },
                child: _buildInputBoxDropdown(
                    boxitem: entry.key,
                    isdropdownshowing: entry.value['isSelected']),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 40.0,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBoxDropdown(
      {required String boxitem, required bool isdropdownshowing}) {
    final List<int>? values = widget.inputboxitems[boxitem]?['values'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border.all(color: Colors.white, width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(boxitem),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              )
            ],
          ),
          if (isdropdownshowing && values != null)
            SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                  child: Column(
                children: values.map<Widget>((value) {
                  return GestureDetector(
                    onTap: () {
                      allValues.add(value.toString());
                      _changedropdownstate(boxitem);
                      print(allValues);
                    },
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Text(value.toString()),
                          ],
                        )),
                  );
                }).toList(),
              )),
            ),
        ],
      ),
    );
  }
}
