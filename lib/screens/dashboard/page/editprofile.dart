import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;

  const EditProfile({super.key, this.initialUserData});

  @override
  State<EditProfile> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfile> {
  static const String _baseUrl = 'https://sijala.biz.id/api/v1';
  static const String _imageBaseUrl = 'https://sijala.biz.id/api/image';

  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthPlaceController;
  late TextEditingController _birthDateController;

  String _selectedGender = 'L';
  File? _selectedImage;
  String? _tokenCache;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadToken();

    final data = widget.initialUserData ?? {};

    _nameController = TextEditingController(text: data['name'] ?? '');
    _usernameController = TextEditingController(text: data['username'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _phoneController = TextEditingController(text: data['phone'] ?? '');
    _birthPlaceController = TextEditingController(text: data['birth_place'] ?? '');
    _birthDateController = TextEditingController(text: data['birth_date'] ?? '');

    final genderInput = (data['gender'] ?? 'L').toString().toUpperCase();
    if (genderInput.startsWith('P') || genderInput == 'PEREMPUAN') {
      _selectedGender = 'P';
    } else {
      _selectedGender = 'L';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _tokenCache = prefs.getString('token');
      });
    }
  }

  Future<String?> _getToken() async {
    if (_tokenCache != null) return _tokenCache;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- WIDGET MEMUAT GAMBAR PROFIL LAMA VS BARU ---

  Widget _buildAvatarImage() {
    // 1. Jika pengguna baru saja memilih foto dari galeri/kamera
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    // 2. Jika ada foto lama dari server
    final oldPhoto = widget.initialUserData?['photo'];
    if (oldPhoto != null && oldPhoto.toString().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          '$_imageBaseUrl/$oldPhoto',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          headers: {
            if (_tokenCache != null) 'Authorization': 'Bearer $_tokenCache',
            'Accept': 'application/json',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 60, color: Color.fromARGB(255, 0, 150, 10));
          },
        ),
      );
    }

    // 3. Default Icon jika tidak ada foto
    return const Icon(Icons.person, size: 60, color: Color.fromARGB(255, 0, 150, 10));
  }

  // --- LOGIKA UTILS ---

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Gagal mengambil gambar: $e', isError: true);
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime initialDate = DateTime.tryParse(_birthDateController.text) ?? DateTime(2000, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- LOGIKA API ---

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      final uri = Uri.parse('$_baseUrl/profile');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Method spoofing untuk REST API Laravel jika memakai multipart/form-data
      request.fields['_method'] = 'PUT';

      request.fields['name'] = _nameController.text.trim();
      request.fields['username'] = _usernameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['phone'] = _phoneController.text.trim();
      request.fields['gender'] = _selectedGender;
      request.fields['birth_place'] = _birthPlaceController.text.trim();
      request.fields['birth_date'] = _birthDateController.text.trim();

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['status'] == true || data['success'] == true)) {
        if (!mounted) return;
        _showSnackBar('Profil berhasil diperbarui!');
        context.pop(true);
      } else {
        throw Exception(data['message'] ?? 'Gagal memperbarui profil.');
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil Foto Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar Picker Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green.shade50,
                        child: _buildAvatarImage(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _showImagePickerModal,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Inputs
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.alternate_email,
                  validator: (v) => v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor HP',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                ),

                // Dropdown Gender
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.wc),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedGender = value);
                    },
                  ),
                ),

                _buildTextField(
                  controller: _birthPlaceController,
                  label: 'Tempat Lahir',
                  icon: Icons.location_city_outlined,
                  validator: (v) => v == null || v.isEmpty ? 'Tempat lahir tidak boleh kosong' : null,
                ),
                _buildTextField(
                  controller: _birthDateController,
                  label: 'Tanggal Lahir (YYYY-MM-DD)',
                  icon: Icons.calendar_today_outlined,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  validator: (v) => v == null || v.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}