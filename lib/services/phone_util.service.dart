import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:fuodz/services/local_storage.service.dart';
import 'package:sim_card_code/sim_card_code.dart';

class PhoneUtilService {
  static Country? _userCountry;
  static bool _isInitialized = false;
  static const String _storageKey = 'USER_COUNTRY_CODE';

  /// Initialize the service - call this on app startup
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Clear cached data to force fresh detection
      await clearCachedCountry();
      
      await getUserCountry();
      _isInitialized = true;
      print(
        'PhoneUtilService initialized with country: ${_userCountry?.countryCode}',
      );
    } catch (e) {
      print('Error initializing PhoneUtilService: $e');
      // Set fallback even if init fails
      _userCountry = Country.tryParse('US');
      _isInitialized = true;
    }
  }

  /// Get the user's country based on device locale and SIM card info
  static Future<Country?> getUserCountry() async {
    if (_userCountry != null) {
      return _userCountry;
    }

    // Try to get from cache first
    final cachedCountryCode = await _getCachedCountryCode();
    if (cachedCountryCode != null) {
      try {
        _userCountry = Country.tryParse(cachedCountryCode);
        if (_userCountry != null) {
          return _userCountry;
        }
      } catch (e) {
        print('Error parsing cached country code: $e');
      }
    }

    // Try SIM card first, then fallback to locale
    _userCountry = await _getCountryFromSIM() ?? await _getCountryFromLocale();

    // Cache the result
    if (_userCountry != null) {
      await _cacheCountryCode(_userCountry!.countryCode);
    }

    return _userCountry;
  }

  /// Get country code (2-letter ISO code)
  static Future<String?> getCountryCode() async {
    final country = await getUserCountry();
    return country?.countryCode;
  }

  /// Get country calling code (phone prefix)
  static Future<String?> getCountryCallingCode() async {
    final country = await getUserCountry();
    return country?.phoneCode;
  }

  /// Get country code synchronously (after init)
  static String? get countryCode {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry?.countryCode;
  }

  /// Get country calling code synchronously (after init)
  static String? get countryCallingCode {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry?.phoneCode;
  }

  /// Get user country synchronously (after init)
  static Country? get userCountry {
    if (!_isInitialized) {
      print('Warning: PhoneUtilService not initialized. Call init() first.');
      return null;
    }
    return _userCountry;
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get country from SIM card
  static Future<Country?> _getCountryFromSIM() async {
    try {
      final simCountryCode = await SimCardManager.simCountryCode;
      if (simCountryCode != null && simCountryCode.isNotEmpty) {
        final country = Country.tryParse(simCountryCode.toUpperCase());
        if (country != null) {
          print('Country detected from SIM: ${country.countryCode}');
          return country;
        }
      }
    } catch (e) {
      print('Error getting country from SIM: $e');
    }
    return null;
  }

  /// Get country from device locale
  static Future<Country?> _getCountryFromLocale() async {
    try {
      final locale = Platform.localeName;
      String? countryCode;

      if (locale.contains('_')) {
        countryCode = locale.split('_').last.toUpperCase();
      } else if (locale.contains('-')) {
        countryCode = locale.split('-').last.toUpperCase();
      }

      if (countryCode != null && countryCode.length == 2) {
        return Country.tryParse(countryCode);
      }
    } catch (e) {
      print('Error getting country from locale: $e');
    }

    // Fallback to US if unable to determine
    return Country.tryParse('US');
  }

  /// Clear cached country (useful for testing or manual selection)
  static Future<void> clearCachedCountry() async {
    _userCountry = null;
    final pref = await LocalStorageService.getPrefs();
    await pref.remove(_storageKey);
  }

  /// Manually set user country
  static Future<void> setUserCountry(Country country) async {
    _userCountry = country;
    await _cacheCountryCode(country.countryCode);
  }

  /// Cache country code locally
  static Future<void> _cacheCountryCode(String countryCode) async {
    try {
      final pref = await LocalStorageService.getPrefs();
      await pref.setString(_storageKey, countryCode);
    } catch (e) {
      print('Error caching country code: $e');
    }
  }

  /// Get cached country code
  static Future<String?> _getCachedCountryCode() async {
    try {
      final pref = await LocalStorageService.getPrefs();
      return pref.getString(_storageKey);
    } catch (e) {
      print('Error getting cached country code: $e');
      return null;
    }
  }

  /// Format phone number with country code
  static String formatPhoneWithCountryCode(
    String phoneNumber,
    String countryCode,
  ) {
    final country = Country.tryParse(countryCode);
    if (country != null) {
      // Remove any existing country code or leading zeros
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'^(\+|00)'), '');
      if (cleanNumber.startsWith(country.phoneCode)) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length);
      }
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }

      return '+${country.phoneCode}$cleanNumber';
    }
    return phoneNumber;
  }

  /// Validate phone number for a specific country
  static bool isValidPhoneNumber(String phoneNumber, String countryCode) {
    try {
      final country = Country.tryParse(countryCode);
      if (country == null) return false;

      // Basic validation - remove spaces, dashes, parentheses
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // Remove country code if present
      if (cleanNumber.startsWith('+${country.phoneCode}')) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length + 1);
      } else if (cleanNumber.startsWith(country.phoneCode)) {
        cleanNumber = cleanNumber.substring(country.phoneCode.length);
      }

      // Remove leading zero if present
      if (cleanNumber.startsWith('0')) {
        cleanNumber = cleanNumber.substring(1);
      }

      // Basic length validation (most phone numbers are 7-15 digits)
      return cleanNumber.length >= 7 &&
          cleanNumber.length <= 15 &&
          RegExp(r'^\d+$').hasMatch(cleanNumber);
    } catch (e) {
      print('Error validating phone number: $e');
      return false;
    }
  }

  /// Get list of all available countries
  static List<Country> getAllCountries() {
    return CountryService().getAll();
  }

  /// Search countries by name or code
  static List<Country> searchCountries(String query) {
    final allCountries = getAllCountries();
    final lowerQuery = query.toLowerCase();

    return allCountries.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.countryCode.toLowerCase().contains(lowerQuery) ||
          country.phoneCode.contains(query);
    }).toList();
  }
}
