import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _regUsernameController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();

  bool _loginPasswordVisible = false;
  bool _regPasswordVisible = false;
  bool _regConfirmPasswordVisible = false;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _regUsernameController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('reg_username') ?? '';
    final savedPassword = prefs.getString('reg_password') ?? '';

    final inputUsername = _loginUsernameController.text.trim();
    final inputPassword = _loginPasswordController.text;

    if (inputUsername == savedUsername && inputPassword == savedPassword) {
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('username', inputUsername);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: inputUsername)),
      );
    } else {
      _showSnackBar('Username atau password salah!', isError: true);
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final username = _regUsernameController.text.trim();
    final password = _regPasswordController.text;

    final existingUsername = prefs.getString('reg_username') ?? '';
    if (existingUsername == username) {
      _showSnackBar('Username sudah digunakan!', isError: true);
      return;
    }

    await prefs.setString('reg_username', username);
    await prefs.setString('reg_password', password);

    _showSnackBar('Registrasi berhasil! Silakan login.');
    _tabController.animateTo(0);

    _loginUsernameController.text = username;
    _loginPasswordController.text = password;

    _regUsernameController.clear();
    _regPasswordController.clear();
    _regConfirmPasswordController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Register'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 380,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginForm(),
                    _buildRegisterForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _loginUsernameController,
              label: 'Username',
              icon: Icons.person_outline,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Username tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _loginPasswordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _loginPasswordVisible,
              onTogglePassword: () => setState(
                  () => _loginPasswordVisible = !_loginPasswordVisible),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Password tidak boleh kosong' : null,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _regUsernameController,
              label: 'Username',
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Username tidak boleh kosong';
                if (v.length < 3) return 'Username minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _regPasswordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _regPasswordVisible,
              onTogglePassword: () =>
                  setState(() => _regPasswordVisible = !_regPasswordVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                if (v.length < 3) return 'Password max 3 angka';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _regConfirmPasswordController,
              label: 'Konfirmasi Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _regConfirmPasswordVisible,
              onTogglePassword: () => setState(() =>
                  _regConfirmPasswordVisible = !_regConfirmPasswordVisible),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                if (v != _regPasswordController.text) {
                  return 'Password tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(isPasswordVisible ?? false),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isPasswordVisible ?? false)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}