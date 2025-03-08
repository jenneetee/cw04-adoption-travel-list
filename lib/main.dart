import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(AdoptionTravelApp());
}

class AdoptionTravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Plans',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now(); // Add a focusedDay variable

  void _createPlan(String name, String description, DateTime date) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date));
      plans.sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _showCreatePlanDialog() {
    String name = '';
    String description = '';
    DateTime selectedDate = _selectedDay;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _createPlan(name, description, selectedDate);
                Navigator.of(context).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _toggleComplete(Plan plan) {
    setState(() {
      plan.isCompleted = !plan.isCompleted;
    });
  }

  void _editPlan(Plan plan) {
    String name = plan.name;
    String description = plan.description;
    DateTime selectedDate = plan.date;

    // Show dialog to edit the plan
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: TextEditingController(text: description),
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              // Date picker
              ListTile(
                title: Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate)
                    setState(() {
                      selectedDate = picked;
                    });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  plan.name = name;
                  plan.description = description;
                  plan.date = selectedDate;
                  _selectedDay = selectedDate; // Update selected date
                  _focusedDay = selectedDate; // Update focused day as well
                });
                Navigator.of(context).pop();
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlan(Plan plan) {
    setState(() {
      plans.remove(plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adoption & Travel Plans'),
            Text(
              'Swipe to complete, long press to edit, double tap to delete',
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.brown,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay, // Use _focusedDay
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Update focused day
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                // Color-code based on status
                Color planColor =
                    plan.isCompleted ? Colors.green : Colors.orange;

                // Only show tasks that match the selected date
                return isSameDay(plan.date, _selectedDay)
                    ? Dismissible(
                        key: Key(plan.name),
                        onDismissed: (direction) => _deletePlan(plan),
                        child: GestureDetector(
                          onLongPress: () =>
                              _editPlan(plan), // Long press to edit
                          onDoubleTap: () => _deletePlan(plan),
                          child: ListTile(
                            tileColor: planColor.withOpacity(0.2),
                            title: Text(plan.name),
                            subtitle: Text(plan.description),
                            trailing: IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () => _toggleComplete(plan),
                            ),
                          ),
                        ),
                      )
                    : Container(); // Only show tasks for the selected day
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePlanDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
