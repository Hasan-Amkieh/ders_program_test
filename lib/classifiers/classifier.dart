
import 'dart:isolate';

abstract class Classifier {
  // The classifier class is Singleton, only one object exists of that class

  void classifyData(SendPort sport);

}
