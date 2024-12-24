import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomRadioWidget extends StatefulWidget {
  final Function(int) valueChanged;
  final int initialValue;

  // constructor for custom radio button widget
  const CustomRadioWidget({Key? key, required this.valueChanged, this.initialValue = 0}) : super(key: key);

  @override
  State createState() => _CustomRadioWidgetState();
}

class _CustomRadioWidgetState extends State<CustomRadioWidget> {
  int _value = 0;
  List<Map<String, dynamic>> denomData = [];

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _loadDenomData();
  }

  // Load denomData from session
  Future<void> _loadDenomData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? denomDataString = prefs.getString('denomData');
    String? denomUnsoldString = prefs.getString('denomUnsold');

    // Initialize denomData list
  List<Map<String, dynamic>> tempDenomData = [];

  if (denomDataString != null) {
    // Parse denomData from session
    tempDenomData = List<Map<String, dynamic>>.from(jsonDecode(denomDataString));
  }

  if (denomUnsoldString != null) {
    // Parse denomUnsold from session
    List<Map<String, dynamic>> denomUnsold = List<Map<String, dynamic>>.from(jsonDecode(denomUnsoldString));

    // Add denomUnsold data itself at the beginning
    tempDenomData.insertAll(0, denomUnsold);
  }

  // Update the state
  setState(() {
    denomData = tempDenomData;
  });
  }

  // function to create custom radio buttons
  Widget customRadioButton(String text, int harga) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _value = harga;
            widget.valueChanged(_value);
          });
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(
            color: (_value == harga) ? Theme.of(context).colorScheme.primary : Colors.black,
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.dongle(
            textStyle: TextStyle(
              fontSize: 22,
              color: (_value == harga) ? Theme.of(context).colorScheme.primary : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (denomData.isEmpty) {
      return Center(child: Text("Data denom tidak tersedia."));
    }
    List<TableRow> rows = [];
    for (int i = 0; i < denomData.length; i += 3) {
      rows.add(
        TableRow(
          children: [
            for (int j = 0; j < 3; j++)
              if (i + j < denomData.length)
                customRadioButton(
                  "Rp. ${denomData[i + j]['itemid']}",
                  denomData[i + j]['itemvalue'],
                )
              else
                SizedBox.shrink(), // Empty cell if no data
          ],
        ),
      );
    }
    return Table(
      border: TableBorder.all(color: Colors.transparent),
      children: rows,
    );
    // return Table(
    //   border: TableBorder.all(color: Colors.transparent),
    //   children: [
    //     TableRow(
    //       children: [
    //         customRadioButton("Rp. 20.000", 20000),
    //         customRadioButton("Rp. 200.000", 200000),
    //         customRadioButton("Rp. 5.000.000", 5000000),
    //       ],
    //     ),
    //     TableRow(
    //       children: [
    //         customRadioButton("Rp. 50.000", 50000),
    //         customRadioButton("Rp. 500.000", 500000),
    //         customRadioButton("Rp. 10.000.000", 10000000),
    //       ],
    //     ),
    //     TableRow(
    //       children: [
    //         customRadioButton("Rp. 100.000", 100000),
    //         customRadioButton("Rp. 1.000.000", 1000000),
    //         customRadioButton("Rp. 50.000.000", 50000000),
    //       ],
    //     ),
    //   ],
    // );
  }
}

