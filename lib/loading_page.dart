import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: SizedBox(
                height: 150.0,
                width: 150.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                  strokeWidth: 3.0,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                "Bitte warten...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
