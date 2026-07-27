import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  final String baseUrl = AppConfig.apiBaseUrl;
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String userType,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'user_type': userType,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    final body = <String, dynamic>{'password': password};
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getProfile() => _get('/auth/me');

  Future<Map<String, dynamic>> listProperties({
    String? location,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? houseType,
    int page = 1,
  }) {
    final params = <String, String>{
      'page': page.toString(),
      if (location != null) 'location': location,
      if (minPrice != null) 'min_price': minPrice.toStringAsFixed(0),
      if (maxPrice != null) 'max_price': maxPrice.toStringAsFixed(0),
      if (bedrooms != null) 'bedrooms': bedrooms.toString(),
      if (houseType != null) 'house_type': houseType,
    };
    return _get('/properties', params: params);
  }

  Future<Map<String, dynamic>> getProperty(String id) => _get('/properties/$id');

  Future<Map<String, dynamic>> createProperty({
    required String title,
    required double price,
    required String location,
    required int bedrooms,
    required String contactPhone,
    String? houseType,
    String? description,
    String? securityDetails,
    bool parking = false,
    bool waterAvailable = false,
    double? latitude,
    double? longitude,
    List<File>? photos,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/properties'),
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.fields.addAll({
      'title': title,
      'price': price.toStringAsFixed(0),
      'location': location,
      'bedrooms': bedrooms.toString(),
      'contact_phone': contactPhone,
      if (houseType != null) 'house_type': houseType,
      if (description != null) 'description': description,
      if (securityDetails != null) 'security_details': securityDetails,
      'parking': parking.toString(),
      'water_available': waterAvailable.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
    });
    if (photos != null) {
      for (final f in photos) {
        request.files.add(await http.MultipartFile.fromPath('photos', f.path));
      }
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateProperty(String id, {
    String? title,
    double? price,
    String? location,
    int? bedrooms,
    String? contactPhone,
    String? houseType,
    String? description,
    String? securityDetails,
    bool? parking,
    bool? waterAvailable,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (price != null) body['price'] = price;
    if (location != null) body['location'] = location;
    if (bedrooms != null) body['bedrooms'] = bedrooms;
    if (contactPhone != null) body['contact_phone'] = contactPhone;
    if (houseType != null) body['house_type'] = houseType;
    if (description != null) body['description'] = description;
    if (securityDetails != null) body['security_details'] = securityDetails;
    if (parking != null) body['parking'] = parking;
    if (waterAvailable != null) body['water_available'] = waterAvailable;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (isActive != null) body['is_active'] = isActive;
    final res = await http.put(
      Uri.parse('$baseUrl/properties/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> deleteProperty(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/properties/$id'),
      headers: _headers,
    );
    return _handle(res);
  }

  Future<List<Map<String, dynamic>>> listReminders({String? status}) {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    return _getList('/agents/reminders', params: params);
  }

  Future<Map<String, dynamic>> createReminder({
    required String tenantName,
    String? tenantPhone,
    String? unitNumber,
    double? rentAmount,
    required String dueDate,
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/agents/reminders'),
      headers: _headers,
      body: jsonEncode({
        'tenant_name': tenantName,
        if (tenantPhone != null) 'tenant_phone': tenantPhone,
        if (unitNumber != null) 'unit_number': unitNumber,
        if (rentAmount != null) 'rent_amount': rentAmount,
        'due_date': dueDate,
        if (notes != null) 'notes': notes,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> updateReminder(
    String id, {
    String? status,
    String? tenantName,
    String? tenantPhone,
    String? unitNumber,
    double? rentAmount,
    String? dueDate,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (tenantName != null) body['tenant_name'] = tenantName;
    if (tenantPhone != null) body['tenant_phone'] = tenantPhone;
    if (unitNumber != null) body['unit_number'] = unitNumber;
    if (rentAmount != null) body['rent_amount'] = rentAmount;
    if (dueDate != null) body['due_date'] = dueDate;
    if (notes != null) body['notes'] = notes;
    final res = await http.put(
      Uri.parse('$baseUrl/agents/reminders/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<void> deleteReminder(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/agents/reminders/$id'),
      headers: _headers,
    );
    _handle(res);
  }

  Future<Map<String, dynamic>> initiateSubscription({
    required String planType,
    String? phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/subscriptions/initiate'),
      headers: _headers,
      body: jsonEncode({
        'plan_type': planType,
        if (phone != null) 'phone': phone,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> getSubscriptionStatus() => _get('/subscriptions/status');

  Future<List<Map<String, dynamic>>> listFavorites() => _getList('/favorites');

  Future<Map<String, dynamic>> addFavorite(String propertyId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
      body: jsonEncode({'property_id': propertyId}),
    );
    return _handle(res);
  }

  Future<void> removeFavorite(String propertyId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/favorites/$propertyId'),
      headers: _headers,
    );
    _handle(res);
  }

  Future<List<Map<String, dynamic>>> listMyBookings() => _getList('/bookings');

  Future<Map<String, dynamic>> updateBooking(
    String id, {
    String? status,
    String? message,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (message != null) body['message'] = message;
    final res = await http.put(
      Uri.parse('$baseUrl/bookings/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> createBooking(
    String propertyId, {
    String? message,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _headers,
      body: jsonEncode({
        'property_id': propertyId,
        if (message != null) 'message': message,
      }),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> _get(String path, {Map<String, String>? params}) async {
    return _retryIfFails(() async {
      var uri = Uri.parse('$baseUrl$path');
      if (params != null) uri = uri.replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers);
      return _handle(res);
    });
  }

  Future<List<Map<String, dynamic>>> _getList(String path, {Map<String, String>? params}) async {
    return _retryIfFails(() async {
      var uri = Uri.parse('$baseUrl$path');
      if (params != null) uri = uri.replace(queryParameters: params);
      final res = await http.get(uri, headers: _headers);
      return _handleList(res);
    });
  }

  Future<T> _retryIfFails<T>(Future<T> Function() fn, {int maxRetries = 2}) async {
    for (int i = 0; i <= maxRetries; i++) {
      try {
        return await fn();
      } on SocketException catch (_) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 1 << i));
      } on TimeoutException catch (_) {
        if (i == maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 1 << i));
      }
    }
    throw ApiException('Network error', 0);
  }

  Map<String, dynamic> _handle(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    throw ApiException(body['error'] ?? 'Unknown error', res.statusCode);
  }

  List<Map<String, dynamic>> _handleList(http.Response res) {
    final body = jsonDecode(res.body) as List<dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body.cast<Map<String, dynamic>>();
    }
    final err = body.isNotEmpty ? body.first : 'Unknown error';
    throw ApiException(err.toString(), res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);
  @override
  String toString() => message;
}
