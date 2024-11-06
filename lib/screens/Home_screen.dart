import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:test_assignment/widgets/top_containers.dart';
import 'package:test_assignment/services/permissions_helper.dart';
import 'package:test_assignment/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PermissionsHelper _permissionsHelper = PermissionsHelper();
  final LocationService _locationService = LocationService();
  final List<Map<String, double>> _locationDataList = [];
  static const platform = MethodChannel('com.example.notifications/settings');




  Future<void> _requestLocationPermission() async {
    bool granted = await _permissionsHelper.requestLocationPermission();
    if (granted) {
      Get.snackbar(
          "Permission Granted", "Location permission granted successfully.");
    } else {
      Get.snackbar(
          "Permission Denied", "Location permission is required to proceed.");
    }
  }



  void _startLocationUpdate() async {
    final confirm = await _showConfirmationDialog("Start Location Update?");
    if (confirm) {
      bool isNotificationAllowed =
          await _permissionsHelper.requestNotificationPermission();

      if (!isNotificationAllowed) {
        Get.snackbar(
          "Notification Permission Required",
          "Please enable notification permission to receive updates.",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _locationService.startLocationUpdates();
      _triggerNotification("Location update started");
      _updateLocationData();
      Future.delayed(const Duration(seconds: 30), _updateLocationData);
    }
  }

  void _stopLocationUpdate() async {
    final confirm = await _showConfirmationDialog("Stop Location Update?");
    if (confirm) {
      await _locationService.stopLocationUpdates();
      _triggerNotification("Location update stopped");
    }
  }



  Future<void> enableNotifications() async {
    try {
      bool locationUpdatesActive = true;

      if (locationUpdatesActive) {
        bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
        await platform.invokeMethod('openNotificationSettings');
      }
    } on PlatformException catch (e) {
      print("Failed to open settings: '${e.message}'.");
    }
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await Get.dialog<bool>(
          AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateLocationData() async {
    final data = await _locationService.getLocationData();
    setState(() {
      _locationDataList.add({
        'latitude': data['latitude'] ?? 0.0,
        'longitude': data['longitude'] ?? 0.0,
        'speed': double.parse((data['speed'] ?? 0.0).toStringAsFixed(2)),
      });
    });
  }

  void _triggerNotification(String message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: message,
        body: 'Location update notification',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Test App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TopContainers(
                          onTap: _requestLocationPermission,
                          text: 'Request Location Permission',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        TopContainers(
                          onTap: enableNotifications,
                          text: 'Request Notification Permission',
                          color: Colors.yellow,
                          textStyle: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        TopContainers(
                          onTap: _startLocationUpdate,
                          text: 'Start Location Update',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        TopContainers(
                          onTap: _stopLocationUpdate,
                          text: 'Stop Location Update',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: _locationDataList.length,
                  itemBuilder: (context, index) {
                    final data = _locationDataList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Request ${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Lat: ${data['latitude'] ?? 0.0}"),
                              Text("Long: ${data['longitude'] ?? 0.0}"),
                              Text("Speed: ${data['speed'] ?? 0.0}"),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
