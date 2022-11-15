
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview/src/in_app_webview/in_app_webview_controller.dart';

abstract class Scraper {
  // The scarper class is Singleton, only one object exists of that class

  dynamic getTimetableData(InAppWebViewController? controller, AjaxRequest? request);

}
