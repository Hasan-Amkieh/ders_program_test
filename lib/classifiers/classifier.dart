
import 'dart:isolate';

abstract class Classifier {
  // A classifier object is Singleton, only one object exists of that class

  void classifyData(SendPort sport);

}
