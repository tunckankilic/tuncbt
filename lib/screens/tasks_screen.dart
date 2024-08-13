import 'package:flutter/material.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';
import 'package:tuncbt/widgets/task_widget.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        // leading: Builder(
        //   builder: (ctx) {
        //     return IconButton(
        //       icon: Icon(
        //         Icons.menu,
        //         color: Colors.black,
        //       ),
        //       onPressed: () {
        //         Scaffold.of(ctx).openDrawer();
        //       },
        //     );
        //   },
        // ),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.pink),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showTaskCategoriesDialog(size: size);
              },
              icon: Icon(Icons.filter_list_outlined, color: Colors.black))
        ],
      ),
      body: ListView.builder(itemBuilder: (BuildContext context, int index) {
        return TaskWidget();
      }),
    );
  }

  _showTaskCategoriesDialog({required Size size}) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(
              'Task Category',
              style: TextStyle(fontSize: 20, color: Colors.pink.shade800),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.taskCategoryList.length,
                  itemBuilder: (ctxx, index) {
                    return InkWell(
                      onTap: () {
                        print(
                            'taskCategoryList[index], ${Constants.taskCategoryList[index]}');
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: Colors.red.shade200,
                          ),
                          // SizedBox(width: 10,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Constants.taskCategoryList[index],
                              style: TextStyle(
                                  color: Constants.darkBlue,
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('Cancel filter'),
              ),
            ],
          );
        });
  }
}
