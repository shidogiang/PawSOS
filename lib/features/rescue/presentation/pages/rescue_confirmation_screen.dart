import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:paw_sos/utils/imageCompressHelper.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_bloc.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_event.dart';
import 'package:paw_sos/features/rescue/presentation/bloc/rescue_state.dart';
import 'package:paw_sos/features/rescue/domain/usecases/complete_mission_usecase.dart'; // THÊM IMPORT

class RescueConfirmationScreen extends StatefulWidget {
  final AnimalReportModel mission;

  const RescueConfirmationScreen({super.key, required this.mission});

  @override
  State<RescueConfirmationScreen> createState() => _RescueConfirmationScreenState();
}

class _RescueConfirmationScreenState extends State<RescueConfirmationScreen> with SingleTickerProviderStateMixin {
  File? _photoFile;
  final ImagePicker _picker = ImagePicker();

  String _selectedStatus = 'Thành công';
  final TextEditingController _noteCtrl = TextEditingController();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 100,
      );
      if (photo != null) {
        File originalFile = File(photo.path);
        // GỌI THUẬT TOÁN NÉN ẢNH
        File? compressedFile = await ImageCompressHelper.compressImage(originalFile);
        
        setState(() => _photoFile = compressedFile ?? originalFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi mở Camera')));
    }
  }

  void _submitConfirmation() {
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chụp ảnh minh chứng!'), backgroundColor: Colors.orange));
      return;
    }
    
    // GỬI EVENT BÊN BLOC
    context.read<RescueBloc>().add(
      CompleteMission(
        widget.mission.id,
        _photoFile,
        _selectedStatus,
        _noteCtrl.text,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RescueBloc, RescueState>(
      listener: (context, state) {
        if (state is RescueMissionCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tuyệt vời! Bạn được cộng +10 điểm tín nhiệm.'), backgroundColor: Colors.green)
          );
          // Đá về màn hình gốc (Mất thanh trạng thái đang cứu)
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Load lại Radar
          context.read<RescueBloc>().add(LoadRadarReports());
        } else if (state is RescueError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      builder: (context, state) {
        final _isSubmitting = state is RescueLoading;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
            title: const Text('Báo cáo kết quả', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMissionSummary(),
                      const SizedBox(height: 16),
                      _buildCameraSection(),
                      const SizedBox(height: 16),
                      _buildResultSelection(),
                      const SizedBox(height: 16),
                      _buildNoteSection(),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -5), blurRadius: 10)]),
                  child: SafeArea(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600, foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.verified),
                      label: Text(_isSubmitting ? 'Đang cập nhật...' : 'HOÀN TẤT NHIỆM VỤ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionSummary() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(widget.mission.imageUrl, width: 60, height: 60, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.mission.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Mã ca: #${widget.mission.id.substring(0, 8)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCameraSection() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ảnh minh chứng', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text('* Bắt buộc', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openCamera,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  image: _photoFile != null ? DecorationImage(image: FileImage(_photoFile!), fit: BoxFit.cover) : null,
                ),
                child: _photoFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) => Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.blue.withOpacity((1 - _pulseController.value) * 0.5), spreadRadius: _pulseController.value * 15)]),
                              child: Icon(Icons.camera_alt, color: Colors.blue.shade400, size: 30),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('Chạm để chụp ảnh hiện trường', style: TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      )
                    : Container(
                        alignment: Alignment.bottomRight, padding: const EdgeInsets.all(8),
                        child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => setState(() => _photoFile = null))),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSelection() {
    final statuses = [
      {'label': 'Thành công', 'icon': Icons.favorite, 'color': Colors.green},
      {'label': 'Bé đã bỏ chạy', 'icon': Icons.directions_run, 'color': Colors.orange},
      {'label': 'Đã tử vong', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.grey},
    ];

    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kết quả cứu hộ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(
            children: statuses.map((s) {
              final isSelected = _selectedStatus == s['label'];
              final color = s['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedStatus = s['label'] as String),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.white,
                      border: Border.all(color: isSelected ? color : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(s['icon'] as IconData, color: isSelected ? color : Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s['label'] as String, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color.withOpacity(0.8).withAlpha(255) : Colors.black87))), 
                        if (isSelected) Icon(Icons.check_circle, color: color),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ghi chú thêm (Tùy chọn)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl, maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập tình trạng chi tiết của bé (vết thương, phản ứng)...', hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green)),
            ),
          )
        ],
      ),
    );
  }
}