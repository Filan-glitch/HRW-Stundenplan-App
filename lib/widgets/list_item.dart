import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';

class ListItem extends StatefulWidget {
  const ListItem({required this.event, required this.currentWeek, super.key});

  final Event event;
  final bool currentWeek;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  late final Timer _refreshTimer;
  late Mode _lastMode;

  @override
  void initState() {
    super.initState();
    _lastMode = widget.event.mode;
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      Mode newMode = widget.event.mode;
      if (_lastMode != newMode) {
        setState(() {
          _lastMode = newMode;
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Opacity(
            opacity:
                widget.event.mode == Mode.done && widget.currentWeek ? 0.6 : 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: widget.event.mode == Mode.active && widget.currentWeek
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 5,
                        )
                      : BorderSide.none,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal:
                      widget.event.mode == Mode.active && widget.currentWeek
                          ? 10.0
                          : 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.event.start} - ${widget.event.end}'),
                            Text(widget.event.room),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
