import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:presentation_displays/display.dart';

const _listDisplay = "listDisplay";
const _showPresentation = "showPresentation";
const _transferDataToPresentation = "transferDataToPresentation";

const String DISPLAY_CATEGORY_PRESENTATION =
    "android.hardware.display.category.PRESENTATION";

/// it will provide you with the method for you to work with [PresentationDisplay].
class DisplayManager {
  final _displayChannel = "presentation_displays_plugin";
  MethodChannel _displayMethodChannel;

  DisplayManager() {
    _displayMethodChannel = MethodChannel(_displayChannel);
  }

  /// Gets all currently valid logical displays of the specified category.
  /// <p>
  /// When there are multiple displays in a category the returned displays are sorted
  /// of preference.  For example, if the requested category is
  /// {@link [DISPLAY_CATEGORY_PRESENTATION]} and there are multiple presentation displays
  /// then the displays are sorted so that the first display in the returned array
  /// is the most preferred presentation display.  The application may simply
  /// use the first display or allow the user to choose.
  /// </p>
  ///
  /// [category] The requested display category or null to return all displays.
  /// @return An array containing all displays sorted by order of preference.
  ///
  /// @see [DISPLAY_CATEGORY_PRESENTATION]
  FutureOr<List<Display>> getDisplays({String category}) async {
    List<dynamic> origins = await jsonDecode(await _displayMethodChannel
            ?.invokeMethod(_listDisplay, category)) ??
        [];
    List<Display> displays = [];
    origins.forEach((element) {
      Map map = jsonDecode(jsonEncode(element));
      displays.add(displayFromJson(map));
    });
    return displays;
  }

  /// Gets the name of the display by [displayId] of [getDisplays].
  /// <p>
  /// Note that some displays may be renamed by the user.
  /// [category] The requested display category or null to return all displays.
  /// @see [DISPLAY_CATEGORY_PRESENTATION]
  /// </p>
  ///
  /// @return The display's name.
  /// May be null.
  FutureOr<String> getNameByDisplayId(int displayId, {String category}) async {
    List<Display> displays = await getDisplays(category: category) ?? [];

    String name;
    displays.forEach((element) {
      if (element.displayId == displayId) name = element.name;
    });
    return name;
  }

  /// Gets the name of the display by [index] of [getDisplays].
  /// <p>
  /// Note that some displays may be renamed by the user.
  /// [category] The requested display category or null to return all displays.
  /// @see [DISPLAY_CATEGORY_PRESENTATION]
  /// </p>
  ///
  /// @return The display's name
  /// May be null.
  FutureOr<String> getNameByIndex(int index, {String category}) async {
    List<Display> displays = await getDisplays(category: category) ?? [];
    String name;
    if (index >= 0 && index <= displays.length) name = displays[index].name;
    return name;
  }

  /// Creates a new presentation that is attached to the specified display
  /// using the default theme.
  /// <p>
  /// Before displaying a Presentation display, please define the UI you want to display in the [Route].
  /// If we can't find the router name, the presentation displays a blank screen
  /// [displayId] The id of display to which the presentation should be attached.
  /// [routerName] The screen you want to display on the presentation.
  /// </P>
  ///
  /// @return [Future<bool>] about the status has been display or not
  Future<bool> showPresentation(
      {@required int displayId, @required String routerName}) {
    return _displayMethodChannel?.invokeMethod(
        _showPresentation,
        "{"
        "\"displayId\": $displayId,"
        "\"routerName\": \"$routerName\""
        "}");
  }

  /// Transfer data to Presentation display
  /// <p>
  /// Transfer data from main screen to screen Presentation display
  /// Consider using [arguments] for cases where a particular run-time type is expected. Consider using String when that run-time type is Map or JSONObject.
  /// </p>
  ///
  /// @return [Future<bool>] the value to determine whether or not the data has been transferred successfully
  Future<bool> transferDataToPresentation(dynamic arguments) {
    return _displayMethodChannel?.invokeMethod(
        _transferDataToPresentation, arguments);
  }
}
