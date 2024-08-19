import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/inner_screens/screens/profile.dart';

class AllWorkersWidget extends StatelessWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String positionInCompany;
  final String phoneNumber;
  final String userImageUrl;

  const AllWorkersWidget({
    Key? key,
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.positionInCompany,
    required this.phoneNumber,
    required this.userImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () => _navigateToProfile(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: _buildLeadingAvatar(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailingButton(),
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(width: 1)),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        backgroundImage: NetworkImage(userImageUrl),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      userName,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Constants.darkBlue,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(Icons.linear_scale_outlined, color: Colors.pink.shade800),
        Text(
          '$positionInCompany/$phoneNumber',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTrailingButton() {
    return IconButton(
      icon: Icon(Icons.mail_outline, size: 30, color: Colors.pink.shade800),
      onPressed: _mailTo,
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userID: userID),
      ),
    );
  }

  void _mailTo() async {
    final mailUrl = 'mailto:$userEmail';
    if (await canLaunchUrl(Uri.parse(mailUrl))) {
      await launchUrl(Uri.parse(mailUrl));
    } else {
      log('Error: Unable to launch email client');
    }
  }
}