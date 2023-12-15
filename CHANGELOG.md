## 1.0.0
* Able to package android release build. Works fine in example app.

* Tested example app in android tab and ios tab and things work as expected. Ensure the devices have USB C 3.0 and above else HDMI out is not supported.

* In case of iOS, please refer to example app app delegate. There are few lines of code which needs to be added to your app's app delegate as well for this to work fine in iOS.

* Updated optional issues and null checks

* Added option to hide second display from the first

* WIP support second main in iOS for extended display

* WIP Send data back from 2nd to 1st display

## 0.2.3
* Fix for "show presentation" wrong index

## 0.2.2
*gradle updated & and example proguard rule added


## 0.2.1
* Adding getDisplays, getNameByDisplayId, and getNameByIndex for iOS
* Allowing the user to select the screen index and routerName for show presentation for iOS
* Changing the example UI to allow user input and showing the result on the UI

## 0.2.0

* Supported IOS platform

## 0.1.9

* Supported Null Safety

## 0.1.8

* update Readme.md

## 0.1.7

* update documents
* Replace PresentationDisplay to SecondaryDisplay

## 0.1.6

* update documents of transferDataToPresentation

## 0.1.5

* update documents

## 0.1.4

* add documents

## 0.1.3

* fix static analysis

## 0.1.2

* add video demo

## 0.1.1

* remove DisplaysManager widget

## 0.1.0

* Initial Open Source release.
