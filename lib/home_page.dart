import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:timetable/list_item.dart';
import 'package:timetable/model/data.dart';

import 'model/break.dart';
import 'model/event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    _activePage = DateTime.now().weekday - 1;
    if (_activePage >= 4) _activePage = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Stundenplan",
              style: TextStyle(
                fontSize: 22,
              ),
            ),
            Text(
              "SoSe 2023",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: timetable[_activePage].length,
        padding: const EdgeInsets.all(20),
        itemBuilder: (context, index) {
          if (timetable[_activePage][index] is Event) {
            return ListItem(
              event: timetable[_activePage][index],
              currentWeekday: DateTime.now().weekday - 1 == _activePage,
            );
          } else if (timetable[_activePage][index] is Break) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: const <Widget>[
                Expanded(
                    child: Divider(
                  color: Colors.black54,
                )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "Pause",
                    style: TextStyle(
                      color: Color.fromARGB(194, 0, 0, 0),
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black54,
                  ),
                ),
              ]),
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _activePage,
        onTap: (i) => setState(() => _activePage = i),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(Icons.looks_one),
            title: const Text("Montag"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.looks_two),
            title: const Text("Dienstag"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.looks_3),
            title: const Text("Mittwoch"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.looks_4),
            title: const Text("Donnerstag"),
            selectedColor: Colors.blue,
          ),
          SalomonBottomBarItem(
            icon: const Icon(Icons.looks_5),
            title: const Text("Freitag"),
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
