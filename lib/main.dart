import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/pages/login_screen.dart';
import 'package:paw_sos/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:paw_sos/features/auth/data/repositories/auth_repositories_impl.dart';
import 'package:paw_sos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:paw_sos/features/report/data/datasources/report_remote_data_source.dart';
import 'package:paw_sos/features/report/data/repositories/report_repository_impl.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_bloc.dart';
import 'package:paw_sos/features/rescue/data/datasources/rescue_remote_data_source.dart';
import 'package:paw_sos/features/rescue/data/repositories/rescue_repository_impl.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_radar_reports_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/accept_mission_usecase.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_bloc.dart';
import 'package:paw_sos/features/rescue/domain/usecases/get_ongoing_mission_usecase.dart';
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
  // khởi tạo data source và repository cho AuthBloc
  final authRemoteDataSource = AuthRemoteDataSourceImpl(supabaseClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  // khởi tạo data source và repository cho ReportBloc
  final reportRemoteDataSource = ReportRemoteDataSourceImpl(supabaseClient);
  final reportRepository = ReportRepositoryImpl(reportRemoteDataSource);
 // khởi tạo data source và repository cho RescueBloc
  final rescueRemoteDataSource = RescueRemoteDataSourceImpl(supabaseClient);
  final rescueRepository = RescueRepositoryImpl(rescueRemoteDataSource);
  final getRadarReportsUseCase = GetRadarReportsUseCase(rescueRepository);
  final acceptMissionUseCase = AcceptMissionUseCase(rescueRepository);
  final checkOngoingMissionUseCase = CheckOngoingMissionUseCase(rescueRepository);
  runApp(MultiBlocProvider(
    providers:[
      BlocProvider(
        create: (context) => AuthBloc(authRepository: authRepository),
      ),
      BlocProvider(
        create: (context) => ReportBloc(reportRepository: reportRepository),
      ),
      BlocProvider(
        create: (context) => RescueBloc(
          getRadarReportsUseCase: getRadarReportsUseCase,
          acceptMissionUseCase: acceptMissionUseCase,
          checkOngoingMissionUseCase: checkOngoingMissionUseCase,
        ),
      ),
    ],
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
