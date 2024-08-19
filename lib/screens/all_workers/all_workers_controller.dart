import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllWorkersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final workers = <DocumentSnapshot>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkers();
  }

  void fetchWorkers() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      workers.value = snapshot.docs;
      isLoading.value = false;
    }, onError: (error) {
      log("Error fetching workers: $error");
      isLoading.value = false;
    });
  }
}
