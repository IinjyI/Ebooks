import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebooks/Functions/DBandAuth/sharedPrefs.dart';
import 'package:flutter/material.dart';

import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomInfoItem.dart';
import '../CustomWidgets/CustomNotLoggedIn.dart';
import '../Functions/DBandAuth/database.dart';
import '../Functions/DBandAuth/firebaseAuth.dart';
import 'WelcomeScreen.dart';

/// User info,
/// sign out
///
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'ProfileScreen';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Profile(),
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return loggedInUser != "NotLoggedIn"
        ? Padding(
            padding: const EdgeInsets.all(11),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
              ),
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: getUserInformation(loggedInUser),
                builder: (c, snapshot) => snapshot.hasData
                    ? Column(
                        children: [
                          CustomInfoItem(
                            icon: Icons.person,
                            label: snapshot.data!.data()!['username'],
                          ),
                          CustomInfoItem(
                            icon: Icons.email,
                            label: snapshot.data!.data()!['email'],
                          ), CustomInfoItem(
                            icon: Icons.email,
                            label: snapshot.data!.data()!['phone'],
                          ),
                          CustomButton(
                              text: 'Sign Out',
                              function: () {
                                signOut();
                                Navigator.pushReplacementNamed(
                                    context, WelcomeScreen.id);
                              }),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator()),
              )
            ]),
          )
        : const CustomNotLoggedIn();
  }
}
