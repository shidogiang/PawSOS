import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

import 'package:paw_sos/features/adoption/data/models/AdoptionTrackingModel.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_bloc.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_event.dart';
import 'package:paw_sos/features/adoption/presentation/bloc/adoption_state.dart';
import 'package:paw_sos/core/utils/imageCompressHelper.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_bloc.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_event.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_state.dart';
import 'package:paw_sos/features/message/presentation/pages/chat_screen.dart' as paw_sos;
import 'package:paw_sos/features/report/presentation/pages/edit_report_screen.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdoptionBloc>().add(LoadMyTrackings());
    context.read<MyReportBloc>().add(StartListeningMyReports());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Hoạt động', style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: Column(
              children: [
                BlocBuilder<AdoptionBloc, AdoptionState>(
                  builder: (context, state) {
                    int rescued = 0;
                    int reported = 0;
                    
                    if (state is AdoptionLoaded) {
                      rescued = state.rescuedCount;
                      reported = state.reportedCount;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          _buildStatCard(
                            icon: Icons.volunteer_activism, iconColor: Colors.green.shade600, bgColor: Colors.green.shade50,
                            label: 'Đã cứu', value: rescued.toString(), unit: 'bé',
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            icon: Icons.campaign, iconColor: Colors.blue.shade600, bgColor: Colors.blue.shade50,
                            label: 'Báo cáo', value: reported.toString(), unit: 'ca',
                          ),
                        ],
                      ),
                    );
                  },
                ),
                TabBar(
                  labelColor: Colors.red.shade500,
                  unselectedLabelColor: Colors.grey.shade500,
                  indicatorColor: Colors.red.shade500,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(text: 'Nhiệm vụ cứu hộ'),
                    Tab(text: 'Ca tôi báo cáo'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildRescueTasksTab(), 
            _buildMyReportsTab(),   
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required Color bgColor, required String label, required String value, required String unit}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: iconColor.withOpacity(0.2))),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.1)),
                    const SizedBox(width: 2),
                    Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRescueTasksTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdoptionBloc>().add(LoadMyTrackings());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BlocConsumer<AdoptionBloc, AdoptionState>(
            listener: (context, state) {
              if (state is AdoptionPhotoSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
              } else if (state is AdoptionError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
              }
            },
            builder: (context, state) {
              if (state is AdoptionLoading) {
                return const Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator(color: Colors.purple)));
              } else if (state is AdoptionLoaded) {
                if (state.trackings.isEmpty) {
                  return _buildEmptyState(Icons.pets, "Chưa có nhiệm vụ nào.", "Hãy nhận nuôi hoặc đi cứu hộ để tích điểm nhé!");
                }
                return Column(children: state.trackings.map((tracking) => _DynamicAdoptionCard(model: tracking)).toList());
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  // --- TAB CA TÔI BÁO CÁO (CÓ SWIPE TO DELETE) ---
  Widget _buildMyReportsTab() {
    return BlocBuilder<MyReportBloc, ReportState>(
      builder: (context, state) {
        if (state is MyReportLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }
        
        if (state is MyReportLoaded) {
          final data = state.reports;
          
          if (data.isEmpty) {
            return _buildEmptyState(Icons.speaker_notes_off, "Chưa có báo cáo nào.", "Khi bạn báo cáo SOS, trạng thái sẽ cập nhật tại đây.");
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final report = data[index];
              
              Color statusColor; String statusText; IconData statusIcon;
              if (report.status == 'OPEN') {
                statusColor = Colors.red; statusText = 'ĐANG CHỜ TÌM KIẾM'; statusIcon = Icons.wifi_tethering;
              } else if (report.status == 'IN_PROGRESS') {
                statusColor = Colors.blue; statusText = 'ĐÃ CÓ NGƯỜI NHẬN CỨU'; statusIcon = Icons.directions_run;
              } else {
                statusColor = Colors.green; statusText = 'ĐÃ HOÀN TẤT'; statusIcon = Icons.check_circle;
              }

              // WIDGET VUỐT ĐỂ XÓA
              return Dismissible(
                key: Key(report.id),
                direction: DismissDirection.endToStart, // Chỉ cho vuốt từ Phải sang Trái
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(color: Colors.red.shade500, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                      Text('Xóa ca này', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                    ],
                  ),
                ),
                // Hỏi xác nhận trước khi xóa thật
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 8), Text('Xác nhận xóa')]),
                      content: const Text('Bạn có chắc chắn muốn gỡ bỏ báo cáo SOS này không? Dữ liệu không thể khôi phục.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true), 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Xóa Báo Cáo', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  // Bắn Event xuống Bloc để dọn dẹp Database
                  context.read<MyReportBloc>().add(DeleteReportEvent(report.id));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa báo cáo SOS!'), backgroundColor: Colors.orange));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(report.animalType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(statusText, style: TextStyle(color: Color(0xFF1976D2), fontSize: 10, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(report.timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 12),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: Color(0xFFF43F5E), size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(report.description.isEmpty ? "Không có mô tả" : report.description, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      // THANH CÔNG CỤ: CHỈNH SỬA & NHẮN TIN
                      Row(
                        children: [
                          // Nút Chỉnh Sửa (Chuẩn bị cho Phase sau)
                          if (report.status == 'OPEN')
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditReportScreen(report: report)));
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: const Text('Sửa'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.blue.shade700, side: BorderSide(color: Colors.blue.shade200), padding: const EdgeInsets.symmetric(vertical: 8)),
                              ),
                            ),
                          if (report.status == 'OPEN') const SizedBox(width: 8),

                          // Nút Nhắn tin (Chỉ hiện khi có người nhận)
                          if (report.status == 'IN_PROGRESS') 
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => paw_sos.ChatScreen(reporterName: 'Hiệp sĩ cứu hộ', reportId: report.id)));
                                },
                                icon: const Icon(Icons.chat, size: 16),
                                label: const Text('Nhắn tin với Hiệp sĩ', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      }
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 60.0),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        )
      ),
    );
  }
}

// ... Giữ nguyên phần _DynamicAdoptionCard như cũ ...
class _DynamicAdoptionCard extends StatefulWidget {
  final AdoptionTrackingModel model;
  const _DynamicAdoptionCard({required this.model});

  @override
  State<_DynamicAdoptionCard> createState() => _DynamicAdoptionCardState();
}

class _DynamicAdoptionCardState extends State<_DynamicAdoptionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _takeAndSubmitPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    
    if (photo != null) {
      File originalFile = File(photo.path);
      File? compressedFile = await ImageCompressHelper.compressImage(originalFile);
      
      if (mounted) {
        context.read<AdoptionBloc>().add(
          SubmitWeeklyPhotoEvent(trackingId: widget.model.id, weekNumber: widget.model.currentWeek, imageFile: compressedFile ?? originalFile)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final int currentWeek = model.currentWeek;
    final bool isCompleted = model.trackingStatus == 'COMPLETED';
    final bool isCurrentSubmitted = model.isCurrentWeekSubmitted();
    
    final duration = model.timeUntilNextWeek;
    final String countdown = "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: isCompleted ? Colors.green : Colors.purple, width: 4)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: isCompleted ? Colors.green.shade50 : Colors.purple.shade50, borderRadius: BorderRadius.circular(4)),
                child: Row(children: [Icon(isCompleted ? Icons.verified : Icons.home, size: 12, color: isCompleted ? Colors.green.shade700 : Colors.purple.shade700), const SizedBox(width: 4), Text(isCompleted ? 'CHÍNH THỨC SỞ HỮU' : 'ĐANG THEO DÕI', style: TextStyle(color: isCompleted ? Colors.green.shade700 : Colors.purple.shade700, fontSize: 10, fontWeight: FontWeight.bold))]),
              ),
              Text(isCompleted ? 'Hoàn thành' : 'Tuần $currentWeek / 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.purple.shade600))
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(model.petImageUrl ?? 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop'), backgroundColor: Colors.grey.shade200),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(model.petName ?? 'Thú cưng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Ngày bắt đầu: ${model.createdAt.day}/${model.createdAt.month}/${model.createdAt.year}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressDot(isActive: currentWeek >= 1, isCompleted: model.week1Image != null, label: '1', isPulsing: currentWeek == 1 && !isCurrentSubmitted), _buildProgressLine(isActive: currentWeek >= 2),
              _buildProgressDot(isActive: currentWeek >= 2, isCompleted: model.week2Image != null, label: '2', isPulsing: currentWeek == 2 && !isCurrentSubmitted), _buildProgressLine(isActive: currentWeek >= 3),
              _buildProgressDot(isActive: currentWeek >= 3, isCompleted: model.week3Image != null, label: '3', isPulsing: currentWeek == 3 && !isCurrentSubmitted), _buildProgressLine(isActive: currentWeek >= 4),
              _buildProgressDot(isActive: currentWeek >= 4, isCompleted: model.week4Image != null, label: '4', isPulsing: currentWeek == 4 && !isCurrentSubmitted),
            ],
          ),
          const SizedBox(height: 16),
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: isCurrentSubmitted
                ? OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.timer), label: Text(duration.isNegative ? 'Đang tải tuần mới...' : 'Mở khóa Tuần ${currentWeek + 1} sau: $countdown'), style: OutlinedButton.styleFrom(disabledForegroundColor: Colors.grey.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))
                : ElevatedButton.icon(onPressed: _takeAndSubmitPhoto, icon: const Icon(Icons.camera_alt), label: Text('Chụp ảnh xác nhận Tuần $currentWeek'), style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade500, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
            )
        ],
      ),
    );
  }

  Widget _buildProgressDot({required bool isActive, required bool isCompleted, required String label, bool isPulsing = false}) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(color: isCompleted ? Colors.green : (isActive ? Colors.purple.shade500 : Colors.grey.shade300), shape: BoxShape.circle, border: isPulsing ? Border.all(color: Colors.purple.shade100, width: 4) : null),
      child: Center(child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Expanded(child: Container(height: 2, color: isActive ? Colors.purple.shade500 : Colors.grey.shade300));
  }
}