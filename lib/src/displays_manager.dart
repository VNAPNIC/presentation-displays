import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'display.dart';
import 'secondary_display.dart';

const _listDisplay = 'listDisplay';
const _showPresentation = 'showPresentation';
const _transferDataToPresentation = 'transferDataToPresentation';

/// Display category: secondary display.
/// <p>
/// This category can be used to identify secondary displays that are suitable for
/// use as presentation displays such as HDMI or Wireless displays.  Applications
/// may automatically project their content to presentation displays to provide
/// richer second screen experiences.
/// </p>
/// <p>
/// Use the following methods to query the real display area:
/// [DisplayManager.getDisplays], [DisplayManager.getNameByDisplayId],
/// [DisplayManager.getNameByIndex], [DisplayManager.showSecondaryDisplay],
/// [DisplayManager.transferDataToPresentation]
/// </p>
///
/// [DisplayManager.getDisplays]
///
const String displayCategoryPresentation =
    'android.hardware.display.category.PRESENTATION';

/// Provide you with the method for you to work with [SecondaryDisplay].
class DisplayManager {
  final _displayChannel = 'presentation_displays_plugin';
  MethodChannel? _displayMethodChannel;

  DisplayManager() {
    _displayMethodChannel = MethodChannel(_displayChannel);
  }

  /// Gets all currently valid logical displays of the specified category.
  /// <p>
  /// When there are multiple displays in a category the returned displays are sorted
  /// of preference.  For example, if the requested category is
  /// [displayCategoryPresentation] and there are multiple secondary display
  /// then the displays are sorted so that the first display in the returned array
  /// is the most preferred secondary display.  The application may simply
  /// use the first display or allow the user to choose.
  /// </p>
  ///
  /// [category] The requested display category or null to return all displays.
  /// @return An array containing all displays sorted by order of preference.
  ///
  /// See [displayCategoryPresentation]
  FutureOr<List<Display>?> getDisplays({String? category}) async {
    final List<dynamic> origins = await jsonDecode(await _displayMethodChannel
            ?.invokeMethod(_listDisplay, category)) ??
        [];
    final List<Display> displays = [];
    for (final element in origins) {
      final map = jsonDecode(jsonEncode(element));
      displays.add(displayFromJson(map));
    }
    return displays;
  }

  /// Gets the name of the display by [displayId] of [getDisplays].
  /// <p>
  /// Note that some displays may be renamed by the user.
  /// [category] The requested display category or null to return all displays.
  /// See [displayCategoryPresentation]
  /// </p>
  ///
  /// @return The display's name.
  /// May be null.
  FutureOr<String?> getNameByDisplayId(int displayId,
      {String? category}) async {
    final List<Display> displays = await getDisplays(category: category) ?? [];

    String? name;
    for (final element in displays) {
      if (element.displayId == displayId) name = element.name;
    }
    return name;
  }

  /// Gets the name of the display by [index] of [getDisplays].
  /// <p>
  /// Note that some displays may be renamed by the user.
  /// [category] The requested display category or null to return all displays.
  /// see [displayCategoryPresentation]
  /// </p>
  ///
  /// @return The display's name
  /// May be null.
  FutureOr<String?> getNameByIndex(int index, {String? category}) async {
    final List<Display> displays = await getDisplays(category: category) ?? [];
    String? name;
    if (index >= 0 && index <= displays.length) name = displays[index].name;
    return name;
  }

  /// Creates a new secondary display that is attached to the specified display
  /// <p>
  /// Before displaying a secondary display, please define the UI you want to display in the [Route].
  /// If we can't find the router name, the secondary display a blank screen
  /// [displayId] The id of display to which the secondary display should be attached.
  /// [routerName] The screen you want to display on the secondary display.
  /// </P>
  ///
  /// return [Future<bool>] about the status has been display or not
  Future<bool?>? showSecondaryDisplay(
      {required int displayId, required String routerName}) {
    return _displayMethodChannel?.invokeMethod<bool?>(
        _showPresentation,
        '{'
        '"displayId": $displayId,'
        '"routerName": "$routerName"'
        '}');
  }

  /// Transfer data to a secondary display
  /// <p>
  /// Transfer data from main screen to a secondary display
  /// Consider using [arguments] for cases where a particular run-time type is expected. Consider using String when that run-time type is Map or JSONObject.
  /// </p>
  /// <p>
  /// Main Screen
  ///
  /// ```dart
  /// DisplayManager displayManager = DisplayManager();
  /// ...
  /// static Future<void> transferData(Song song) async {
  ///   displayManager.transferDataToPresentation(<String, dynamic>{
  ///         'id': song.id,
  ///         'title': song.title,
  ///         'artist': song.artist,
  ///       });
  /// }
  /// ```
  /// Secondary display
  ///
  /// ```dart
  /// class _SecondaryScreenState extends State<SecondaryScreen> {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///       return PresentationDisplay(
  ///        callback: (argument) {
  ///          Song.fromJson(argument)
  ///       },
  ///       child: Center()
  ///     );
  ///   }
  /// }
  /// ```
  /// Class Song
  ///
  /// ```dart
  /// class Song {
  ///   Song(this.id, this.title, this.artist);
  ///
  ///   final String id;
  ///   final String title;
  ///   final String artist;
  ///
  ///   static Song fromJson(dynamic json) {
  ///     return Song(json['id'], json['title'], json['artist']);
  ///   }
  /// }
  /// ```
  /// </p>
  ///
  /// return [Future<bool>] the value to determine whether or not the data has been transferred successfully
  Future<bool?>? transferDataToPresentation(dynamic arguments) {
    return _displayMethodChannel?.invokeMethod<bool?>(
        _transferDataToPresentation, arguments);
  }
}
