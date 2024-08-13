import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  List<Color> _colors = [
    Colors.amber,
    Colors.orange,
    Colors.pink.shade200,
    Colors.brown,
    Colors.cyan,
    Colors.blue,
    Colors.deepOrange,
  ];
  @override
  Widget build(BuildContext context) {
    _colors.shuffle();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: _colors[1],
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: NetworkImage(
                      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'),
                  fit: BoxFit.fill),
            ),
          ),
        ),
        SizedBox(
          width: 6,
        ),
        Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commenter name',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Text(
                  'Comment body',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                  ),
                )
              ],
            ))
      ],
    );
  }
}
