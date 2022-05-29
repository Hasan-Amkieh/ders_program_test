import 'package:get_storage/get_storage.dart';

// This class will classify the data and store it permanently inside the appropriate files
class Classifier {

  Classifier() {

    ;

  }

}

// TODO: Make this class easier to use for our app purpose!
class FileStorage {

  late final GetStorage file;
  final String fileName;

  FileStorage({required this.fileName}) {

    file = GetStorage(fileName);

  }

}