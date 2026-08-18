import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart'; // IMPORT MAP
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


import 'package:paw_sos/features/notification/presentation/bloc/noti_bloc.dart';
import 'package:paw_sos/features/notification/presentation/bloc/noti_state.dart';
import 'package:paw_sos/features/notification/presentation/pages/NotificationScreen.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_bloc.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_event.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_state.dart';
import 'package:paw_sos/screen/card/home_function_card/report_card.dart';
import 'package:paw_sos/screen/card/home_function_card/hero_service_card.dart';
import 'package:paw_sos/features/report/presentation/pages/report_screen.dart';
import 'package:paw_sos/features/rescue/presentation/pages/rescue_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = 'Đang định vị...';
  LatLng _myLocation = const LatLng(10.762622, 106.660172); // Tọa độ mặc định
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    context.read<RescueBloc>().add(LoadRadarReports());
    
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _currentAddress = 'GPS đang tắt');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentAddress = 'Chưa cấp quyền GPS');
          return;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      if (mounted) {
        setState(() {
          _myLocation = LatLng(pos.latitude, pos.longitude);
          _isLocating = false;
        });
      }

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'paw_sos_app', 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        
        if (address != null) {
          final road = address['road'] ?? address['pedestrian'];
          final suburb = address['suburb'] ?? address['quarter'] ?? address['neighbourhood'];
          final city = address['city'] ?? address['town'] ?? address['county'] ?? address['state'];
          
          List<String> parts = [];
          if (road != null) parts.add(road);
          if (suburb != null) parts.add(suburb);
          if (city != null) parts.add(city);
          
          String finalAddress = parts.join(', ');
          
          if (mounted) {
            setState(() {
              _currentAddress = finalAddress.isNotEmpty ? finalAddress : 'Khu vực không xác định';
            });
          }
        }
      } else {
        if (mounted) setState(() => _currentAddress = 'Lỗi dịch địa chỉ');
      }
    } catch (e) {
      if (mounted) setState(() => _currentAddress = 'Chưa xác định vị trí');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFFF43F5E),
            actions: [
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  int unreadCount = 0;
                  if (state is NotificationLoaded) {
                    unreadCount = state.unreadCount;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          );
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 10, right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.yellow, shape: BoxShape.circle),
                            child: Text(
                              unreadCount > 9 ? '9+' : unreadCount.toString(),
                              style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 60), 
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vị trí hiện tại', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _currentAddress, 
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFFF43F5E), Colors.red.shade400],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào,👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      HeroServiceCard(
                        title: 'Báo cáo\nKhẩn cấp', icon: Icons.add_a_photo_outlined, color: Colors.orange.shade600,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportEmergencyScreen()));
                        },
                      ),
                      const SizedBox(width: 16),
                      HeroServiceCard(
                        title: 'Nhận nuôi\n& Cứu hộ', icon: Icons.volunteer_activism_outlined, color: const Color(0xFFF43F5E),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RescueMapScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text('Bản đồ khu vực của bạn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RescueMapScreen()));
                    },
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            if (!_isLocating)
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: _myLocation,
                                  initialZoom: 15.0,
                                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.paw_sos.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _myLocation, width: 40, height: 40,
                                        child: const Icon(Icons.location_on, color: Color(0xFFF43F5E), size: 40),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            else
                              const Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E))),
                            
                            Container(color: Colors.blue.withOpacity(0.05)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cần cứu hộ khẩn cấp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RescueMapScreen())),
                        child: const Text('Xem tất cả', style: TextStyle(color: Color(0xFFF43F5E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  BlocBuilder<RescueBloc, RescueState>(
                    builder: (context, state) {
                      if (state is RescueLoading) {
                        return const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E))));
                      }

                      List<AnimalReportModel> recentReports = [];
                      if (state is RadarLoaded) {
                        recentReports = state.reports.where((r) => r.status == 'OPEN').toList();
                      }

                      if (recentReports.isEmpty) {
                        return SizedBox(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified, size: 48, color: Colors.green.shade200),
                                const SizedBox(height: 8),
                                const Text('Khu vực an toàn, không có SOS!', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentReports.length, 
                          itemBuilder: (context, index) {
                            return SOSItemCard(
                              report: recentReports[index], 
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => RescueMapScreen(initialReport: recentReports[index]),
                                ));
                              },
                            );
                          },
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 40), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}