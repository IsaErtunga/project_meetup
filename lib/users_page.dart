import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:project_meetup/chat_screen.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  // Create a user with an ID of UID if you don't use `FirebaseChatCore.instance.users()` stream
  void _handlePressed(types.User otherUser, BuildContext context) async {
    final room = await FirebaseChatCore.instance.createRoom(otherUser);
    print("Hej");
    // Navigate to the Chat screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      floatingActionButton: FloatingActionButton(onPressed: () async {
        await FirebaseChatCore.instance.createUserInFirestore(
          types.User(
            firstName: 'Isas',
            id: "BLr66879yWfcUT8FmHuDYKn003r1", // UID from Firebase Authentication
            imageUrl: 'https://i.pravatar.cc/300',
            lastName: 'Ertunga',
          ),
        );
      }),*/
      body: StreamBuilder<List<types.User>>(
        stream: FirebaseChatCore.instance.users(),
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const Text('Error');
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].firstName.toString()),
                    onTap: () {
                      _handlePressed(snapshot.data![index], context);
                    },
                  );
                },
              );
            } else {
              return const Text('Empty data');
            }
          } else {
            return Text('State: ${snapshot.connectionState}');
          }
        },
      ),
    );
  }
}
