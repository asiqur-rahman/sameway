import 'package:sameway/core/api/api_client.dart';
import 'package:sameway/core/api/models/reminder_settings.dart';
import 'package:sameway/core/api/repositories/uploads_repository.dart';
import 'package:sameway/core/api/user_mapper.dart';
import 'package:sameway/core/session/user_profile.dart';

class UsersRepository {
  UsersRepository._();

  static final UsersRepository instance = UsersRepository._();
  final _client = ApiClient.instance;

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final result = await _client.patch('/users/me', data: data);
    return UserMapper.fromApi(result);
  }

  Future<VehicleInfo> addVehicle(VehicleInfo vehicle) async {
    final result = await _client.post('/users/me/vehicles', data: UserMapper.vehicleToApi(vehicle));
    return VehicleInfo(
      id: result['id'] as String?,
      type: (result['type'] as String?)?.toLowerCase() ?? vehicle.type,
      makeModel: result['makeModel'] as String? ?? vehicle.makeModel,
      licensePlate: result['licensePlate'] as String? ?? vehicle.licensePlate,
      color: result['color'] as String? ?? vehicle.color,
      seats: result['availableSeats'] as int? ?? vehicle.seats,
      usuallyLeave: result['usuallyLeave'] as String? ?? vehicle.usuallyLeave,
      latestDepart: result['latestDepart'] as String? ?? vehicle.latestDepart,
      riderPreference: result['riderPreference'] as String? ?? vehicle.riderPreference,
    );
  }

  Future<void> updateCommutePreferences(CommutePreferences prefs) async {
    await _client.patch('/users/me/commute-preferences', data: prefs.toJson());
  }

  Future<void> savePlace({
    required String label,
    required String address,
    required double lat,
    required double lng,
  }) async {
    await _client.post('/users/me/locations', data: {
      'label': label,
      'address': address,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<void> submitVerification({
    required String verificationMethod,
    String? employeeIdImageUrl,
  }) async {
    await _client.post('/users/me/verification', data: {
      'verificationMethod': verificationMethod,
      if (employeeIdImageUrl != null) 'employeeIdImageUrl': employeeIdImageUrl,
    });
  }

  Future<String> uploadFile(String filePath, {String type = 'profiles'}) async {
    return UploadsRepository.instance.uploadImage(filePath, type: type);
  }

  Future<ReminderSettings> getReminderSettings() async {
    final result = await _client.get('/users/me/reminder-settings');
    return ReminderSettings.fromJson(result);
  }

  Future<ReminderSettings> updateReminderSettings(ReminderSettings settings) async {
    final result = await _client.patch('/users/me/reminder-settings', data: settings.toJson());
    return ReminderSettings.fromJson(result);
  }

  Future<void> registerDeviceToken({required String token, required String platform}) async {
    await _client.post('/users/me/device-tokens', data: {
      'token': token,
      'platform': platform,
    });
  }
}
