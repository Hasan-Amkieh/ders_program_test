import 'dart:core';

const Map<String, Map<String, String>> faculties = {
  "Engineering" : engineeringDeps,
  "Civil Aviation" : civilAviationDeps,
  "Health Sciences" : healthSciencesDeps,
  "Arts and Sciences" : artsnScienceDeps,
  "Fine Arts" : fineArtsDeps,
  "Law" : lawDeps,
  "Business" : businessDeps,
};

const Map<String, String> engineeringDeps = {
  "AE" : "Automotive Engineering",
  "ASE" : "Aerospace Engineering",
  "CE": "Civil Engineering",
  "CEAC": "Chemical Engineering",
  "CMPE": "Computer Engineering",
  "EE": "Electrical Engineering",
  "ENE": "Energy Engineering",
  "IE": "Industrial Engineering",
  "ISE": "Information Systems Engineering",
  "MATE": "Material Engineering",
  "ME": "Mechanical Engineering",
  "MECE": "Mechatronics Engineering",
  "MFGE": "Manufacturing Engineering",
  "SE": "Software Engineering"
};

const Map<String, String> civilAviationDeps = {
  "AEE" : "Avionics",
  "APM" : "Airframe & Powerplant Maintenance",
  "AVM" : "Aviation Management",
  "PLT" : "Pilot Training",
};

const Map<String, String> healthSciencesDeps = { // TODO: Look For CHL1 and do smth about it
  "NURS" : "Nursery",
  "NUT" : "Nutrition and Dietetics",
  "PTR" : "Physiotherapy and Rehabilitation",
};

const Map<String, String> artsnScienceDeps = {
  "ELIT" : "English Language and Literature",
  "ETI" : "English Translation and Interpretation",
  "MATH" : "Mathematics",
  "PSY" : "Psychology",
};

const Map<String, String> fineArtsDeps = {
  "EUT" : "Industrial Product Design", // Endüstriyel Ürün Tasarımı
  "GRT" : "Graphics Design", // Grafik Tasarim
  "ICM" : "Interior Architecture & Env. Design", // and Environmental Design , I cut Env. word bcs no space
  "MMR" : "Architecture", // Mimar
  "MMT" : "Textile and Fashion Design",
};

const Map<String, String> lawDeps = {
  "LAW" : "Law", // hukuk
  "Adalet" : "Justice"
};

const Map<String, String> businessDeps = {
  "ECON" : "Economics", // In English
  "IR" : "International Relations",
  "KAM" : "Political Science & Business Admin.",
  "LOG" : "International Trade and Logistics",
  "MAN" : "Business Administration (English)",
  "ISL" : "Business Administration (Turkish)",
  "MLY" : "Public Finance",
  "PR" : "Public Relations and Advertising",
  "TOUR" : "Tourism Management"
};

String getFacultyLink(String depName) {

  if (engineeringDeps.keys.contains(depName)) {
    return "https://atilimengr.edupage.org/timetable/view.php?num=22&class=*2";
  } else if (civilAviationDeps.keys.contains(depName)) {
    return "https://atilimcav.edupage.org/timetable/view.php?num=20&class=-84";
  } else if (healthSciencesDeps.keys.contains(depName)) {
    return "https://atilimhlth.edupage.org/timetable/view.php?num=12&class=*1";
  } else if (artsnScienceDeps.keys.contains(depName)) {
    return "https://atilimartsci.edupage.org/timetable/view.php?num=22&subject=-279";
  } else if (fineArtsDeps.keys.contains(depName)) {
    return "https://atilimgstm.edupage.org/timetable/view.php?num=19&class=-119";
  } else if (lawDeps.keys.contains(depName)) {
    return "https://atilimlaw.edupage.org/timetable/?&lang=tr";
  } else if (businessDeps.keys.contains(depName)) { //
    return "https://atilimmgmt.edupage.org/timetable/view.php?num=23&subject=*372";
  }

  return "";

}
