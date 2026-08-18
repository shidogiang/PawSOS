import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:paw_sos/features/message/presentation/bloc/message_bloc.dart';
import 'package:paw_sos/features/message/presentation/bloc/message_event.dart';
import 'package:paw_sos/features/message/presentation/bloc/message_state.dart';
class ChatScreen extends StatefulWidget {
  final String reporterName;
  final String reportId;

  const ChatScreen({super.key, required this.reporterName, required this.reportId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final String? _myUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    // mở luồng Stream khi vào mess
    context.read<ChatBloc>().add(StartListeningChat(widget.reportId));
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    
    context.read<ChatBloc>().add(
      SendMessageEvent(reportId: widget.reportId, message: _msgCtrl.text.trim())
    );
    
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1, shadowColor: Colors.black12,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(backgroundColor: Colors.blue.shade100, child: const Icon(Icons.person, color: Colors.blue)),
                Positioned(bottom: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.reporterName, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Đang hoạt động', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatLoaded) {
                  final messages = state.messages;
                  
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('Hãy gửi tin nhắn đầu tiên!', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }

                  //  reverse = true  mới nhất  ở dưới cùng
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _myUserId;

                      return _buildMessageBubble(msg.message, isMe);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          
          // Khung nhập tin nhắn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -5), blurRadius: 10)]),
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.add, color: Colors.blue), onPressed: () {}),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true, fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: _sendMessage),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Khối bong bóng chat
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade600 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: isMe ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
        ),
      ),
    );
  }
}