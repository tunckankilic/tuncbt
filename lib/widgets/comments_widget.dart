import 'package:flutter/material.dart';
import 'package:tuncbt/screens/inner_screens/screens/profile.dart';

class CommentWidget extends StatelessWidget {
  final String commentId;
  final String commenterId;
  final String commenterName;
  final String commentBody;
  final String commenterImageUrl;

  const CommentWidget({
    Key? key,
    required this.commentId,
    required this.commenterId,
    required this.commenterName,
    required this.commentBody,
    required this.commenterImageUrl,
  }) : super(key: key);

  static const List<Color> _colors = [
    Colors.amber,
    Colors.orange,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.blue,
    Colors.deepOrange,
  ];

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        _colors[DateTime.now().microsecond % _colors.length];

    return InkWell(
      onTap: () => _navigateToProfile(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommenterAvatar(borderColor),
          const SizedBox(width: 6),
          Expanded(child: _buildCommentContent()),
        ],
      ),
    );
  }

  Widget _buildCommenterAvatar(Color borderColor) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: borderColor),
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(commenterImageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCommentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          commenterName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          commentBody,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userID: commenterId),
      ),
    );
  }
}
