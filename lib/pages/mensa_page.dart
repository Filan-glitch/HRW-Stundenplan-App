import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/campus.dart';
import '../model/constants.dart';
import '../model/redux/app_state.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/store.dart';
import '../service/storage.dart';
import '../widgets/horizontal_selector.dart';
import '../widgets/page_wrapper.dart';
import '../widgets/pdf_widget.dart';

class MensaPage extends StatefulWidget {
  const MensaPage({super.key});

  @override
  State<MensaPage> createState() => _MensaPageState();
}

class _MensaPageState extends State<MensaPage> {
  bool _showCurrentWeek = true;
  Key _refreshKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      simpleDesign: true,
      title: "Mensa",
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          String url = "";

          if (state.campus == Campus.muelheim && _showCurrentWeek) {
            url = MENSA_MUE_CURRENT_URL;
          } else if (state.campus == Campus.muelheim && !_showCurrentWeek) {
            url = MENSA_MUE_NEXT_URL;
          } else if (state.campus == Campus.bottrop && _showCurrentWeek) {
            url = MENSA_BOT_CURRENT_URL;
          } else if (state.campus == Campus.bottrop && !_showCurrentWeek) {
            url = MENSA_BOT_NEXT_URL;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: _showCurrentWeek
                        ? null
                        : () {
                            setState(() {
                              _showCurrentWeek = true;
                              _refreshKey = UniqueKey();
                            });
                          },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                    ),
                  ),
                  if (_showCurrentWeek) const Text("Aktuelle Woche"),
                  if (!_showCurrentWeek) const Text("Nächste Woche"),
                  IconButton(
                    onPressed: _showCurrentWeek
                        ? () {
                            setState(() {
                              _showCurrentWeek = false;
                              _refreshKey = UniqueKey();
                            });
                          }
                        : null,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PdfWidget(
                  key: _refreshKey,
                  url: url,
                  onError: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              HorizontalSelector(
                items: Campus.values.asMap().map(
                      (key, value) => MapEntry(
                        value,
                        value.name,
                      ),
                    ),
                onChanged: (value) {
                  store.dispatch(
                    redux.Action(
                      redux.ActionTypes.setCampus,
                      payload: value,
                    ),
                  );

                  writeCampus();

                  _refreshKey = UniqueKey();
                },
                value: state.campus,
              ),
            ],
          );
        },
      ),
    );
  }
}
