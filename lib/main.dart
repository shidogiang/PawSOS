import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/pages/login_screen.dart';
import 'screen/start/main_tab_screen.dart';
import 'package:paw_sos/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:paw_sos/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_bloc.dart';
void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
      await Supabase.initialize(
          url: 'https://vtwqngkmizyqadmcmbmo.supabase.co', // TODO: Dán Project URL của đại ca vào đây
          publishableKey: 'sb_publishable_YpSYI-WhDMhyH9BVOIV_Hw_epowOCjy', // TODO: Dán API Key (anon/public) vào đây
        );
      debugPrint("Supabase initialized successfully");
  } 
  catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }
  //  Khởi tạo toàn bộ Dependency Injection trước khi chạy App
  final supabaseClient = Supabase.instance.client;
  final authRemoteDataSource = AuthRemoteDataSourceImpl(supabaseClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  runApp(BlocProvider(
    create: (context) => AuthBloc(authRepository: authRepository),
    child: const PawsSOSApp(),
  ));
}

class PawsSOSApp extends StatelessWidget {
  const PawsSOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paws SOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF43F5E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF43F5E),
          primary: const Color(0xFFF43F5E),
        ),
        fontFamily: 'Roboto', 
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF43F5E),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      // ROUTING LOGIC 
      home: const LoginScreen(),
    
    );
  }
}
