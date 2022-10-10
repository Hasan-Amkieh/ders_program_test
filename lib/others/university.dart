
import '../main.dart';

class University {

  // Add only functions, no attributes are allowed unless they constants

  static int getBgnMinutes() {

    switch (Main.uni) {
      case "Atilim":
        return 30;
      case "Bilkent":
        return 30;
      default:
        return 30;
    }

  }

}
