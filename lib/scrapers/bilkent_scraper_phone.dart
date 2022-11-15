
import 'package:Atsched/scrapers/scraper.dart';

class BilkentScraperPhone extends Scraper {

  @override
  getTimetableData(controller, request) {
    // TODO: implement getTimetableData
    throw UnimplementedError();
  }

  BilkentScraperPhone._privateConstructor();

  static late final Scraper instance = BilkentScraperPhone._privateConstructor();

}
