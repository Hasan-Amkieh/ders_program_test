import 'dart:core';

List<String> langs = ["English", "Turkish"];

Map<String, String> engToTurk = {
  "Schedule" : "Ders Programı",
  "Settings" : "Ayarlar",
  "Links" : "Bağlantılar",
  "Tools" : "Aletler",
  /*"" : "",
  "" : "",
  "" : "",
  "" : "",
  "" : "",
  "" : "",
  "" : "",*/
};

String? translateEng(String eng) {

  if (engToTurk.containsKey(eng)) {
    return engToTurk[eng];
  } else {
    return eng;
  }

}

