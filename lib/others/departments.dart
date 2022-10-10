import 'dart:core';

import '../main.dart';

const Map<String, Map<String, String>> faculties = {
  "Engineering" : engineeringDeps,
  "Civil Aviation" : civilAviationDeps,
  "Health Sciences" : healthSciencesDeps,
  "Arts and Sciences" : artsnScienceDeps,
  "Fine Arts" : fineArtsDeps,
  //"Law" : lawDeps, // Since version 1.1.1, the university stopped uploading the faculty's info
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
    return Main.engineeringLink;
  } else if (civilAviationDeps.keys.contains(depName)) {
    return Main.civilAviationLink;
  } else if (healthSciencesDeps.keys.contains(depName)) {
    return Main.healthSciencesLink;
  } else if (artsnScienceDeps.keys.contains(depName)) {
    return Main.artsNSciencesLink;
  } else if (fineArtsDeps.keys.contains(depName)) {
    return Main.fineArtsLink;
  } else if (lawDeps.keys.contains(depName)) {
    return Main.lawLink;
  } else if (businessDeps.keys.contains(depName)) {
    return Main.businessLink;
  }

  return "";

}
