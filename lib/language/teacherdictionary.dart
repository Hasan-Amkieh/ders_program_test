import 'dart:core';

import '../main.dart';
import '../others/subject.dart';

// NOTE: No list for Arts and sciences because they have full names of teachers
// NOTE: Law fac. does not even offer any teacher names
// NOTE: Health Sciences have full names

String translateTeacher({required String teacherCode, required Subject subject}) { // class code is only used inside the general dictionary

  List<String> depsToSearch = subject.teacherCodes.toString().replaceAll(RegExp("[\\[.*?\\]]"), "").split(",");
  String classCode = subject.getCourseCodeWithoutSectionNumber();
  bool doSearchByDeps = false;

  for (int i = 0 ; i < depsToSearch.length ; i++) {
    if (teacherDictByDeps.containsKey(depsToSearch[i])) {
      doSearchByDeps = true;
    } else {
      depsToSearch.removeAt(i);
      i--;
    }
  }

  if (doSearchByDeps && teacherDictByDeps[Main.department]!.containsKey(teacherCode)) { // first search by the department:

    for (String dep in depsToSearch) {
      if (teacherDictByDeps[dep]!.containsKey(teacherCode)) {
        return teacherDictByDeps[dep]![teacherCode] ?? teacherCode;
      }
    }

  } else {
    switch(Main.faculty) { // search by the faculty
      case "Engineering":
        return teacherDictEngFac[teacherCode] ?? teacherCode;
      case "Civil Aviation":
        return teacherDictCivAvFac[teacherCode] ?? teacherCode;
      case "Fine Arts":
        return teacherDictFineArtsFac[teacherCode] ?? teacherCode;
      case "Arts and Sciences":
      case "Business":
      case "Health Sciences":
      case "Law":
      default:
        if (classCode.isNotEmpty && teacherDictGeneral.containsKey(classCode)) {
          return teacherDictGeneral[classCode]![teacherCode] ?? teacherCode;
        } else {
          return teacherCode;
        }
    }
  }

  return teacherCode;
}

Map<String, String>	teacherDictEngFac = {
  "HO" : "Hüseyin OYMAK",
  "RJ" : "Rahim JAFARI",
  "RB" : "RAMIN BARZEGAR",
  "EB" : "EREN BİLLUR",
  "CU" : "Candaş URUNGA",
  //"AO" : "ARDA ÖZMEN", // Fine Arts // she already exists in other faculties
  "ES" : "RECEP ENGİN SANSA", // Fine Arts
  "OA" : "Onur AYMERGEN", // Fine Arts
  "POI" : "Pınar OLGAÇ",
  "MO" : "Meral ÖZTÜRK",
  "TAr" : "Tanıl ARAYANCAN",
  "GAK" : "GONCA ARAT KOL",
  "NA" : "NAZLI ANGIN AKINER",
  "ETa" : "EVREN TANDOĞAN",
  "ET" : "Emine TURGUT",
  "SAKu" : "SEÇİL KUTLU",
  "HAt" : "HEDİYE ATİK",
  "ACC" : "AHMET CAN ÇALIK",
  "SA" : "SAEİD KAZEMZADEH",
  "TA" : "Tolga AKIŞ",
  "MY" : "Meriç YILMAZ",
  "YD" : "Yakup DARAMA",
  "EA" : "Ebru AKIŞ",
  "HCM" : "HALİT CENAN MERTOL",
  "GT" : "Gökhan TUNÇ",
  "SAm" : "SAMAN AMİNBAKHSH",
  "EG" : "Mustafa Erşan GÖKSU", // Civil Engineering
  "MSN" : "MUSTAFA SERDAR NALÇAKAN",
  "NM" : "Nesrin EKİNCİ MACHIN",
  "SOY" : "Şeniz ÖZALP YAMAN",
  // TODO: Solve this name:
  "AKa" : "AKa", // Chemical Engineering / CEAC406
  "AC" : "Atilla CINAHER",
  "SErt" : "Salih ERTAN",
  "ST" : "Seha TİRKEŞ",
  "MK" : "Murat KAYA", // for chemistry engineeering department
  "GTi" : "GÜZİN TİRKEŞ",
  "ECY" : "Ekrem Çağlar YILMAZ",
  "TBa" : "TUNCAY BAYRAK",
  "NC" : "NERGİZ ÇAĞILTAY",
  "CT" : "Çiğdem TURHAN",
  "GGMD" : "GONCA GÖKÇE MENEKŞE DALVEREN",
  "CCE" : "Cansu Çiğdem EKİN",
  "DT" : "Damla TOPALLI",
  "BYi" : "BEYTULLAH YILDIZ",
  "HKi" : "HÜREVREN KILIÇ",
  "ZK" : "Ziya KARAKAYA",
  "GS" : "Gökhan ŞENGÜL",
  "IBU" : "İBRAHİM BARAN USLU",
  "KEE" : "KEMAL EFE ESELLER",
  "MEO" : "Mehmet Efe ÖZBEK",
  "ETas" : "ENDER TAŞCI",
  "BE" : "HULUSİ BÜLENT ERTAN",
  "IY" : "İLKER YAĞLIDERE",
  "YDa" : "Yaser DALVEREN",
  "RD" : "REŞAT ÖZGÜR DORUK",
  "CTu" : "Cihan TURHAN",
  "MM" : "Mehdi MEHRTASH",
  "AA" : "Aysel ATİMTAY",
  "AAl" : "Ayhan ALBOSTAN",
  "GG" : "Günseli GÜMÜŞEL",
  "GKB" : "GÜLTEKİN KAMİL BİRLİK",
  "AEK" : "AHMET EREN KURTER",
  "FYO" : "FATMA YERLİKAYA ÖZKURT",
  "CUG" : "ÇAĞLAR UTKU GÜLER",
  "ASa" : "AIDA SALIMNEZHADGHAREHZIAEDDINI",
  "UB" : "Uğur BAÇ",
  "EE" : "Turan Erman ERKAN",
  "BLS": "BAHRAM LOTFİ",
  "KDU" : "KAMİL DEMİRBERK ÜNLÜ",
  "YAk" : "Yılmaz AKKOYUN",
  "STo" : "Sacip TOKER",
  "ME" : "Meltem ERYILMAZ",
  "BBa" : "BABUR BATURAY",
  "OO" : "Ozan ÖZKAN",
  "EK" : "ENDER KESKİNKILIÇ",
  "JP" : "Jongee PARK",
  "HTS" : "HİLAL TÜRKOĞLU ŞAŞMAZEL",
  "DD" : "DORUK DOĞU",
  "FS" : "Fatih SULAK",
  "EYK" : "EMEL YILDIRIM KAVGACI",
  "ADO" : "ARZU DENK OĞUZ",
  "TE" : "Tanıl ERGENÇ",
  "MT" : "Mehmet TURAN",
  "FA" : "FATMA AYAZ",
  "FAO" : "FERİHE ATALAN",
  "BGT" : "Burcu GÜLMEZ TEMÜR",
  "SAkg" : "SİBEL DOĞRU AKGÖL",
  "IE" : "İnci ERHAN",
  "UA" : "Ümit AKSOY",
  "RA" : "Rezan SEVİNİK ADIGÜZEL",
  "SO" : "Sofiya OSTROVSKA",
  "AO" : "Altan ÖZKİL", // for MDES
  "HA" : "Ahmet Hakan ARGEŞO",
  "Eki" : "SADIK ENGİN KILIÇ",
  "FT" : "Fuat TİNİŞ",
  "HKa" : "Hakan KALKAN",
  "SB" : "Şakir BAYTAROĞLU",
  "BKe" : "BEHZAT BAHADIR KENTEL",
  "EKi" : "SADIK ENGİN KILIÇ",
  "MS" : "Cemal Merih ŞENGÖNÜL",
  "HUA" : "Hasan Umur AKAY",
  "UK" : "Muhammad Umer KHAN",
  "ZE" : "Zühal ERDEN",
  "BSa" : "Bilge SAY",
  "IA" : "Kamil İbrahim AKMAN",
  "TH" : "Tuna HACALOĞLU",
  "AY" : "Ali YAZICI",
  "DC" : "Davut ÇULHA",
  "GU" : "GÖKÇE ULUS",
};

Map<String, Map<String, String>> teacherDictByDeps = {
  "MECE" : {
    "BI" : "Bülent İRFANOĞLU", // Mechatronics
  },
  "ME" : {
    "OA" : "Özgür ASLAN", // Mechanical Eng Dep
  },
  "ISE" : {
    "MK" : "Murat KOYUNCU", // ISE dep
  },
  "CE" : {
    "ES" : "Ertan SÖNMEZ", // Civil Eng
  },
  "SE" : {
    "GK" : "Güler KALEM", // Software Eng
  },
  "CEAC" : {
    "EG" : "Enver GÜLER", // Chemical Engineering
    "BI" : "Sultan Belgin İŞGÖR", // Chemical Engineering
  },
  "GRT" : {
    "ET" : "Evren TURAL", // for GRT314 and GRT232
    "EE" : "Fatma Emel ERTÜRK", // GRT department
    "MO" : "MEHMET MURAT ÖZKOYUNCU", // graphics design
  },
  "ICM" : {
    "EE" : "EDİZ ERDOĞDU", // ICM101 / 102 // ICM dep
  },
  "MMR" : {
    "FE" : "Faruk EŞİM", // Architecture // MMR
    "FD" : "MEHMET FERİDUN DUYGULUER", // for MMR306
    "MO" : "Mete ÖZ", // MMR401
  },
  "PLT" : {
    "ET" : "Erdal TORO", // PLT402
  },
  "AVM" : {
    "AO" : "Altan ÖZKİL", // AVM306
  },
};


Map<String, String>	teacherDictCivAvFac = {
  "MB" : "MEHMET BULUT",
  "HT" : "Hakan TORA",
  "OAy" : "Okan AYDIN",
  "AK" : "Ahmet KÖPRÜ",
  "MA" : "Mehmet ARGUN",
  "UK" : "ÜMİT KELEŞ",
  "MEr" : "Mehmet ERKAN",
  "EI" : "Erk İNGER",
  "NA" : "HÜSEYİN NAFİZ ALEMDAROĞLU",
  "MBe" : "Murat BELTAN",
  "NVE" : "Neşet Vefa ERDEN",
  "AO" : "ARDA ÖZMEN", // ART courses
  "ES" : "RECEP ENGİN SANSA",
  "OA" : "Onur AYMERGEN",
  "POl" : "Pınar OLGAÇ",
  "MO" : "Meral ÖZTÜRK",
  "TAr" : "Tanıl ARAYANCAN",
  "GAK" : "GONCA ARAT KOL",
  "NAn" : "NAZLI ANGIN AKINER",
  "ETa" : "EVREN TANDOĞAN",
  "ET" : "Emine TURGUT", // ART course\s
  "SAK" : "SEÇİL KUTLU",
  "IR" : "İzay REYHANOĞLU",
  "ESS" : "ESRA ŞENGÖR ŞENALP",
  "GG" : "Günseli GÜMÜŞEL",
  "GK" : "Gül KANİA",
  "AEK" : "AHMET EREN KURTER",
  "BTo" : "Burcu TOSUN",
  "KB" : "Hüseyin Kamil BÜYÜKMİRZA",
  "GU" : "GÖKÇE ULUS",
};


Map<String, String>	teacherDictFineArtsFac = {
  "AO" : "ARDA ÖZMEN",
  "ES" : "RECEP ENGİN SANSA",
  "PO" : "Pınar OLGAÇ",
  "MOz" : "Meral ÖZTÜRK",
  "TAr" : "Tanıl ARAYANCAN",
  "GAK" : "GONCA ARAT KOL",
  "NA" : "NAZLI ANGIN AKINER", // ARTS teacher, I remember that I forgot to fill the NA teacher for arts in the previousd facs
  "SP" : "ŞULE PFEIFFER",
  "ETa" : "EVREN TANDOĞAN",
  "ET" : "Emine TURGUT", // ARTS courses
  "SAK" : "SEÇİL KUTLU",
  "AV" : "Ayşegül VURAL",
  "FO" : "FATMA FİLİZ ÖZSUCA",
  "SI" : "ŞAHİN YİĞİTCAN IŞILAK",
  "MH" : "Mustafa HASDOĞAN",
  "CS" : "İBRAHİM ÇAĞRI ŞAHİN",
  "BU" : "Bülent ÜNAL",
  "ED" : "Emrah DEMİRHAN",
  "ST" : "Seçil TOROS",
  "SG" : "UĞUR SELİM GENÇOĞLU",
  "PG" : "Pelin GEZERYEL",
  "IO" : "ITIR TOKDEMİR ÖZÜDOĞRU",
  "FKC" : "FATİH KOYUNCU",
  "EEr" : "Ergin ERENOĞLU",
  "SS" : "Serdar SÜDOR",
  "GKB" : "GÜLTEKİN KAMİL BİRLİK",
  "GC" : "Gaye ÇULCUOGLU",
  "AUg" : "MAKBULE ASLI UĞURL",
  "CB" : "Çağrı BULHAZ",
  "CR" : "Çılga RESULOĞLU",
  "MD" : "MUSTAFA DEMİR",
  "MSC" : "MELİKE SELCAN CİHANGİROĞLU",
  "BAA" : "BEGÜM AKSEL ALKAN",
  "IM" : "İpek MEMİKOĞLU",
  "TA" : "MEHMET TAHİR AYPARLAR",
  "ITB" : "İpek BİLGİÇ",
  "FU" : "Feray ÜNLÜ",
  "BK" : "BUKET ERGUN KOCAİLİ",
  "GA" : "GÖKÇE NUR AYKAÇ",
  "NY" : "ÖZLEM NUR ASLANTAMER",
  "FE" : "FERHAT ERÖZ",
  "KEK" : "ERGİN KEMAL KOCAİLİ",
  "FSa" : "Füsun SALTIK",
  "GAkt" : "GÖZEN GÜNER AKTAŞ",
  "HG" : "Hakan GÖKDEMİR",
  "CK" : "MÜNİR CEM KAYALIGİL",
  "HGu" : "HAKKI GÜNGÖR",
  "FUB" : "FULAY UYSAL BİLGE",
  "SO" : "Selahattin ÖNÜR",
  "NBB" : "NEZİH BURAK BİCAN",
  "MC" : "Mustafa Can",
  "GI" : "Gamze İLALAN",
  "AH" : "Ali HAKKAN",
  "MY" : "MUSTAFA KEMAL YURTTAŞ",
  "BEKo" : "ECE BELAMİR KÖSE",
  "SKi" : "AHMET SİNAN KINIKOĞLU",
  "KO" : "Kemal ÖZGÜR",
  "EZ" : "Elif ZİLAN",
  "NK" : "NAZAN KIRCI",
  "EGo" : "Mustafa Erşan GÖKSU",
  "MG" : "Mediha GÜLTEK",
  "HOU" : "HATİCE ÜSKÜDAR ÖZER",
  "AU" : "AYDOĞAN ÜNSÜN",
  "GE" : "Günay ERDEM",
  "HE" : "Hakan EVKAYA",
  "KOz" : "Kaan ÖZER",
  "SL" : "Sevgi LÖKÇE",
  "GTo" : "Gökhan TOPRAK",
  "KA" : "CAHİT KUMRU ALPAYDIN ALTINKÖK",
  "MS" : "Mehmet SOYLU",
  "YH" : "Yeşim HATIRLI",
  "TC" : "TEZCAN KARAKUŞ CANDAN",
  "FK" : "Filiz BAL KOÇYİĞİT",
  "EA" : "EMEL AKIN",
  "HKa" : " Haluk KARA",
  "AOz" : "Aytaç ÖZEN",
  "CKi" : "Cansen KILIÇÇÖTE",
  "EU" : "Erdem ÜNVER",
  "EYG" : "ELİF YETKİN GÜRBÜZ",
  "SK" : "Songül KURU",
  "GAy" : "SEVGİ GAYE AYANOĞLU",
  "HD" : "Hikmet DİNÇ",
  "GS" : "GÜLŞEN SERDAR",
  "GU" : "GÜLÇİN TUĞBA NURDAN",
};

Map<String, Map<String, String>> teacherDictGeneral = {
  "HIST221" : const {
    "GK": "GÜL KANİA",
  },
};
