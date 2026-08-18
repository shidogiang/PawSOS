import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_event.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_state.dart';
import '../../../../screen/start/main_tab_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      String rawPhone = _usernameController.text.trim();
      if (rawPhone.startsWith('0')) {
        rawPhone = rawPhone.substring(1); // Bỏ số 0 ở đầu nếu có
      }
      // Nếu người dùng nhập thẳng số điện thoại, ta tự động thêm +84
      String formattedPhone = rawPhone.startsWith('+') ? rawPhone : '+84$rawPhone';

      context.read<AuthBloc>().add(
        AuthLoginSubmitted(
          phone: formattedPhone,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              if (ModalRoute.of(context)?.isCurrent == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Chào mừng ${state.user.fullName} trở lại!"),
                    backgroundColor: Colors.green.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainTabScreen()),
                  (route) => false,
                );
              }
            } 
            else if (state is AuthFailure) {
              if (ModalRoute.of(context)?.isCurrent == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDemoLogo(),
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Paws SOS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF43F5E),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cứu hộ động vật khẩn cấp',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        TextFormField(
                          controller: _usernameController,
                          keyboardType: TextInputType.phone, 
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Số điện thoại', 
                            prefixIcon: Icon(Icons.phone_android),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitForm(),
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Chức năng quên mật khẩu (sẽ làm sau)
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFF43F5E),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading ? null : _submitForm, 
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'ĐĂNG NHẬP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'HOẶC',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => const RegisterScreen())
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                                children: [
                                  const TextSpan(text: 'Chưa có tài khoản? '),
                                  TextSpan(text: 'Đăng ký ngay', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDemoLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF43F5E).withOpacity(0.1),
          width: 4,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.pets,
            size: 55,
            color: Color(0xFFF43F5E),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_circle,
                size: 20,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}