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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.volunteer_activism, iconColor: Colors.green.shade600, bgColor: Colors.green.shade50,
                        label: 'Đã cứu', value: '12', unit: 'bé',
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.campaign, iconColor: Colors.blue.shade600, bgColor: Colors.blue.shade50,
                        label: 'Báo cáo', value: '5', unit: 'ca',
                      ),
                    ],
                  ),
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
          // 2. TÍCH HỢP BLOC: QUY TRÌNH TRACKING 4 TUẦN (Dynamic UI)
          BlocConsumer<AdoptionBloc, AdoptionState>(
            listener: (context, state) {
              if (state is AdoptionPhotoSubmitted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.green)
                );
              } else if (state is AdoptionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red)
                );
              }
            },
            builder: (context, state) {
              if (state is AdoptionLoading) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.purple)),
                );
              } else if (state is AdoptionLoaded) {
                if (state.trackings.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text("Chưa có nhiệm vụ nào.", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Hãy nhận nuôi hoặc đi cứu hộ để tích điểm nhé!", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      )
                    ),
                  );
                }
                
                // Trả ra danh sách các bé đang được người này nhận nuôi
                return Column(
                  children: state.trackings.map((tracking) => _DynamicAdoptionCard(model: tracking)).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.speaker_notes_off, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text("Chưa có báo cáo nào.", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Khi bạn báo cáo SOS, trạng thái sẽ cập nhật tại đây.", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _buildTimelineItem({required bool isActive, required String title, required String time}) {
    return Transform.translate(
      offset: const Offset(-13, 0), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10, height: 10, margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: isActive ? Colors.blue.shade500 : Colors.grey.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey.shade600)),
                Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

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
    // Khởi tạo Timer để cập nhật UI đếm ngược thời gian mỗi giây (Phục vụ Demo 2 phút cực gắt)
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
      // Nén ảnh siêu nhẹ trước khi gửi
      File? compressedFile = await ImageCompressHelper.compressImage(originalFile);
      
      if (mounted) {
        context.read<AdoptionBloc>().add(
          SubmitWeeklyPhotoEvent(
            trackingId: widget.model.id, 
            weekNumber: widget.model.currentWeek, 
            imageFile: compressedFile ?? originalFile
          )
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
    
    // Format đếm ngược thời gian
    final duration = model.timeUntilNextWeek;
    final String countdown = "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border(left: BorderSide(color: isCompleted ? Colors.green : Colors.purple, width: 4)), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          // Tiêu đề trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.shade50 : Colors.purple.shade50, 
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Row(
                  children: [
                    Icon(isCompleted ? Icons.verified : Icons.home, size: 12, color: isCompleted ? Colors.green.shade700 : Colors.purple.shade700), 
                    const SizedBox(width: 4), 
                    Text(
                      isCompleted ? 'CHÍNH THỨC SỞ HỮU' : 'ĐANG THEO DÕI', 
                      style: TextStyle(color: isCompleted ? Colors.green.shade700 : Colors.purple.shade700, fontSize: 10, fontWeight: FontWeight.bold)
                    )
                  ]
                ),
              ),
              Text(isCompleted ? 'Hoàn thành' : 'Tuần $currentWeek / 4', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCompleted ? Colors.green : Colors.purple.shade600))
            ],
          ),
          const SizedBox(height: 12),
          
          // Thông tin Pet
          Row(
            children: [
              CircleAvatar(
                radius: 24, 
                backgroundImage: NetworkImage(model.petImageUrl ?? 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=200&auto=format&fit=crop'), 
                backgroundColor: Colors.grey.shade200
              ),
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
              _buildProgressDot(isActive: currentWeek >= 1, isCompleted: model.week1Image != null, label: '1', isPulsing: currentWeek == 1 && !isCurrentSubmitted),
              _buildProgressLine(isActive: currentWeek >= 2),
              _buildProgressDot(isActive: currentWeek >= 2, isCompleted: model.week2Image != null, label: '2', isPulsing: currentWeek == 2 && !isCurrentSubmitted),
              _buildProgressLine(isActive: currentWeek >= 3),
              _buildProgressDot(isActive: currentWeek >= 3, isCompleted: model.week3Image != null, label: '3', isPulsing: currentWeek == 3 && !isCurrentSubmitted),
              _buildProgressLine(isActive: currentWeek >= 4),
              _buildProgressDot(isActive: currentWeek >= 4, isCompleted: model.week4Image != null, label: '4', isPulsing: currentWeek == 4 && !isCurrentSubmitted),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              child: isCurrentSubmitted
                ? OutlinedButton.icon(
                    onPressed: null, // Khóa nút vì tuần này nộp ảnh rồi
                    icon: const Icon(Icons.timer), 
                    label: Text(duration.isNegative ? 'Đang tải tuần mới...' : 'Mở khóa Tuần ${currentWeek + 1} sau: $countdown'),
                    style: OutlinedButton.styleFrom(disabledForegroundColor: Colors.grey.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )
                : ElevatedButton.icon(
                    onPressed: _takeAndSubmitPhoto, 
                    icon: const Icon(Icons.camera_alt), 
                    label: Text('Chụp ảnh xác nhận Tuần $currentWeek'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade500, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
            )
        ],
      ),
    );
  }

  Widget _buildProgressDot({required bool isActive, required bool isCompleted, required String label, bool isPulsing = false}) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green : (isActive ? Colors.purple.shade500 : Colors.grey.shade300), 
        shape: BoxShape.circle,
        border: isPulsing ? Border.all(color: Colors.purple.shade100, width: 4) : null,
      ),
      child: Center(
        child: isCompleted 
          ? const Icon(Icons.check, size: 12, color: Colors.white) 
          : Text(label, style: TextStyle(fontSize: 10, color: isActive ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressLine({required bool isActive}) {
    return Expanded(child: Container(height: 2, color: isActive ? Colors.purple.shade500 : Colors.grey.shade300));
  }
}