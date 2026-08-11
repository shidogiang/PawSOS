import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_event.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_state.dart';
import 'package:paw_sos/screen/start/main_tab_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isTermsChecked = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_validateForm);
    _phoneCtrl.addListener(_validateForm);
    _passCtrl.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isNameValid = _nameCtrl.text.trim().isNotEmpty;
    final isPhoneValid = _phoneCtrl.text.trim().length >= 9;
    final isPassValid = _passCtrl.text.length >= 6;
    
    setState(() {
      _isFormValid = isNameValid && isPhoneValid && isPassValid && _isTermsChecked;
    });
  }

  // bơm Event vào BLoC
  void _handleSubmit() {
    if (!_isFormValid) return;

    FocusScope.of(context).unfocus();

    // format số điện thoại chuẩn quốc tế (E.164) cho Supabase
    String rawPhone = _phoneCtrl.text.trim();
    if (rawPhone.startsWith('0')) {
      rawPhone = rawPhone.substring(1); // Bỏ số 0 ở đầu nếu có
    }
    String formattedPhone = '+84$rawPhone';

    // Bơm Event vào BLoC
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(
        fullName: _nameCtrl.text.trim(),
        phone: formattedPhone,
        password: _passCtrl.text,
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required Widget prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
      prefixIcon: prefix,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //  BlocConsumer để lắng nghe các trạng thái từ AuthBloc
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // TUYỆT CHIÊU: Chỉ chạy khi màn hình này đang hiển thị trên cùng
            if (ModalRoute.of(context)?.isCurrent == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tạo tài khoản thành công! Đang vào ứng dụng..."),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Đá thẳng vào màn hình chính luôn vì Supabase đã tự login
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
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // Đọc trạng thái loading từ BLoC để hiện overlay
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red.shade500, Colors.orange.shade400],
                      ),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -20, right: -10,
                          child: Transform.rotate(
                            angle: 0.2,
                            child: Icon(Icons.pets, size: 100, color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        Positioned(
                          top: 40, left: -20,
                          child: Transform.rotate(
                            angle: -0.2,
                            child: Icon(Icons.pets, size: 80, color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                        Positioned(
                          top: 20, left: -10,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Positioned(
                          bottom: 0, left: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paws SOS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
                              Text('Trở thành anh hùng cứu hộ ngay hôm nay!', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đăng ký tài khoản', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 24),
                          const Text('HỌ VÀ TÊN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _nameCtrl,
                            keyboardType: TextInputType.name,
                            decoration: _buildInputDecoration(
                              hint: 'Nguyễn Văn A',
                              prefix: const Icon(Icons.person, color: Colors.grey, size: 20),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('SỐ ĐIỆN THOẠI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: _buildInputDecoration(
                              hint: '987 654 321',
                              prefix: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.grey.shade300))),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [Text('+84', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))],
                                ),
                              ),
                            ).copyWith(counterText: ''), 
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Row(
                              children: [
                                Icon(Icons.shield, color: Colors.green.shade500, size: 12),
                                const SizedBox(width: 4),
                                const Text('Dùng để gửi mã OTP xác thực', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('MẬT KHẨU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passCtrl,
                            obscureText: !_isPasswordVisible,
                            decoration: _buildInputDecoration(
                              hint: 'Tối thiểu 6 ký tự',
                              prefix: const Icon(Icons.lock, color: Colors.grey, size: 20),
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: _isPasswordVisible ? Colors.red.shade500 : Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: _isTermsChecked,
                                  activeColor: Colors.red.shade500,
                                  onChanged: (val) {
                                    setState(() {
                                      _isTermsChecked = val ?? false;
                                      _validateForm(); 
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isTermsChecked = !_isTermsChecked;
                                      _validateForm();
                                    });
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                                      children: [
                                        const TextSpan(text: 'Tôi đồng ý với '),
                                        TextSpan(text: 'Điều khoản Dịch vụ', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ' và '),
                                        TextSpan(text: 'Chính sách Bảo mật', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                        const TextSpan(text: ' của Paws SOS. Hệ thống nghiêm cấm mọi hành vi tạo báo cáo giả mạo.'),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isFormValid ? _handleSubmit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade500,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: _isFormValid ? 4 : 0,
                              ),
                              child: const Text('Tạo tài khoản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  children: [
                                    const TextSpan(text: 'Đã có tài khoản? '),
                                    TextSpan(text: 'Đăng nhập ngay', style: TextStyle(color: Colors.red.shade500, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ĐÃ SỬA: Hiển thị loading overlay dựa vào state của BLoC
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.9),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.red.shade500, strokeWidth: 4),
                        const SizedBox(height: 20),
                        const Text('Đang kết nối Supabase...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        const Text('Vui lòng đợi trong giây lát', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}