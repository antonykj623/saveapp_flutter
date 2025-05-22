import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class MonthYearPicker extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final Function(int month, int year) onDateSelected;

  const MonthYearPicker({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.onDateSelected,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    months[selectedMonth > 0 && selectedMonth <= 12 ? selectedMonth - 1 : 0],
                    style: TextStyle(
                      color: selectedMonth == widget.initialMonth ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 2,
                    color: Colors.grey,
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    selectedYear.toString(),
                    style: TextStyle(
                      color: selectedYear == widget.initialYear ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 100,
                    height: 2,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListWheelScrollView(
                    itemExtent: 40,
                    diameterRatio: 1.5,
                    offAxisFraction: 0.0,
                    squeeze: 1.0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedMonth = index + 1;
                      });
                    },
                    children: months.map((month) {
                      return Center(
                        child: Text(
                          month,
                          style: TextStyle(
                            fontSize: 16,
                            color: months.indexOf(month) + 1 == selectedMonth
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    diameterRatio: 1.5,
                    offAxisFraction: 0.0,
                    squeeze: 1.0,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedYear = DateTime.now().year - 5 + index;
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: 10,
                      builder: (context, index) {
                        final year = DateTime.now().year - 5 + index;
                        return Center(
                          child: Text(
                            year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: year == selectedYear ? Colors.black : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              widget.onDateSelected(selectedMonth, selectedYear);
              Navigator.pop(context);
            },
            child: const Text('SET'),
          ),
        ],
      ),
    );
  }
}