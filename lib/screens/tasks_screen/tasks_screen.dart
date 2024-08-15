import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';
import 'package:tuncbt/widgets/task_widget.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          iconTheme: const IconThemeData(
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
          title: const Text(
            'Tasks',
            style: TextStyle(color: Colors.pink),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _showTaskCategoriesDialog(size: size);
                },
                icon:
                    const Icon(Icons.filter_list_outlined, color: Colors.black))
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return TaskWidget(
                        taskTitle: snapshot.data!.docs[index]['taskTitle'],
                        taskDescription: snapshot.data!.docs[index]
                            ['taskDescription'],
                        taskId: snapshot.data!.docs[index]['taskId'],
                        uploadedBy: snapshot.data!.docs[index]['uploadedBy'],
                        isDone: snapshot.data!.docs[index]['isDone'],
                      );
                    });
              } else {
                return const Center(
                  child: Text('There is no tasks'),
                );
              }
            }
            return const Center(
                child: Text(
              'Something went wrong',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ));
          },
        ));
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
            content: SizedBox(
              width: size.width * 0.9,
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Constants.taskCategoryList.length,
                  itemBuilder: (ctxx, index) {
                    return InkWell(
                      onTap: () {
                        log('taskCategoryList[index], ${Constants.taskCategoryList[index]}');
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
                  Navigator.canPop(ctx) ? Navigator.pop(ctx) : null;
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Cancel filter'),
              ),
            ],
          );
        });
  }
}
