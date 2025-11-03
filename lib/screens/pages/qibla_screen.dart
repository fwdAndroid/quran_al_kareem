import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quran_al_kareem/utils/colors.dart';

class QiblaScreen extends StatefulWidget {
  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled &&
        locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
      final s = await FlutterQiblah.checkLocationStatus();
      _locationStreamController.sink.add(s);
    } else {
      _locationStreamController.sink.add(locationStatus);
    }
  }

  @override
  void initState() {
    _checkLocationStatus();
    super.initState();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/bg.png", fit: BoxFit.cover),
          ),
          Container(
            color: mainColor.withOpacity(
              0.15,
            ), // optional overlay for better contrast
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder(
              stream: stream,
              builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.enabled == true) {
                  switch (snapshot.data!.status) {
                    case LocationPermission.always:
                    case LocationPermission.whileInUse:
                      return QiblaScreenWidget();

                    case LocationPermission.denied:
                      return LocationErrorWidget(
                        error: "Location service permission denied",
                        callback: _checkLocationStatus,
                      );
                    case LocationPermission.deniedForever:
                      return LocationErrorWidget(
                        error: "Location service Denied Forever!",
                        callback: _checkLocationStatus,
                      );
                    default:
                      return Container();
                  }
                } else {
                  return LocationErrorWidget(
                    error: "Please enable Location service",
                    callback: _checkLocationStatus,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QiblaScreenWidget extends StatefulWidget {
  @override
  State<QiblaScreenWidget> createState() => _QiblaScreenWidgetState();
}

class _QiblaScreenWidgetState extends State<QiblaScreenWidget> {
  final _compassSvg = SvgPicture.asset('assets/compass.svg');
  final _needleSvg = SvgPicture.asset(
    'assets/needle.svg',
    fit: BoxFit.contain,
    height: 300,
    alignment: Alignment.center,
  );

  double? distanceToKaaba;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Future<void> _calculateDistance() async {
    const double kaabaLatitude = 21.4225;
    const double kaabaLongitude = 39.8262;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        kaabaLatitude,
        kaabaLongitude,
      );

      setState(() {
        distanceToKaaba = distanceInMeters / 1000; // Convert to km
      });
    } catch (e) {
      debugPrint("Error calculating distance: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final qiblahDirection = snapshot.data!;

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform.rotate(
              angle: (qiblahDirection.direction * (pi / 180) * -1),
              child: _compassSvg,
            ),
            Transform.rotate(
              angle: (qiblahDirection.qiblah * (pi / 180) * -1),
              alignment: Alignment.center,
              child: _needleSvg,
            ),
            Positioned(
              bottom: 50,
              child: Column(
                children: [
                  Text(
                    "${qiblahDirection.offset.toStringAsFixed(2)}° to Qibla",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.tealAccent),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (distanceToKaaba != null)
                    Text(
                      "Distance to Kaaba: ${distanceToKaaba!.toStringAsFixed(1)} km",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.amber)],
                      ),
                    )
                  else
                    const Text(
                      "Calculating distance...",
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LocationErrorWidget extends StatelessWidget {
  final String? error;
  final Function? callback;

  const LocationErrorWidget({Key? key, this.error, this.callback})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const errorColor = Color(0xffb00020);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.location_off, size: 150, color: errorColor),
          const SizedBox(height: 32),
          Text(
            error ?? '',
            style: const TextStyle(
              color: errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            child: const Text("Retry"),
            onPressed: () {
              if (callback != null) callback!();
            },
          ),
        ],
      ),
    );
  }
}
