import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import 'test_data.dart';

MockCloudFirestore getMockCloudFirestore() {
  return MockCloudFirestore(getTestData());
}

void main() {
  MockCloudFirestore mcf = getMockCloudFirestore();

  test('stream listening should work without errors or exceptions logged', () async {
    bool dataWasReceived = false;
    final StreamController<List<String>> broadcastController =
        StreamController<List<String>>.broadcast();

    broadcastController.stream.listen((List<String> onData) {
      log(onData.toString());
      dataWasReceived = true;
    });

    CollectionReference projRef =
        mcf.collection("projects").document("1").collection("tasks");

    Observable<QuerySnapshot> myStream = Observable(projRef.snapshots());
    Observable<List<String>> _tmpStream =
        myStream.switchMap((QuerySnapshot snapshot) {
      List<String> ids;
      for (DocumentSnapshot currentDocSnapshot in snapshot.documents) {
        ids.add(currentDocSnapshot.documentID);
      }

      return Stream.value(ids);
    });

    _tmpStream.listen((data) {
      broadcastController.add(data);
    }); // Exception would potentially be thrown here.

    //while (!dataWasReceived) {}
    sleep(Duration(seconds: 10));
    expect(dataWasReceived, true);
  });
}
