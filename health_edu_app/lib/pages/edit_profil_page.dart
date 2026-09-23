import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../utils/toast_helper.dart';

class EditProfilPage extends StatefulWidget {
  final Map<String, dynamic>? profileData;

  const EditProfilPage({super.key, this.profileData});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _classController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _schoolController = TextEditingController();
    _classController = TextEditingController();
    _ageController = TextEditingController();
    _phoneController = TextEditingController();

    if (widget.profileData != null) {
      _populateData(widget.profileData!);
      _isLoading = false;
    } else {
      _fetchProfile();
    }
  }

  void _populateData(Map<String, dynamic> data) {
    _nameController.text = (data['full_name'] ?? '').toString();
    _schoolController.text = (data['school'] ?? '').toString();
    _classController.text = (data['class'] ?? '').toString();
    _ageController.text = data['age'] != null ? data['age'].toString() : '';
    _phoneController.text = (data['phone'] ?? '').toString();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (data != null && mounted) {
          _populateData(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ToastHelper.showError(context, 'Nama lengkap tidak boleh kosong.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ToastHelper.showError(context, 'Sesi tidak valid.');
        return;
      }

      await Supabase.instance.client.from('profiles').update({
        'full_name': name,
        'school': _schoolController.text.trim(),
        'class': _classController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'phone': _phoneController.text.trim(),
      }).eq('id', user.id);

      if (mounted) {
        ToastHelper.showSuccess(context, 'Profil berhasil diperbarui!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Gagal menyimpan: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar display
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UtiCareTheme.primarySubtle,
                          border: Border.all(color: UtiCareTheme.primary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _nameController.text.trim().isNotEmpty
                                ? _nameController.text.trim()[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: UtiCareTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nama Lengkap
                    const Text('Nama Lengkap', style: UtiCareTheme.bodyBold),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nama lengkap kamu',
                        prefixIcon: Icon(Icons.person_outline_rounded, color: UtiCareTheme.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sekolah / SMA
                    const Text('Sekolah / SMA', style: UtiCareTheme.bodyBold),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _schoolController,
                      decoration: const InputDecoration(
                        hintText: 'Nama SMA di Bandung',
                        prefixIcon: Icon(Icons.school_outlined, color: UtiCareTheme.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kelas & Umur
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kelas', style: UtiCareTheme.bodyBold),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _classController,
                                decoration: const InputDecoration(
                                  hintText: 'Contoh: X-IPA 1',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Usia', style: UtiCareTheme.bodyBold),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '16 thn',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // No WhatsApp
                    const Text('Nomor WhatsApp', style: UtiCareTheme.bodyBold),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined, color: UtiCareTheme.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Simpan Perubahan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
