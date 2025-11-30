// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todolist_app/data/profile_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist_app/services/page_widget.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel? profile;

  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Nama Box Hive
  final String profileBoxName = 'profileBox';
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    // Isi dari constructor (lebih cepat dari Hive)
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _emailController.text = widget.profile!.email;
      _imagePath = widget.profile!.imagePath;
    }

    // Tetap load dari Hive sebagai fallback
    _loadProfileData();
  }

  // Fungsi untuk memuat data profil yang ada dari Hive
  void _loadProfileData() async {
    final profileBox = await Hive.openBox<ProfileModel>(profileBoxName);
    final profile = profileBox.get('userProfile');
    if (profile != null) {
      setState(() {
        _nameController.text = profile.name;
        _emailController.text = profile.email;
        _imagePath = profile.imagePath;
      });
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pilih gambar dari galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageWidget(
      isSpalashScreen: false,
      child: Center(
        child: Column(
          children: [
            _header(),
            const Gap(24),
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: CircleAvatar(
                radius: 54,
                backgroundImage: _imagePath != null && _imagePath!.isNotEmpty
                    ? FileImage(File(_imagePath!)) as ImageProvider
                    : const AssetImage('assets/images/User.png'),
                backgroundColor: const Color.fromARGB(255, 105, 105, 105),
                child: Transform.translate(
                  offset: const Offset(40, 50),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 32),
                  ),
                ),
              ),
            ),
            const Gap(32),
            _nameInput(),
            const Gap(24),
            _emailInput(),
            const Gap(48),
            _saveButton(),
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Material(
        color: const Color(0xFF5F33E1),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            // Validasi input
            if (_nameController.text.trim().isEmpty ||
                _emailController.text.trim().isEmpty) {
              // Tampilkan peringatan jika ada yang kosong
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nama dan Email tidak boleh kosong!'),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              // Jika semua terisi, simpan data dan kembali
              _saveProfileData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil disimpan!')),
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: SizedBox(
            width: 331,
            height: 52,
            child: Center(
              child: Text(
                'Save Changes',
                style: GoogleFonts.lexendDeca(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menyimpan data profil ke Hive
  void _saveProfileData() async {
    final profileBox = await Hive.openBox<ProfileModel>(profileBoxName);
    final profile = ProfileModel(
      name: _nameController.text,
      email: _emailController.text,
      imagePath: _imagePath,
    );
    // Simpan dengan key 'userProfile' agar mudah diambil
    await profileBox.put('userProfile', profile);
  }

  /// Widget untuk input nama.
  Padding _nameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Name",
                style: GoogleFonts.lexendDeca(
                  fontSize: 9,
                  color: const Color(0xFF6E6A7C),
                ),
              ),
              const Gap(1),
              SizedBox(
                width: 320,
                height: 18,
                child: TextFormField(
                  controller: _nameController,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  inputFormatters: [LengthLimitingTextInputFormatter(32)],
                  decoration: InputDecoration(
                    hintText: 'Enter your profile name',
                    hintStyle: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: const Color(0xFF6E6A7C),
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk input email.
  Padding _emailInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        width: 331,
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Email",
                style: GoogleFonts.lexendDeca(
                  fontSize: 9,
                  color: const Color(0xFF6E6A7C),
                ),
              ),
              const Gap(1),
              SizedBox(
                width: 320,
                height: 18,
                child: TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: const Color(0xFF6E6A7C),
                      fontStyle: FontStyle.italic,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.only(top: 28, left: 22, right: 22),
      child: SizedBox(
        width: 331,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                // Kembali ke halaman sebelumnya tanpa menyimpan perubahan.
                Navigator.of(context).pop();
              },
              icon: Transform.rotate(
                angle: math.pi, // Memutar 180 derajat
                child: SvgPicture.asset(
                  'assets/svgs/button_start.svg',
                  fit: BoxFit.cover,
                  color: Colors.black,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            Text(
              'Profile Settings',
              style: GoogleFonts.lexendDeca(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            Stack(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/svgs/notif.svg',
                    fit: BoxFit.cover,
                    color: Colors.black,
                    width: 24,
                    height: 24,
                  ),
                ),
                // Bulatan merah di pojok kanan atas
                Positioned(
                  right: 15,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xFF5F33E1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
