
import 'package:Atsched/scrapers/bilkent_scraper_computer.dart';
import 'package:Atsched/scrapers/scraper.dart';

class BilkentScraperPhone extends Scraper {

  @override
  getTimetableData() {

    BilkentScraperComputer.instance.getTimetableData();

  }

  BilkentScraperPhone._privateConstructor();

  static late final Scraper instance = BilkentScraperPhone._privateConstructor();

}
