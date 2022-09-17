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
   ShowWindow(window, 0);

}

