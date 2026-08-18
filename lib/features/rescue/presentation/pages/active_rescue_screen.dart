
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_bloc.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_event.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_state.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/message/presentation/pages/chat_screen.dart';
import 'package:paw_sos/screen/main_function/contact/call_screen.dart';
import 'rescue_confirmation_screen.dart';

class ActiveRescueScreen extends StatefulWidget {
  final AnimalReportModel mission;

  const ActiveRescueScreen({super.key, required this.mission});

  @override
  State<ActiveRescueScreen> createState() => _ActiveRescueScreenState();
}

class _ActiveRescueScreenState extends State<ActiveRescueScreen> {
  final MapController _mapController = MapController();
  
  LatLng? _rescuerLocation;
  LatLng? _animalExactLocation;
  List<LatLng> _routePoints = [];
  
  bool _isLoading = true;
  String _distanceStr = 'Đang tính...';
  String _durationStr = '-- phút';

  @override
  void initState() {
    super.initState();
    // Delay 600ms để màn hình trượt ra xong xuôi mới gọi GPS, chống giật lag UI
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _initializeTacticalMap();
    });
  }

  Future<void> _initializeTacticalMap() async {
    try {
      // lấy tọa độ gps
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          try {
            // Lấy GPS không cần giới hạn thời gian, máy sẽ tự rà vệ tinh
            Position pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            _rescuerLocation = LatLng(pos.latitude, pos.longitude);
          } catch (e) {
            debugPrint("Lỗi lấy GPS: $e");
          }
        }
      }

      // Fallback về tọa độ mặc định nếu tắt GPS
      _rescuerLocation ??= const LatLng(10.762622, 106.660172);

      // lấy tọa độ thú cưng
      try {
        final response = await Supabase.instance.client
            .from('secure_report_locations')
            .select()
            .eq('report_id', widget.mission.id)
            .single();

        _animalExactLocation = LatLng(
          (response['exact_lat'] as num).toDouble(),
          (response['exact_lng'] as num).toDouble(),
        );
      } catch (e) {
        debugPrint("Lỗi RLS Két sắt: $e");
        _animalExactLocation = LatLng(widget.mission.noiseLat ?? 10.77, widget.mission.noiseLng ?? 106.65);
      }

      // vẽ đường đi 
      await _fetchRouteOSRM();

    } catch (e) {
      debugPrint("Lỗi tổng: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _fitMapBounds();
        });
      }
    }
  }

  Future<void> _fetchRouteOSRM() async {
    if (_rescuerLocation == null || _animalExactLocation == null) return;

    final start = '${_rescuerLocation!.longitude},${_rescuerLocation!.latitude}';
    final end = '${_animalExactLocation!.longitude},${_animalExactLocation!.latitude}';
    
    final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$start;$end?overview=full&geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          _routePoints = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();
          
          final distance = routes[0]['distance'] as num; 
          final duration = routes[0]['duration'] as num; 
          
          if (mounted) {
            setState(() {
              _distanceStr = distance > 1000 ? '${(distance / 1000).toStringAsFixed(1)} km' : '${distance.toStringAsFixed(0)} m';
              _durationStr = '${(duration / 60).ceil()} phút';
            });
          }
        }
      }
    } catch(e) {
      debugPrint("Lỗi OSRM: $e");
    }
  }

  void _fitMapBounds() {
    if (_routePoints.isEmpty || _isLoading) return;
    final bounds = LatLngBounds.fromPoints(_routePoints);
    _mapController.move(bounds.center, 14.5); 
  }

  Future<void> _launchGoogleMaps() async {
    if (_animalExactLocation == null) return;
    final lat = _animalExactLocation!.latitude;
    final lng = _animalExactLocation!.longitude;
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=two-wheeler');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở Google Maps trên máy này')));
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28), SizedBox(width: 8), Text('Hủy cứu hộ?')]),
        content: const Text('Bạn có chắc chắn muốn hủy nhiệm vụ này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('QUAY LẠI', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); 
              context.read<RescueBloc>().add(CancelMissionEvent(widget.mission.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ĐỒNG Ý HỦY', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RescueBloc, RescueState>(
      listener: (context, state) {
        if (state is RescueMissionCanceled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy nhiệm vụ!'), backgroundColor: Colors.orange)
          );
          Navigator.pop(context); 
          context.read<RescueBloc>().add(LoadRadarReports());
        } else if (state is RescueError) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Lỗi: ${state.message}'), backgroundColor: Colors.red)
           );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Stack(
          children: [
            Positioned.fill(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _rescuerLocation ?? const LatLng(10.762622, 106.660172),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.paw_sos.app',
                        ),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(points: _routePoints, strokeWidth: 5.0, color: Colors.blueAccent.shade400),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            if (_rescuerLocation != null)
                              Marker(
                                point: _rescuerLocation!, width: 50, height: 50,
                                child: Container(decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle), child: const Center(child: Icon(Icons.my_location, color: Colors.blue, size: 24))),
                              ),
                            if (_animalExactLocation != null)
                              Marker(
                                point: _animalExactLocation!, width: 60, height: 60,
                                child: Column(
                                  children: [
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Text('4m', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                                    const Icon(Icons.location_on, color: Colors.red, size: 40),
                                  ],
                                ),
                              )
                          ],
                        ),
                      ],
                    ),
            ),

            Positioned(
              top: 50, left: 16, right: 16,
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _showCancelDialog(context))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade400)),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_run, color: Colors.green), const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ĐANG TRONG NHIỆM VỤ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                              if (!_isLoading) Text('Cách đích $_distanceStr • $_durationStr', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))]),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(widget.mission.imageUrl, width: 50, height: 50, fit: BoxFit.cover)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const Text('Đã mở khóa tọa độ thật', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.shade100)),
                        child: Row(
                          children: [
                            CircleAvatar(backgroundColor: Colors.blue.shade200, radius: 18, child: const Icon(Icons.person, color: Colors.white, size: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Người báo cáo', style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w600)),
                                  const Text('Chạm để gọi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(reporterName: 'Người báo cáo', reportId: widget.mission.id))), icon: const Icon(Icons.chat_bubble_rounded, color: Colors.blue, size: 20), style: IconButton.styleFrom(backgroundColor: Colors.white, shadowColor: Colors.black12, elevation: 1)),
                            const SizedBox(width: 8),
                            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CallScreen(reporterName: 'Reporter'))), icon: const Icon(Icons.phone_in_talk, color: Colors.green, size: 20), style: IconButton.styleFrom(backgroundColor: Colors.white, shadowColor: Colors.black12, elevation: 1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _launchGoogleMaps, 
                              icon: const Icon(Icons.directions), label: const Text('Google Maps'),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.blue)),
                            )
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => RescueConfirmationScreen(mission: widget.mission)),
                                );
                              }, 
                              icon: const Icon(Icons.camera_alt), label: const Text('Đã tới nơi'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                            )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}