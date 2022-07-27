import 'dart:core';

import 'package:ders_program_test/main.dart';

List<String> langs = ["English", "Turkish"];

Map<String, String> engToTurk = {
  "Schedule" : "Takvim",
  "Settings" : "Ayarlar",
  "Links" : "Bağlantılar",
  "Tools" : "Aletler",
  "Turkish" : "Türkçe",
  "English" : "İngilizce",
  "Language" : "Dil",
  "Faculty" : "Fakülte",
  "Department" : "Bölüm",
  "Engineering" : "Mühendislik",
  "Civil Aviation" : "Sivil Havacılık",
  "Health Sciences" : "Sağlık Bilimleri",
  "Arts and Sciences" : "Sanatlar ve Bilimler",
  "Fine Arts" : "Güzel Sanatlar",
  "Law" : "Hukuk",
  "Business" : "İşletme",
  "Automotive Engineering" : "Otomotiv Mühendisliği",
  "Aerospace Engineering" : "Uzay ve Havacılık Mühendisliği",
  "Civil Engineering" : "İnşaat Mühendisliği",
  "Chemical Engineering" : "Kimya Mühendisliği",
  "Computer Engineering" : "Bilgisayar Mühendisliği",
  "Electrical Engineering" : "Elektrik Mühendisliği",
  "Energy Engineering" : "Enerji Mühendisliği",
  "Industrial Engineering" : "Endüstri Mühendisliği",
  "Information Systems Engineering" : "Bilgi Sistemleri Mühendisliği",
  "Material Engineering" : "Malzeme Mühendisliği",
  "Mechanical Engineering" : "Makine Mühendisliği",
  "Mechatronics Engineering" : "Mekatronik Mühendisliği",
  "Manufacturing Engineering" : "İmalat Mühendisliği",
  "Software Engineering" : "Yazılım Mühendisliği",
  "Avionics" : "Aviyonik",
  "Airframe & Powerplant Maintenance" : "Gövde & Motor Bakımı",
  "Aviation Management" : "Havacılık Yönetimi",
  "Pilot Training" : "Pilotaj Eğitimi",
  "Nursery" : "Hemşirelik",
  "Nutrition and Dietetics" : "Beslenme ve Diyetetik",
  "Physiotherapy and Rehabilitation" : "Fizyoterapi ve Rehabilitasyon",
  "English Language and Literature" : "İngiliz Dili ve Edebiyatı",
  "English Translation and Interpretation" : "İngilizce Mütercim Tercümanlık",
  "Mathematics" : "Matematik",
  "Psychology" : "Psikoloji",
  "Industrial Product Design" : "Endüstriyel Ürün Tasarımı",
  "Graphics Design" : "Grafik Tasarım",
  "Interior Architecture & Env. Design" : "İç Mimarlık & Çevre Tasarımı",
  "Architecture" : "Mimari",
  "Textile and Fashion Design" : "Tekstil ve Moda Tasarımı",
  "LAW" : "HUKUK",
  "Justice" : "Adalet",
  "Economics" : "Ekonomi",
  "Economics (English)" : "Ekonomi (İngilizce)",
  "Economics (Turkish)" : "Ekonomi (Türkçe)",
  "International Relations" : "Uluslararası İlişkiler",
  "Political Science & Business Admin." : "Siyaset Bilimi & Kamu Yönetimi",
  "International Trade and Logistics" : "Uluslararası Ticaret ve Lojistik",
  "Business Administration (English)" : "İş İdaresi (İngilizce)",
  "Business Administration (Turkish)" : "İş İdaresi (Türkçe)",
  "Public Finance" : "Kamu Maliyesi",
  "Public Relations and Advertising" : "Halkla İlişkiler ve Reklamcılık",
  "Tourism Management" : "Turizm Yönetimi",
  "About" : "Hakkında",
  "Name: " : "İsim: ",
  "Classrooms: " : "Sınıflar: ",
  "Teachers: " : "Öğretmenler: ",
  "Departments: " : "Bölümler: ",
  "EDIT" : "DÜZENLE",
  "Mon" : "Pzt",
  "Tue" : "Sal",
  "Wed" : "Çar",
  "Thur" : "Per",
  "Fri" : "Cum",
  "Sat" : "Cmt",
  "Edit Courses" : "Kursları düzenle",
  "Scheduler" : "Zamanlayıcı",
  "Choose Made-up Plans" : "Hazır Planları Seçin",
  "Search for Courses" : "Kurs Ara",
  "Saved Schedules" : "Kayıtlı Programlar",
  "Add and edit the courses on the current schedule" : "Mevcut takvimdaki kursları ekleyin ve düzenleyin",
  "Choose the courses with the sections with specific options, then choose your appropriate schedule" : "Belirli seçeneklere sahip bölümleri olan kursları seçin, ardından uygun programınızı seçin",
  "These plans are provided by the university" : "Bu planlar üniversite tarafından sağlanmaktadır.",
  "Search for courses using its name, classroom number, teacher or department" : "Adını, sınıf numarasını, öğretmenini veya bölümünü kullanarak kursları arayın",
  "You can save schedules and set them back again" : "Programları kaydedebilir ve tekrar ayarlayabilirsiniz",
  "School's Schedules" : "Okulun Programları",
  "Update Timeout (hours)" : "Güncelleme Zaman Aşımı (saat)",
  "Theme" : "Tema",
  "Donate me" : "Bana bağış yap",
  "Light  " : "Hafif  ",
  "Dark  " : "Karanlık  ",
  "Fall" : "Güz",
  "Spring" : "Bahar",
  "Summer" : "Yaz",
  "Update now" : "Şimdi Güncelle",
  "Last Updated" : "Son Güncelleme",
  "Only search courses for this department" : "Sadece bu bölüm için kurs ara",
  "OK" : "TAMAM",
  "ADD TO FAVOURITES" : "FAVORİLERE EKLE",
  "Added to favourite courses" : "Favori kurslara eklendi",
  "Course code, teacher name or classroom" : "Ders kodu, öğretmen adı veya sınıf",
  "Favourite Courses" : "Favori Kurslar",
  "The course is already a favourite" : "Kurs zaten favori",
  "You have no favourite courses, please add them from Search for Courses page" : "Favori dersiniz yok, lütfen Kurs Ara sayfasından ekleyin",
  "REMOVE" : "KALDIR",
  "course name" : "kurs adı",
  "teacher" : "Öğretmen",
  "classroom" : "Sınıf",
  "ADD TO SCHEDULE" : "TAKVİME EKLE",
  "Added to the current schedule" : "Mevcut takvime eklendi",
  "The course is already in the schedule" : "Kurs zaten takvimde",
  "NOT NOW" : "ŞİMDİ DEĞİL",
  "RESTART" : "TEKRAR BAŞLAT",
  "Restarting the application" : "Programı yeniden başlatma",
  "was removed" : "kardırıldı",
  "Mo" : "Pz",
  "Tu" : "Sa",
  "We" : "Ça",
  "Th" : "Pe",
  "Fr" : "Cu",
  "Sa" : "Cm",
  "custom course" : "özel kurs ",
};

String translateEng(String eng) {

  if (Main.language == "English") return eng;

  if (engToTurk.containsKey(eng)) {
    return engToTurk[eng] ?? eng;
  }
  return eng;

}

String dayToString(int day) {

  switch(day) {
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
  }

  return "";

}

String dayToStringShort(int day) {

  switch(day) {
    case 1:
      return "Mon";
    case 2:
      return "Tue";
    case 3:
      return "Wed";
    case 4:
      return "Thur";
    case 5:
      return "Fri";
    case 6:
      return "Sat";
  }

  return "";

}

String bgnPeriodToString(int bgnPeriod) {

  switch(bgnPeriod) {
    case 1:
      return "9:30";
    case 2:
      return "10:30";
    case 3:
      return "11:30";
    case 4:
      return "12:30";
    case 5:
      return "13:30";
    case 6:
      return "14:30";
    case 7:
      return "15:30";
    case 8:
      return "16:30";
    case 9:
      return "17:30";
    case 10:
      return "18:30";
  }

  return "";

}

String bgnPeriodToStringHoursOnly(int bgnPeriod) {

  switch(bgnPeriod) {
    case 1:
      return "9";
    case 2:
      return "10";
    case 3:
      return "11";
    case 4:
      return "12";
    case 5:
      return "13";
    case 6:
      return "14";
    case 7:
      return "15";
    case 8:
      return "16";
    case 9:
      return "17";
    case 10:
      return "18";
  }

  return "";

}

String convertTurkishToEnglish(String toConvert) {

  toConvert = toConvert.replaceAll(RegExp(r'ü'), 'u');
  toConvert = toConvert.replaceAll(RegExp(r'ö'), 'o');
  toConvert = toConvert.replaceAll(RegExp(r'ı'), 'i');
  toConvert = toConvert.replaceAll(RegExp(r'ş'), 's');
  toConvert = toConvert.replaceAll(RegExp(r'ç'), 'c');
  toConvert = toConvert.replaceAll(RegExp(r'ğ'), 'g');

  return toConvert;

}

List<String> deleteRepitions(List<String> list) {


  for (int i = 0 ; i < list.length ; i++) {
    if (i >= list.length) {
      break;
    }
    for (int j = i + 1 ; j < list.length ; j++) {
      if (j >= list.length) {
        break;
      }
      if (list[j].trim() == list[i].trim()) {
        list.removeAt(j);
        j--; // decrease j bcs we just removed an element from the list
      }
    }

  }

  return list;

}

