import 'package:flutter/material.dart';
import 'package:paw_sos/features/report/data/models/AnimalReportModel.dart'; 
class SOSItemCard extends StatelessWidget {
  final AnimalReportModel report; // Thay thế 4 biến String bằng 1 biến Model duy nhất
  final VoidCallback? onTap;

  const SOSItemCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Giúp Column không chiếm khoảng trống thừa
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(report.imageUrl), // Lấy ảnh từ Model
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Giúp chống tràn Bottom 6.0 pixels
                children: [
                  Text(
                    report.distance, // Lấy khoảng cách từ Model
                    style: const TextStyle(
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.orange
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.title, // Lấy tiêu đề từ Model
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.timeAgo, // Lấy thời gian từ Model
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}