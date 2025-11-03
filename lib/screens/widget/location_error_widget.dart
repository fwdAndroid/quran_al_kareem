import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_al_kareem/provider/language_providrer.dart';

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({Key? key, this.error, this.callback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Access

    const box = SizedBox(height: 32);
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.location_off, size: 150, color: errorColor),
          box,
          Text(
            error!,
            style: const TextStyle(
              color: errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          box,
          ElevatedButton(
            child: Text(languageProvider.localizedStrings["Retry"] ?? "Retry"),
            onPressed: () {
              if (callback != null) callback!();
            },
          ),
        ],
      ),
    );
  }
}
