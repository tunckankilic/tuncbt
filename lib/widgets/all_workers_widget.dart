import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/inner_screens/screens/profile.dart';

class AllWorkersWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String positionInCompany;
  final String phoneNumber;
  final String userImageUrl;

  const AllWorkersWidget(
      {super.key,
      required this.userID,
      required this.userName,
      required this.userEmail,
      required this.positionInCompany,
      required this.phoneNumber,
      required this.userImageUrl});
  @override
  _AllWorkersWidgetState createState() => _AllWorkersWidgetState();
}

class _AllWorkersWidgetState extends State<AllWorkersWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  userID: widget.userID,
                ),
              ),
            );
          },
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.only(right: 12),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(width: 1),
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 20,
              child: Image.network(widget.userImageUrl),
            ),
          ),
          title: Text(
            widget.userName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Constants.darkBlue,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.linear_scale_outlined,
                color: Colors.pink.shade800,
              ),
              Text(
                '${widget.positionInCompany}/${widget.phoneNumber}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.mail_outline,
              size: 30,
              color: Colors.pink.shade800,
            ),
            onPressed: _mailTo,
          )),
    );
  }

  void _mailTo() async {
    var mailUrl = 'mailto:${widget.userEmail}';
    print('widget.userEmail ${widget.userEmail}');
    if (await canLaunchUrl(Uri.parse(mailUrl))) {
      await launchUrl(Uri.parse(mailUrl));
    } else {
      print('Erorr');
      throw 'Error occured';
    }
  }
}
