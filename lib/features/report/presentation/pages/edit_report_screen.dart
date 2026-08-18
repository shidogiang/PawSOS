import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:paw_sos/core/utils/imageCompressHelper.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_bloc.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_event.dart';
import 'package:paw_sos/features/report/presentation/bloc/report_state.dart';

class EditReportScreen extends StatefulWidget {
  final AnimalReportModel report;

  const EditReportScreen({super.key, required this.report});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  File? _newPhotoFile;
  final ImagePicker _picker = ImagePicker();
  
  late String _selectedAnimalType;
  late List<String> _selectedConditions;
  late TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill dữ liệu từ ca báo cáo cũ
    context.read<ReportBloc>().add(ResetReportEvent());
    _selectedAnimalType = widget.report.animalType;
    _selectedConditions = List.from(widget.report.conditions);
    _noteCtrl = TextEditingController(text: widget.report.description);
  }

  @override
  void dispose() {
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
        File? compressedFile = await ImageCompressHelper.compressImage(originalFile);
        setState(() => _newPhotoFile = compressedFile ?? originalFile);
      }
    } catch (e) {
      _showError("Không thể mở Camera: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_selectedConditions.contains(condition)) {
        _selectedConditions.remove(condition);
      } else {
        _selectedConditions.add(condition);
      }
    });
  }

  void _submitUpdate() {
    FocusScope.of(context).unfocus();
    context.read<ReportBloc>().add(UpdateEmergencyReport(
      reportId: widget.report.id,
      newImageFile: _newPhotoFile,
      animalType: _selectedAnimalType,
      conditions: _selectedConditions,
      note: _noteCtrl.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật báo cáo thành công!"), backgroundColor: Colors.green));
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context, true); // Pop về và báo refresh list
          });
        } else if (state is ReportFailure) {
          _showError(state.message);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ReportLoading;
        final isSuccess = state is ReportSuccess;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.white, elevation: 0,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
            title: const Text('Chỉnh sửa báo cáo', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      _buildCameraSection(),
                      Divider(color: Colors.grey.shade300, thickness: 4, height: 32),
                      _buildTypeSelection(),
                      _buildConditionSelection(),
                      _buildNoteSection(),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -5), blurRadius: 10)]),
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting ? null : _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600, foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('LƯU THAY ĐỔI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              if (isSubmitting || isSuccess)
                Container(
                  color: Colors.white.withOpacity(0.9),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isSuccess) ...[
                          const CircularProgressIndicator(color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text('Đang cập nhật dữ liệu...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ] else ...[
                          const Icon(Icons.check_circle, color: Colors.green, size: 60),
                          const SizedBox(height: 16),
                          const Text('Cập nhật thành công!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ]
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ảnh hiện trường', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openCamera,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, width: 2),
                  image: _newPhotoFile != null 
                    ? DecorationImage(image: FileImage(_newPhotoFile!), fit: BoxFit.cover)
                    : DecorationImage(image: NetworkImage(widget.report.imageUrl), fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 12, right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text('Đổi ảnh', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phân loại', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTypeItem('Chó', Icons.pets), const SizedBox(width: 12),
              _buildTypeItem('Mèo', Icons.pets), const SizedBox(width: 12),
              _buildTypeItem('Khác', Icons.help_outline),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTypeItem(String type, IconData icon) {
    bool isSelected = _selectedAnimalType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedAnimalType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade50 : Colors.white,
            border: Border.all(color: isSelected ? Colors.orange : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.orange : Colors.grey),
              const SizedBox(height: 4),
              Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.orange : Colors.grey.shade700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionSelection() {
    final conditions = ['🩸 Bị thương', '⛓️ Mắc kẹt', '🥺 Suy kiệt / Đói', '🌧️ Dầm mưa/Lạnh', '❓ Không rõ'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tình trạng hiện tại (Chọn nhiều)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: conditions.map((cond) {
              bool isSelected = _selectedConditions.contains(cond);
              return GestureDetector(
                onTap: () => _toggleCondition(cond),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.grey.shade800 : Colors.white,
                    border: Border.all(color: isSelected ? Colors.grey.shade800 : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cond, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.grey.shade700)),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả thêm (Tùy chọn)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl, maxLines: 3,
            decoration: InputDecoration(
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange)),
            ),
          )
        ],
      ),
    );
  }
}