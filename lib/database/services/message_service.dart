import 'package:sollylabs_discover/database/models/message.dart';
import 'package:sollylabs_discover/global/globals.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  Future<List<Message>> getMessages(String connectionId) async {
    final response = await globals.supabaseClient.from('messages').select().eq('connection_id', connectionId).order('created_at', ascending: true);

    List<Message> messages = [];
    for (final message in response) {
      messages.add(Message.fromJson(message));
    }
    return messages;
  }

  Future<Message> sendMessage(String connectionId, String senderId, String messageText) async {
    final message = Message(
      id: UuidValue.fromString(const Uuid().v4()),
      connectionId: UuidValue.fromString(connectionId),
      senderId: UuidValue.fromString(senderId),
      message: messageText,
      createdAt: DateTime.now(),
    );

    final response = await globals.supabaseClient.from('messages').insert(message.toJson()).select();

    return Message.fromJson(response[0]);
  }

// Add other methods for managing messages as needed, like deleting or updating messages
}
