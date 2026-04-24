import 'package:get/get.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:torch_light/torch_light.dart';
import 'package:app_settings/app_settings.dart';
import 'package:installed_apps/installed_apps.dart';

class SystemController extends GetxController {
  final Battery _battery = Battery();

  final batteryLevel = 0.obs;
  final batteryState = BatteryState.unknown.obs;
  final currentVolume = 0.0.obs;
  final currentBrightness = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initSystemStatus();

    _battery.onBatteryStateChanged.listen((state) {
      batteryState.value = state;
      _updateBatteryLevel();
    });

    VolumeController().listener((volume) {
      currentVolume.value = volume;
    });
  }

  Future<void> _initSystemStatus() async {
    _updateBatteryLevel();
    currentVolume.value = await VolumeController().getVolume();
    try {
      currentBrightness.value = await ScreenBrightness().application;
    } catch (_) {}
  }

  Future<void> _updateBatteryLevel() async {
    batteryLevel.value = await _battery.batteryLevel;
  }

  Future<void> setVolume(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    VolumeController().setVolume(clamped);
    currentVolume.value = clamped;
  }

  Future<void> setBrightness(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    try {
      await ScreenBrightness().setApplicationScreenBrightness(clamped);
      currentBrightness.value = clamped;
    } catch (e) {
      print('Failed to set brightness: $e');
    }
  }

  Future<void> toggleTorch(bool on) async {
    try {
      if (on) {
        await TorchLight.enableTorch();
      } else {
        await TorchLight.disableTorch();
      }
    } catch (e) {
      print('Flashlight error: $e');
    }
  }

  void openWifiSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.wifi);
  }

  void openBluetoothSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  void openMainSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.settings);
  }

  void openBatterySettings() {
    AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
  }

  void openDisplaySettings() {
    AppSettings.openAppSettings(type: AppSettingsType.display);
  }

  Future<List<Map<String, String>>> getLaunchableApps() async {
    final apps = await InstalledApps.getInstalledApps();
    return apps.map((a) => {'name': a.name ?? '', 'package': a.packageName ?? ''}).toList();
  }

  Future<bool> launchApp(String nameOrPackage) async {
    try {
      final success = await InstalledApps.startApp(nameOrPackage);
      if (success == true) return true;
    } catch (_) {}

    final apps = await InstalledApps.getInstalledApps();
    for (final app in apps) {
      if ((app.name ?? '').toLowerCase() == nameOrPackage.toLowerCase()) {
        final success = await InstalledApps.startApp(app.packageName ?? '');
        return success == true;
      }
    }
    return false;
  }

  Future<String> getSystemSummary() async {
    await _updateBatteryLevel();
    final level = batteryLevel.value;
    final state = batteryState.value.toString().split('.').last;
    final vol = (currentVolume.value * 100).toInt();
    final bright = (currentBrightness.value * 100).toInt();

    return 'Battery: $level% ($state), Volume: $vol%, Brightness: $bright%';
  }
}
