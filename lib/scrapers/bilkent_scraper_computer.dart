
import 'package:Atsched/scrapers/scraper.dart';

class BilkentScraperComputer extends Scraper {

  @override
  getTimetableData(controller, request) {
    // TODO: implement getTimetableData
    throw UnimplementedError();
  }

  BilkentScraperComputer._privateConstructor();

  static late final Scraper instance = BilkentScraperComputer._privateConstructor();

}
