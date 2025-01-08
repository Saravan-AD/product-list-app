import 'dart:convert';
import 'package:http/http.dart' as http;

class BannerService {
  Future<List<String>> fetchBanners() async {
    final url = 'https://admin.kushinirestaurant.com/api/banners/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item['image'] as String).toList();
      } else {
        throw Exception('Failed to load banners');
      }
    } catch (e) {
      print('Error fetching banners: $e');
      return [];
    }
  }
}