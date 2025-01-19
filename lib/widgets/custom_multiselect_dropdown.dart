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

  // Track dropdown visibility for each category
  final Map<String, bool> _isInputDropdownShowing = {
    'reps': false,
    'sets': false,
    'weigth': false,
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
                          _selectedInput['reps'] = 0;
                          _selectedInput['sets'] = 0;
                          _selectedInput['weigth'] = 0;
                          _isInputDropdownShowing['reps'] = false;
                          _isInputDropdownShowing['sets'] = false;
                          _isInputDropdownShowing['weigth'] = false;
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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reps Dropdown
          _isInputDropdownShowing['reps'] == false
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isInputDropdownShowing['sets'] = false;
                      _isInputDropdownShowing['weigth'] = false;
                      _isInputDropdownShowing['reps'] =
                          !(_isInputDropdownShowing['reps'] ?? false);
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1.0)),
                    child: Row(
                      children: [
                        Text(
                          'Reps: ${_selectedInput['reps']}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10.0),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              :
              // If dropdown is visible for reps
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.white, width: 1.0)),
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: reps.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedInput['reps'] = item;
                              _isInputDropdownShowing['reps'] = false;
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
                ),
          const Spacer(),

          // Sets Dropdown
          _isInputDropdownShowing['sets'] == false
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isInputDropdownShowing['reps'] = false;
                      _isInputDropdownShowing['weigth'] = false;
                      _isInputDropdownShowing['sets'] =
                          !(_isInputDropdownShowing['sets'] ?? false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width * 0.25,
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1.0)),
                    child: Row(
                      children: [
                        Text(
                          'Sets: ${_selectedInput['sets']}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10.0),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              :
              // If dropdown is visible for sets
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.white, width: 1.0)),
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: sets.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedInput['sets'] = item;
                              _isInputDropdownShowing['sets'] = false;
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
                ),
          const Spacer(),

          // Weight Dropdown
          _isInputDropdownShowing['weigth'] == false
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isInputDropdownShowing['reps'] = false;
                      _isInputDropdownShowing['sets'] = false;
                      _isInputDropdownShowing['weigth'] =
                          !(_isInputDropdownShowing['weigth'] ?? false);
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: Colors.white, width: 1.0)),
                    width: MediaQuery.of(context).size.width * 0.25,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          'Weight: ${_selectedInput['weigth']}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10.0),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                )
              :
              // If dropdown is visible for weight
              Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                      color: Colors.black87,
                      border: Border.all(color: Colors.white, width: 1.0)),
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: weigth.map<Widget>((item) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedInput['weigth'] = item;
                              _isInputDropdownShowing['weigth'] = false;
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
                ),
        ],
      ),
    );
  }
}
