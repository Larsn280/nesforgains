import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final String defaultText;
  final List<T> itemsList;

  const MultiSelectDropdown(
      {super.key, required this.defaultText, required this.itemsList});

  @override
  MultiSelectDropdownState createState() => MultiSelectDropdownState();
}

class MultiSelectDropdownState extends State<MultiSelectDropdown> {
  bool _isDropdownShowing = false;
  String _selectedItem = '';
  List<int> repsRange = List.generate(20, (index) => index + 1);
  List<int> setsRange = List.generate(20, (index) => index + 1);
  List<int> weigthRange = List.generate(300, (index) => index + 1);
  final Map<String, int> _selectedInput = {
    'reps': 0,
    "sets": 0,
    "weigth": 0,
  };

  @override
  Widget build(BuildContext context) {
    return _selectedItem.isEmpty
        ? GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownShowing =
                    !_isDropdownShowing; // Toggle dropdown visibility
              });
            },
            child: !_isDropdownShowing
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    decoration: const BoxDecoration(color: Colors.black54),
                    child: Row(
                      children: [
                        Text(widget.defaultText,
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
                      children: widget.itemsList.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItem = item.toString();
                              _isDropdownShowing = false;
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
        : Container(
            width: MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: const BoxDecoration(
              color: Colors.black87,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      'Input for $_selectedItem',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItem = '';
                        });
                      },
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                _buildRepsSetsWeightDropdown(
                    reps: repsRange, sets: setsRange, weigth: weigthRange),
              ],
            ),
          );
  }

  Widget _buildRepsSetsWeightDropdown(
      {required List<int> reps,
      required List<int> sets,
      required List<int> weigth}) {
    final Map<String, bool> isinputdropdownShowing = {
      'reps': false,
      "sets": false,
      "weigth": false,
    };
    return Row(
      children: [
        isinputdropdownShowing['reps'] == true
            ? Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reps.map<Widget>((item) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedInput['reps'] = item;
                          isinputdropdownShowing['reps'] = false;
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
              )
            : Container(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isinputdropdownShowing['reps'] = true;
                    });
                  },
                  child: Text('Reps'),
                ),
              ),
        const Spacer(),
        Container(
          child: Text('Sets'),
        ),
        const Spacer(),
        Container(
          child: Text('Weigth'),
        ),
      ],
    );
  }
}
