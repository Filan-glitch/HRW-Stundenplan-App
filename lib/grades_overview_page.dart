import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/widgets/page_wrapper.dart';
import 'model/redux/app_state.dart';
import 'model/module.dart';

class GradesOverviewPage extends StatelessWidget {
  const GradesOverviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      simpleDesign: true,
      title: "Prüfungsergebnisse",
      body: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.modules.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Gesamtnote: ${state.gpa.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  );
                }

                Module module = state.modules[index - 1];
                if (module.status == Status.passed && module.creditsAll == 0) {
                  return Container();
                }

                return ListTile(
                  title: Text(
                    module.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (module.grade != 0)
                        Row(
                          children: [
                            const Text('Note: '),
                            Text(
                              module.grade.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      if (module.status != Status.open) ...[
                        Text(
                          'Mögliche Credits: ${module.creditsAll.toString()}',
                        ),
                        Text(
                          'Angerechnete Credits: ${module.creditsCharged.toString()}',
                        ),
                      ],
                      if (module.status == Status.passed)
                        const Text(
                          'Status: Bestanden',
                          style: TextStyle(color: Colors.green),
                        ),
                      if (module.status == Status.failed)
                        const Text(
                          'Status: Durchgefallen',
                          style: TextStyle(color: Colors.red),
                        ),
                      if (module.status == Status.open)
                        const Text(
                          'Status: Offen',
                        ),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
