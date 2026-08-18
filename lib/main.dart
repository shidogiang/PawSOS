import 'package:flutter/material.dart';
import 'package:paw_sos/features/message/data/datasources/message_remote_datasource.dart';
import 'package:paw_sos/features/message/data/repositories/message_repository_impl.dart';
import 'package:paw_sos/features/message/domain/usecases/send_message_usecase.dart';
import 'package:paw_sos/features/message/domain/usecases/stream_message_usecase.dart';
import 'package:paw_sos/features/message/presentation/bloc/message_bloc.dart';
import 'package:paw_sos/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:paw_sos/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:paw_sos/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:paw_sos/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:paw_sos/features/report/domain/usecases/delete_report_usecase.dart';
import 'package:paw_sos/features/report/domain/usecases/stream_report_usecase.dart';
import 'package:paw_sos/features/rescue/domain/usecases/cancel_mission_usecase.dart';
import 'package:paw_sos/screen/start/main_tab_screen.dart';
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
import 'package:paw_sos/features/rescue/domain/usecases/complete_mission_usecase.dart';
import 'features/adoption/data/datasources/adoption_remote_datasouce.dart';
import 'features/adoption/data/repositories/adoption_repository_impl.dart';
import 'features/adoption/domain/usecases/get_my_tracking_usecase.dart';
import 'features/adoption/domain/usecases/submit_weekly_usecase.dart';
import 'features/adoption/presentation/bloc/adoption_bloc.dart';
import 'features/adoption/domain/usecases/get_activity_stats_usecase.dart';
import 'features/notification/data/datasources/noti_remote_datasource.dart';
import 'features/notification/data/repositories/noti_repository_impl.dart';
import 'features/notification/domain/usecases/stream_usecase.dart';
import 'features/notification/domain/usecases/mark_noti_usecase.dart';
import 'features/notification/presentation/bloc/noti_bloc.dart';


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
  final streamMyReportsUseCase = StreamMyReportsUseCase(reportRepository);
  final deleteReportUseCase = DeleteReportUseCase(reportRepository);
 // khởi tạo data source và repository cho RescueBloc
  final rescueRemoteDataSource = RescueRemoteDataSourceImpl(supabaseClient);
  final rescueRepository = RescueRepositoryImpl(rescueRemoteDataSource);
  final getRadarReportsUseCase = GetRadarReportsUseCase(rescueRepository);
  final acceptMissionUseCase = AcceptMissionUseCase(rescueRepository);
  final checkOngoingMissionUseCase = CheckOngoingMissionUseCase(rescueRepository);
  final completeMissionUseCase = CompleteMissionUseCase(rescueRepository);
  final cancelMissionUseCase = CancelMissionUseCase(rescueRepository);

  // khởi tạo data source và repository cho AdoptionBloc
  final adoptionRemoteDataSource = AdoptionRemoteDataSourceImpl(supabaseClient);
  final adoptionRepository = AdoptionRepositoryImpl(adoptionRemoteDataSource);
  final getMyTrackingsUseCase = GetMyTrackingsUseCase(adoptionRepository);
  final submitWeeklyImageUseCase = SubmitWeeklyImageUseCase(adoptionRepository);
  final getActivityStatsUseCase = GetActivityStatsUseCase(adoptionRepository);
  //khởi tạo data source và repository cho NotificationBloc
  final notificationRemoteDataSource = NotificationRemoteDataSourceImpl(supabaseClient);
  final notificationRepository = NotificationRepositoryImpl(notificationRemoteDataSource);
  final streamNotificationsUseCase = StreamNotificationsUseCase(notificationRepository);
  final markNotificationReadUseCase = MarkNotificationReadUseCase(notificationRepository);
  // khởi tạo data source và repo cho MessageBloc
  final chatRemoteDataSource = ChatRemoteDataSourceImpl(supabaseClient);
  final chatRepository = ChatRepositoryImpl(chatRemoteDataSource);
  final streamMessagesUseCase = StreamMessagesUseCase(chatRepository);
  final sendMessageUseCase = SendMessageUseCase(chatRepository);
  // khởi tạo data và repo cho ProfileBloc
  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(supabaseClient);
  final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);
  final getProfileUseCase = GetProfileUseCase(profileRepository);

   
  runApp(MultiBlocProvider(
    providers:[
      BlocProvider(
        create: (context) => AuthBloc(authRepository: authRepository),
      ),
      BlocProvider(
        create: (context) => ReportBloc(reportRepository: reportRepository),
      ),
      BlocProvider(
        create: (context) => MyReportBloc(streamMyReportsUseCase: streamMyReportsUseCase, deleteReportUseCase: deleteReportUseCase)
      ),
      BlocProvider(
        create: (context) => RescueBloc(
          getRadarReportsUseCase: getRadarReportsUseCase,
          acceptMissionUseCase: acceptMissionUseCase,
          checkOngoingMissionUseCase: checkOngoingMissionUseCase,
          completeMissionUseCase: completeMissionUseCase,
          cancelMissionUseCase: cancelMissionUseCase,

        ),
      ),
      BlocProvider(
        create: (context) => AdoptionBloc(
          getMyTrackingsUseCase: getMyTrackingsUseCase,
          submitWeeklyImageUseCase: submitWeeklyImageUseCase,
          getActivityStatsUseCase: getActivityStatsUseCase,
        ),
      ),
      BlocProvider(
        create: (context) => NotificationBloc(
          streamNotificationsUseCase: streamNotificationsUseCase,
          markNotificationReadUseCase: markNotificationReadUseCase,
        ),
      ),
      BlocProvider(
        create: (context) => ChatBloc(
          streamMessagesUseCase: streamMessagesUseCase,
          sendMessageUseCase: sendMessageUseCase,
        ),
      ),
       BlocProvider(
        create: (context) => ProfileBloc(
          getProfileUseCase: getProfileUseCase,
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
      home: Supabase.instance.client.auth.currentSession != null 
        ? const MainTabScreen() 
        : const LoginScreen(),
    
    );
  }
}
