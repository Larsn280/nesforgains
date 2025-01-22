import 'package:flutter/material.dart';
import 'package:nesforgains/widgets/custom_buttons.dart';
import 'package:nesforgains/widgets/custom_snackbar.dart';

class CustomDropdownlist extends StatefulWidget {
  final bool closedropdowns;
  final List<String> dropdownitems;
  final Map<String, Map<String, dynamic>> inputboxitems;
  final Map<String, Map<String, String>> completeexercise;
  final Function(Map<String, Map<String, String>>) onStoreAddedExercises;
  final String defaultdropdowntext;

  const CustomDropdownlist({
    super.key,
    required this.closedropdowns,
    required this.dropdownitems,
    required this.inputboxitems,
    required this.completeexercise,
    required this.defaultdropdowntext,
    required this.onStoreAddedExercises,
  });

  @override
  CustomDropdownlistState createState() => CustomDropdownlistState();
}

class CustomDropdownlistState extends State<CustomDropdownlist> {
  bool _isdropdownshowing = false;
  String _selecteditem = '';
  List<String> allValues = [];
  late String storedmapkey = '';

  void _changedropdownstate(String isdropdownshowing) {
    setState(() {
      widget.inputboxitems[isdropdownshowing]?['isSelected'] =
          !widget.inputboxitems[isdropdownshowing]?['isSelected'];
    });
  }

  void _clearandcloseinputbox() {
    setState(() {
      widget.completeexercise.clear();
      _selecteditem = '';
      print(widget.completeexercise);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _saveTrainingData() async {
    try {
      // Check if the number of keys in completeexercise matches the keys in inputboxitems
      bool hasInvalidField =
          widget.completeexercise.values.any((exerciseDetails) {
        // Check if all the required subkeys ('Reps', 'Sets', 'Weight') exist and are valid
        return widget.inputboxitems.keys.any((key) {
          // Check if the subkey exists in the exercise details
          if (!exerciseDetails.containsKey(key)) {
            return true; // If the subkey doesn't exist, it's invalid
          }

          // Get the value for the subkey
          var value = exerciseDetails[key];

          // Check if the value is '0' (string) or 0 (integer)
          if (value == '0') {
            return true; // If the value is '0', it's invalid
          }

          return false;
        });
      });

      // If there's an invalid field, prevent saving and show an error message
      if (hasInvalidField) {
        CustomSnackbar.showSnackBar(message: 'Please select all fields!');
        // Optionally show an error message to the user
        return;
      }

      // If there are no invalid fields, continue with the save process
      if (widget.completeexercise.isNotEmpty) {
        // Process the selected exercises
        widget.onStoreAddedExercises(widget.completeexercise);
        // Save to the database or perform other actions
        print(widget.completeexercise);
        _clearandcloseinputbox();
      } else {
        print('No exercises selected.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
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
                      widget.completeexercise[item.toString()] = {};
                      storedmapkey = widget.completeexercise.keys.first;
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
                      widget.completeexercise.clear();
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
            children: widget.inputboxitems.entries
                .toList()
                .asMap()
                .entries
                .map((mapEntry) {
              final int index = mapEntry.key + 1; // The index of the entry
              final MapEntry<String, Map<String, dynamic>> entry =
                  mapEntry.value;
              return GestureDetector(
                onTap: () {
                  _changedropdownstate(entry.key);
                },
                child: _buildInputBoxDropdown(
                    dropdownboxnumber: index,
                    boxitem: entry.key,
                    isdropdownshowing: entry.value['isSelected']),
              );
            }).toList(),
          ),
          const SizedBox(
            height: 20.0,
          ),
          CustomButtons.buildElevatedFunctionButton(
              context: context,
              onPressed: () => {_saveTrainingData()},
              text: 'Add Exercise'),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBoxDropdown({
    required String boxitem,
    required bool isdropdownshowing,
    required int dropdownboxnumber,
  }) {
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
              widget.completeexercise[storedmapkey]![boxitem] != null
                  ? Text(
                      '$boxitem: ${widget.completeexercise[storedmapkey]![boxitem]}'
                          .toString())
                  : Text(boxitem),
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
                      setState(() {
                        widget.completeexercise[storedmapkey]![boxitem] =
                            value.toString();
                      });
                      _changedropdownstate(boxitem);
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(value.toString()),
                    ),
                  );
                }).toList(),
              )),
            ),
        ],
      ),
    );
  }
}
