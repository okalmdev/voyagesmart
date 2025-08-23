import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _showOtp = false;
  bool _showPassword = false;
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedRole = 'Client';
  final List<String> _roles = ['Client', 'Partenaire', 'Agent'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (_emailController.text == 'test@example.com' && _passwordController.text == '123456') {
      Navigator.pushNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Email ou mot de passe incorrect';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  InputDecoration _inputDecoration(String label, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF4CAF50)) : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            children: [
              Image.asset('assets/images/logo_vsmart.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                'Bienvenue sur Voyage Smart',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 30),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: _inputDecoration('Rôle'),
                items: _roles.map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                )).toList(),
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Email ou téléphone', icon: Icons.person),
              ),
              const SizedBox(height: 20),

              if (!_showOtp)
                TextField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: _inputDecoration(
                    'Mot de passe',
                    icon: Icons.lock,
                    suffix: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),

              if (_showOtp)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Code OTP', icon: Icons.sms),
                ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Checkbox(
                    value: _showOtp,
                    onChanged: (value) => setState(() => _showOtp = value!),
                    activeColor: const Color(0xFF4CAF50),
                  ),
                  const Text('Se connecter avec un code OTP'),
                ],
              ),

              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _showOtp ? 'Vérifier OTP' : 'Se connecter',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Pas de compte ? S'inscrire",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
