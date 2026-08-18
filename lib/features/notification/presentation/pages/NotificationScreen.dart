
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/noti_bloc.dart';
import '../bloc/noti_state.dart';
import '../bloc/noti_event.dart';
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thông báo', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF43F5E)));
          } 
          
          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Chưa có thông báo nào', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12, indent: 70),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  tileColor: notif.isRead ? Colors.transparent : Colors.red.shade50.withOpacity(0.5),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notif.type == 'RESCUE' ? Colors.red.shade100 : Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notif.type == 'RESCUE' ? Icons.local_hospital : Icons.info, 
                      color: notif.type == 'RESCUE' ? Colors.red.shade600 : Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 14))),
                      if (!notif.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.body, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text(notif.timeAgo, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                    ],
                  ),
                  onTap: () {
                    if (!notif.isRead) {
                      context.read<NotificationBloc>().add(MarkAsReadEvent(notif.id));
                    }
                  },
                );
              },
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}