import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paw_sos/screen/card/radar_item_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'active_rescue_screen.dart'; 
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart'; 
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_bloc.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_event.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_state.dart';
class RescueMapScreen extends StatefulWidget {
  final AnimalReportModel? initialReport; 
  final bool isMainTab; 

  const RescueMapScreen({super.key, this.initialReport, this.isMainTab = false});

  @override
  State<RescueMapScreen> createState() => _RescueMapScreenState();
}

class _RescueMapScreenState extends State<RescueMapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  
  bool _showDetailPanel = false; 
  bool _showRadarPanel = true; 
  AnimalReportModel? _selectedReport; 
  
  LatLng _myLocation = const LatLng(10.762622, 106.660172); // Mặc định trước khi có GPS
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    context.read<RescueBloc>().add(LoadRadarReports());
    _fetchMyLocation(); // Gọi hàm lấy GPS

    if (widget.initialReport != null) {
      _selectedReport = widget.initialReport;
      _showDetailPanel = true; 
    } else {
      _showRadarPanel = !widget.isMainTab;
    }
  }

  void _openDetail(AnimalReportModel report) {
    setState(() {
      _selectedReport = report;
      _showDetailPanel = true;
    });
    
    if (report.noiseLat != null && report.noiseLng != null) {
      _mapController.move(LatLng(report.noiseLat! - 0.005, report.noiseLng!), 14.5);
    }
  }

  void _closeDetail() {
    setState(() {
      _showDetailPanel = false;
      _selectedReport = null; 
    });
  }

  Future<void> _fetchMyLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        if (mounted) {
          setState(() {
            _myLocation = LatLng(pos.latitude, pos.longitude);
            _isLocating = false;
          });
          if (_selectedReport == null) {
            _mapController.move(_myLocation, 14.0);
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi GPS Radar: $e');
    }
  }

  void _handleClaimRescue() {
    if (_selectedReport != null) {
      context.read<RescueBloc>().add(AcceptMission(_selectedReport!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<RescueBloc, RescueState>(
      listener: (context, state) {
        if (state is RescueMissionAccepted) {
          
          final missionToRescue = _selectedReport;
          
          _closeDetail();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã nhận ca! Bắt đầu định tuyến...'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            )
          );
          
          if (missionToRescue != null) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (mounted) {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) => ActiveRescueScreen(mission: missionToRescue),
                  ),
                ).then((_) {
                  context.read<RescueBloc>().add(LoadRadarReports());
                });
              }
            });
          }
        } else if (state is RescueError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        List<AnimalReportModel> nearbyReports = [];
        AnimalReportModel? ongoingMission; 

        if (state is RadarLoaded) {
          nearbyReports = state.reports;
          ongoingMission = state.ongoingMission; 
        }

        final isClaiming = state is RescueLoading && _selectedReport != null;
        final isLoadingRadar = state is RescueLoading && _selectedReport == null;

        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _myLocation, 
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.paw_sos.app',
                    ),
                    CircleLayer(
                      circles: _buildRadarCircles(nearbyReports),
                    ),
                    MarkerLayer(
                      markers: [
                        if (!_isLocating)
                          Marker(
                            point: _myLocation,
                            width: 50, height: 50,
                            child: Container(
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.3), shape: BoxShape.circle),
                              child: const Center(child: Icon(Icons.my_location, color: Colors.blue, size: 24)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!widget.isMainTab) 
                      CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)))
                    else
                      const SizedBox(width: 40), 

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                      child: Row(
                        children: [
                          if (isLoadingRadar) 
                             const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          else
                             const Icon(Icons.radar, color: Colors.blue, size: 16), 
                          const SizedBox(width: 8),
                          const Text('Radar Paws SOS', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9), child: const Icon(Icons.filter_alt, color: Colors.black87)),
                  ],
                ),
              ),

              if (ongoingMission != null && !_showDetailPanel)
                Positioned(
                  top: 110, left: 16, right: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => ActiveRescueScreen(mission: ongoingMission!),
                        ),
                      ).then((_) => context.read<RescueBloc>().add(LoadRadarReports()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NHIỆM VỤ ĐANG THỰC HIỆN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('Chạm để tiếp tục đi cứu ${ongoingMission.animalType}', style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
                        ],
                      ),
                    ),
                  ),
                ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                left: 0, right: 0,
                bottom: (_showRadarPanel && !_showDetailPanel) ? 0 : -screenHeight,
                child: _buildRadarPanel(nearbyReports, isLoadingRadar),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                left: 0, right: 0,
                bottom: _showDetailPanel ? 0 : -screenHeight,
                child: _buildDetailPanel(isClaiming),
              ),

              if (widget.isMainTab && !_showDetailPanel)
                Positioned(
                  bottom: 24, right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () => setState(() => _showRadarPanel = !_showRadarPanel),
                    child: Icon(_showRadarPanel ? Icons.map : Icons.format_list_bulleted, color: const Color(0xFFF43F5E)),
                  ),
                )
            ],
          ),
        );
      }
    );
  }

  List<CircleMarker> _buildRadarCircles(List<AnimalReportModel> nearbyReports) {
    List<CircleMarker> circles = [];
    if (_selectedReport != null && _selectedReport!.noiseLat != null) {
      circles.add(CircleMarker(
        point: LatLng(_selectedReport!.noiseLat!, _selectedReport!.noiseLng!),
        color: Colors.red.withOpacity(0.3), borderColor: Colors.red, borderStrokeWidth: 2, useRadiusInMeter: true, radius: 500, 
      ));
    } else {
      for (var report in nearbyReports) {
        if (report.noiseLat != null) {
          circles.add(CircleMarker(
            point: LatLng(report.noiseLat!, report.noiseLng!),
            color: Colors.blue.withOpacity(0.15), borderColor: Colors.blue, borderStrokeWidth: 1, useRadiusInMeter: true, radius: 500,
          ));
        }
      }
    }
    return circles;
  }

  Widget _buildRadarPanel(List<AnimalReportModel> reports, bool isLoading) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))]),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gần bạn nhất', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Quét thấy ${reports.length} ca trong bán kính 5km', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                TextButton.icon(onPressed: () => context.read<RescueBloc>().add(LoadRadarReports()), icon: const Icon(Icons.refresh, size: 16), label: const Text('Làm mới'))
              ],
            ),
          ),
          Expanded(
            child: isLoading && reports.isEmpty 
              ? const Center(child: CircularProgressIndicator()) 
              : reports.isEmpty 
                  ? const Center(child: Text("Xung quanh khu vực này hiện rất an bình 🐾", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        return RadarItemCard(
                          report: reports[index],
                          onTap: () => _openDetail(reports[index]),
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailPanel(bool isClaiming) {
    if (_selectedReport == null) return const SizedBox.shrink();
    
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isMyOwnReport = _selectedReport!.reporterId == currentUserId;

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, -10))]),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.close), onPressed: _closeDetail),
              const Expanded(child: Center(child: SizedBox(width: 40, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey))))),
              const SizedBox(width: 48), 
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red.shade200), borderRadius: BorderRadius.circular(6)), child: Text('KHẨN CẤP (${_selectedReport!.status})', style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  Text(_selectedReport!.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(_selectedReport!.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover)),
                      Positioned(
                        bottom: 8, right: 8,
                        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)), child: const Row(children: [Icon(Icons.lock, color: Colors.yellow, size: 14), SizedBox(width: 6), Text('Tọa độ đang bảo mật', style: TextStyle(color: Colors.white, fontSize: 11))])),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(12)),
                    child: RichText(text: TextSpan(style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5), children: [TextSpan(text: 'Mô tả từ Reporter: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)), TextSpan(text: _selectedReport!.description.isEmpty ? "Không có" : _selectedReport!.description)])),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [Icon(Icons.info_outline, color: Colors.blue.shade400), const SizedBox(width: 12), const Expanded(child: Text('Nhấn Tiếp nhận, hệ thống sẽ mở khóa API RLS và gửi tọa độ GPS chính xác. Không nhận mà bỏ sẽ bị trừ điểm.', style: TextStyle(fontSize: 12, color: Colors.black54)))]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isMyOwnReport ? null : (isClaiming ? null : _handleClaimRescue),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMyOwnReport ? Colors.grey.shade400 : Colors.red.shade500, 
                        padding: const EdgeInsets.symmetric(vertical: 16), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      icon: isClaiming 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : Icon(isMyOwnReport ? Icons.pan_tool : Icons.favorite, color: Colors.white),
                      label: Text(
                        isMyOwnReport 
                            ? 'BẠN KHÔNG THỂ TỰ NHẬN CA CỦA MÌNH' 
                            : (isClaiming ? 'Đang gọi Supabase...' : 'TÔI SẼ ĐI CỨU BÉ NÀY!'), 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}