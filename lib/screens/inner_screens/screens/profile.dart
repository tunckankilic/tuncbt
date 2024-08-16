import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/user_state.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({super.key, required this.userID});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _titleTextStyle = const TextStyle(
      fontSize: 22, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold);
  var contentTextStyle = TextStyle(
      color: Constants.darkBlue,
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  bool _isLoading = false;
  String phoneNumber = "";
  String email = "";
  String? name;
  String job = '';
  String imageUrl = "";
  String joinedAt = " ";
  bool _isSameUser = false;
  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();
      setState(() {
        email = userDoc.get('email');
        name = userDoc.get('name');
        job = userDoc.get('positionInCompany');
        phoneNumber = userDoc.get('phoneNumber');
        imageUrl = userDoc.get('userImage');
        Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
        var joinedDate = joinedAtTimeStamp.toDate();
        joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
      });
      User? user = _auth.currentUser;
      final uid = user!.uid;
      setState(() {
        _isSameUser = uid == widget.userID;
      });
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Stack(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Text(name == null ? 'Name here' : name!,
                                    style: _titleTextStyle)),
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '$job Since joined $joinedAt',
                                style: contentTextStyle,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Contact Info',
                              style: _titleTextStyle,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: userInfo(title: 'Email:', content: email),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: userInfo(
                                  title: 'Phone number:', content: phoneNumber),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            _isSameUser
                                ? Container()
                                : const Divider(
                                    thickness: 1,
                                  ),
                            const SizedBox(
                              height: 20,
                            ),
                            _isSameUser
                                ? Container()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _contactBy(
                                        color: Colors.green,
                                        fct: () {
                                          _openWhatsAppChat();
                                        },
                                        icon: FontAwesomeIcons.whatsapp,
                                      ),
                                      _contactBy(
                                          color: Colors.red,
                                          fct: () {
                                            _mailTo();
                                          },
                                          icon: Icons.mail_outline),
                                      _contactBy(
                                          color: Colors.purple,
                                          fct: () {
                                            _callPhoneNumber();
                                          },
                                          icon: Icons.call_outlined),
                                    ],
                                  ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            !_isSameUser
                                ? Container()
                                : Center(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 30),
                                      child: MaterialButton(
                                        onPressed: () {
                                          _auth.signOut();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const UserState(),
                                            ),
                                          );
                                        },
                                        color: Colors.pink.shade700,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13)),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: size.width * 0.26,
                          height: size.width * 0.26,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 8,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.fill)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Erorr');
      throw 'Error occured';
    }
  }

  void _mailTo() async {
    var mailUrl = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(mailUrl))) {
      await launchUrl(Uri.parse(mailUrl));
    } else {
      log('Erorr');
      throw 'Error occured';
    }
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Erorr');
      throw 'Error occured';
    }
  }

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
          radius: 23,
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(
              icon,
              color: color,
            ),
            onPressed: () {
              fct();
            },
          )),
    );
  }

  Widget userInfo({required String title, required String content}) {
    return Row(
      children: [
        Text(
          title,
          style: _titleTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: contentTextStyle,
          ),
        ),
      ],
    );
  }
}
