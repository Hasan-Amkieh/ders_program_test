
import 'package:Atsched/scrapers/bilkent_scraper_computer.dart';
import 'package:Atsched/scrapers/scraper.dart';

class BilkentScraperPhone extends Scraper {

  @override
  getTimetableData(controller, request) {

    BilkentScraperComputer.instance.getTimetableData(null, null);

  }

  BilkentScraperPhone._privateConstructor();

  static late final Scraper instance = BilkentScraperPhone._privateConstructor();

}
