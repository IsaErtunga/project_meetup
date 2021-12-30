import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:filter_list/filter_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseInterestsScreen extends StatefulWidget {
  const ChooseInterestsScreen({Key? key}) : super(key: key);

  @override
  State<ChooseInterestsScreen> createState() => _ChooseInterestScreen();
}

class _ChooseInterestScreen extends State<ChooseInterestsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  List<String> InterestsList = [
    "Music/Dance/Club",
    "Sports & Fitness",
    "Travel & Outdoors",
    "Science & Tech"
  ];
  List<String> selectedInterestsList = [];

  Future<void> addInterests() {
    return users
        .doc(auth.currentUser!.uid)
        .update({'myInterests': selectedInterestsList});
  }

  void _openFilterDialog() async {
    await FilterListDialog.display<String>(context,
        backgroundColor: Colors.black,
        listData: InterestsList,
        selectedListData: selectedInterestsList,
        height: 480,
        headlineText: "Select Interests",
        searchFieldHintText: "Search Here", choiceChipLabel: (item) {
      return item;
    }, validateSelectedItem: (list, val) {
      return list!.contains(val);
    }, onItemSearch: (list, text) {
      if (list!.any(
          (element) => element.toLowerCase().contains(text.toLowerCase()))) {
        return list
            .where(
                (element) => element.toLowerCase().contains(text.toLowerCase()))
            .toList();
      } else {
        return [];
      }
    }, onApplyButtonClick: (list) {
      if (list != null) {
        setState(
          () {
            selectedInterestsList = List.from(list);
            addInterests();
          },
        );
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("Choose your interests"),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: _openFilterDialog,
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ),
        body: selectedInterestsList == null || selectedInterestsList.length == 0
            ? Center(
                child: Text('No interests selected'),
              )
            : ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(selectedInterestsList[index]),
                  );
                },
                separatorBuilder: (context, index) => Divider(),
                itemCount: selectedInterestsList.length));
  }
}
