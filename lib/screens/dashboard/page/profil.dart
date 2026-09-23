import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. MODEL DATA
// ==========================================
class UserProfile {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final String birthPlace;
  final String birthDate;
  final String? photo;

  UserProfile({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthPlace,
    required this.birthDate,
    this.photo,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? '-',
      username: json['username']?.toString() ?? '-',
      email: json['email']?.toString() ?? '-',
      phone: json['phone']?.toString() ?? '-',
      gender: json['gender']?.toString() ?? '-',
      birthPlace: json['birth_place']?.toString() ?? '-',
      birthDate: json['birth_date']?.toString() ?? '-',
      photo: json['photo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'gender': gender,
        'birth_place': birthPlace,
        'birth_date': birthDate,
        'photo': photo,
      };

  String get formattedGender {
    final g = gender.toLowerCase();
    if (g == 'l' || g == 'male' || g.startsWith('l')) return 'Laki-laki';
    if (g == 'p' || g == 'female' || g.startsWith('p')) return 'Perempuan';
    return gender;
  }
}

// ==========================================
// 2. HALAMAN UTAMA
// ==========================================
class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  static const String _baseUrl = 'https://sijala.biz.id/api/v1';
  static const String _imageBaseUrl = 'https://sijala.biz.id/api/image';

  UserProfile? _user;
  Future<Uint8List?>? _profileImageFuture;
  bool _isLoading = true;
  bool _isLoggingOut = false; // Prevents double-tap spamming

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- LOGIKA API ---

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final profile = UserProfile.fromJson(data['data']);
        setState(() {
          _user = profile;
          _isLoading = false;
          _profileImageFuture = (profile.photo?.isNotEmpty ?? false)
              ? _fetchProfileImage(profile.photo!)
              : null;
        });
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data profil.');
      }
    } on SocketException {
      _handleError('Tidak ada koneksi internet.');
    } on TimeoutException {
      _handleError('Server lambat merespons.');
    } catch (e) {
      _handleError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Uint8List?> _fetchProfileImage(String fileName) async {
    try {
      final token = await _getToken() ?? '';
      final response = await http.get(
        Uri.parse('$_imageBaseUrl/$fileName'), // Corrected image endpoint path
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    return null;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return; // Prevent multiple requests

    final confirmed = await _showLogoutDialog();
    if (confirmed != true) return;

    setState(() => _isLoggingOut = true);

    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        // Clear local storage if token is invalidated or successfully logged out
        if (response.statusCode == 200 || response.statusCode == 401) {
          await _clearLocalStorageAndNavigate();
          return;
        } else {
          _showSnackBar('Logout gagal. Silakan coba lagi.', isError: true);
        }
      } else {
        await _clearLocalStorageAndNavigate();
        return;
      }
    } on SocketException {
      _showSnackBar('Tidak dapat terhubung ke server.', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan tak terduga.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _clearLocalStorageAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    if (!mounted) return;
    _showSnackBar('Logout berhasil');
    context.go('/login');
  }

  void _handleError(String message) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackBar(message, isError: true);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool?> _showLogoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final result = await context.push('/edit', extra: _user?.toJson());
    if (result == true) {
      _fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const _LoadingIndicator()
                : _user == null
                    ? const Center(child: Text('Data profil tidak ditemukan.'))
                    : Column(
                        children: [
                          _ProfileCard(
                            user: _user!,
                            imageFuture: _profileImageFuture,
                          ),
                          const SizedBox(height: 16),
                          _ActionTile(
                            icon: Icons.edit,
                            title: 'Edit Profil',
                            subtitle: 'Perbarui data diri Anda',
                            onTap: _navigateToEdit,
                          ),
                          _ActionTile(
                            icon: Icons.logout,
                            title: 'Keluar',
                            subtitle: _isLoggingOut ? 'Memproses...' : 'Logout dari sesi akun',
                            isDanger: true,
                            onTap: _isLoggingOut ? () {} : _logout,
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. WIDGET KOMPONEN TERPISAH
// ==========================================

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 40.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile user;
  final Future<Uint8List?>? imageFuture;

  const _ProfileCard({
    required this.user,
    required this.imageFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _Avatar(photo: user.photo, imageFuture: imageFuture),
          const SizedBox(height: 14),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Divider(height: 30),
          _InfoRow(label: 'Username', value: user.username),
          _InfoRow(label: 'Email', value: user.email),
          _InfoRow(label: 'Nomor HP', value: user.phone),
          _InfoRow(label: 'Jenis Kelamin', value: user.formattedGender),
          _InfoRow(label: 'Tempat Lahir', value: user.birthPlace),
          _InfoRow(label: 'Tanggal Lahir', value: user.birthDate),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photo;
  final Future<Uint8List?>? imageFuture;

  const _Avatar({this.photo, this.imageFuture});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photo != null && photo!.isNotEmpty;

    return CircleAvatar(
      radius: 46,
      backgroundColor: Colors.blue.shade50,
      child: hasPhoto
          ? FutureBuilder<Uint8List?>(
              future: imageFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return ClipOval(
                    child: Image.memory(
                      snapshot.data!,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return const _DefaultAvatarIcon();
              },
            )
          : const _DefaultAvatarIcon(),
    );
  }
}

class _DefaultAvatarIcon extends StatelessWidget {
  const _DefaultAvatarIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person, size: 48, color: Colors.blue);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? Colors.red : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDanger ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}