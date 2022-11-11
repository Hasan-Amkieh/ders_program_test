//
// Created by Hasan on 9/17/2022.
//

#ifdef WIN32
   #define EXPORT __declspec(dllexport)
#else
   #define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))
#endif

#include <windows.h>

EXPORT
void hideWebView() {

   HWND window = FindWindowA(NULL, "Timetable Webpage"); // if it does work, then try to switch between the NULL and the name of the window
   if (window != NULL) {
        ShowWindow(window, 0);
   }

}

EXPORT
void changeWindowName() { // NOTE: For some reason, the app I have does not get the name "Atsched", it get s the old name, Idk why, this fixes the issue

   HWND window = FindWindowA(NULL, "ders_program_test");

    if (window != NULL) {
        SetWindowText(window, L"Atsched");
    }

}

