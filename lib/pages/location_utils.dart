import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class LocationUtils {
  /// Generates a Google Maps link from latitude and longitude
  static String generateGoogleMapsLink(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  /// Generates a Google Maps directions link from latitude and longitude
  static String generateGoogleMapsDirectionsLink(
    double latitude,
    double longitude,
  ) {
    return 'https://maps.google.com/maps?daddr=$latitude,$longitude&amp;ll=';
  }

  /// Formats location coordinates for display
  static String formatLocationCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Formats location for display in Arabic
  static String formatLocationForDisplay(double latitude, double longitude) {
    return 'الموقع الحالي: ${formatLocationCoordinates(latitude, longitude)}';
  }

  /// Opens the Google Maps app or website with the given coordinates
  static Future<bool> openGoogleMaps(double latitude, double longitude) async {
    final url = generateGoogleMapsLink(latitude, longitude);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Opens Google Maps with directions to the given coordinates
  static Future<bool> openGoogleMapsDirections(
    double latitude,
    double longitude,
  ) async {
    final url = generateGoogleMapsDirectionsLink(latitude, longitude);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Shows a location picker dialog
  static Future<void> showLocationOptionsDialog(
    BuildContext context,
    Position position,
    Function(String) onLinkCopied,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('خيارات الموقع', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.blue),
                  title: const Text('فتح في خرائط جوجل'),
                  onTap: () {
                    Navigator.pop(context);
                    openGoogleMaps(position.latitude, position.longitude);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.directions, color: Colors.green),
                  title: const Text('الحصول على الاتجاهات'),
                  onTap: () {
                    Navigator.pop(context);
                    openGoogleMapsDirections(
                      position.latitude,
                      position.longitude,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy, color: Colors.purple),
                  title: const Text('نسخ رابط الموقع'),
                  onTap: () {
                    final link = generateGoogleMapsLink(
                      position.latitude,
                      position.longitude,
                    );
                    Navigator.pop(context);
                    onLinkCopied(link);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
            ],
          ),
    );
  }
}
