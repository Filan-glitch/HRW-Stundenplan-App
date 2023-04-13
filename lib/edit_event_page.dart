import 'package:flutter/material.dart';

import 'model/event.dart';
import 'model/time.dart';

class EditEventPage extends StatefulWidget {
  const EditEventPage({this.event, super.key});
  final Event? event;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  TextEditingController titleController = TextEditingController();
  Time startTime = const Time(0, 0);
  Time endTime = const Time(0, 0);
  Weekday weekday = Weekday.monday;
  TextEditingController roomController = TextEditingController();

  int? index;

  @override
  void initState() {
    super.initState();
    if (widget.event == null) return;

    titleController = TextEditingController.fromValue(
      TextEditingValue(text: widget.event!.title),
    );
    roomController = TextEditingController.fromValue(
      TextEditingValue(text: widget.event!.room),
    );

    startTime = widget.event!.start;
    endTime = widget.event!.end;

    weekday = widget.event!.day;

    //index = store.state.events.indexOf(widget.event!);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
    /*return Scaffold(
      body: PageWrapper(
          canGoBack: true,
          title: widget.event == null ? "Neues Event" : "Event bearbeiten",
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Titel",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          child: Text("Startzeit: $startTime"),
                          onPressed: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: startTime.hour,
                                minute: startTime.minute,
                              ),
                            ).then((value) {
                              if (value == null) return;
                              setState(() {
                                startTime = Time(value.hour, value.minute);
                              });
                            });
                          },
                        ),
                        TextButton(
                          child: Text("Endzeit: $endTime"),
                          onPressed: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: endTime.hour,
                                minute: endTime.minute,
                              ),
                            ).then((value) {
                              if (value == null) return;
                              setState(() {
                                endTime = Time(value.hour, value.minute);
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Wochentag:  "),
                      DropdownButton<Weekday>(
                        value: weekday,
                        onChanged: (Weekday? value) {
                          setState(() {
                            weekday = value!;
                          });
                        },
                        items: Weekday.values
                            .map<DropdownMenuItem<Weekday>>((Weekday day) {
                          return DropdownMenuItem<Weekday>(
                            value: day,
                            child: Text(day.text),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                      labelText: "Raum",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Event newEvent = Event(
                          title: titleController.text,
                          start: startTime,
                          end: endTime,
                          room: roomController.text,
                          day: weekday,
                        );

                        if (index == null) {
                          store.dispatch(
                            redux.Action(
                              redux.ActionTypes.addEvent,
                              payload: newEvent,
                            ),
                          );
                        } else {
                          store.dispatch(
                            redux.Action(
                              redux.ActionTypes.updateEvent,
                              payload: {"index": index, "event": newEvent},
                            ),
                          );
                        }

                        Navigator.pop(context);
                      },
                      child: const Text("Event speichern"),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );*/
  }
}
