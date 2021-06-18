Display displayFromJson(Map<String, dynamic> json) => Display(
    displayId: json['displayId'],
    flag: json['flags'],
    name: json['name'],
    rotation: json['rotation']);

/// The default Display id, which is the id of the built-in primary display
/// assuming there is one.
const int DEFAULT_DISPLAY = 0;

/// Invalid display id.
const int INVALID_DISPLAY = -1;

/// Display flag: Indicates that the display supports compositing content
/// that is stored in protected graphics buffers.
/// <p>
/// If this flag is set then the display device supports compositing protected buffers.
/// </p>
/// <p>
/// If this flag is not set then the display device may not support compositing
/// protected buffers; the user may see a blank region on the screen instead of
/// the protected content.
/// </p>
/// <p>
/// Secure (DRM) video decoders may allocate protected graphics buffers to request that
/// a hardware-protected path be provided between the video decoder and the external
/// display sink.  If a hardware-protected path is not available, then content stored
/// in protected graphics buffers may not be composited.
/// </p>
/// <p>
/// An application can use the absence of this flag as a hint that it should not use protected
/// buffers for this display because the content may not be visible.  For example,
/// if the flag is not set then the application may choose not to show content on this
/// display, show an informative error message, select an alternate content stream
/// or adopt a different strategy for decoding content that does not rely on
/// protected buffers.
/// </p>
///
/// See [Display.flag]
const int FLAG_SUPPORTS_PROTECTED_BUFFERS = 1 << 0;

/// Display flag: Indicates that the display has a secure video output and
/// supports compositing secure surfaces.
/// <p>
/// If this flag is set then the display device has a secure video output
/// and is capable of showing secure surfaces.  It may also be capable of
/// showing [FLAG_SUPPORTS_PROTECTED_BUFFERS] protected buffers.
/// </p>
/// <p>
/// If this flag is not set then the display device may not have a secure video
/// output; the user may see a blank region on the screen instead of
/// the contents of secure surfaces or protected buffers.
/// </p>
/// <p>
/// Secure surfaces are used to prevent content rendered into those surfaces
/// by applications from appearing in screenshots or from being viewed
/// on non-secure displays. Protected buffers are used by secure video decoders
/// for a similar purpose.
/// </p>
/// <p>
/// An application creates a window with a secure surface by specifying the
/// [FLAG_SECURE] window flag.
/// Likewise, an application creates a SurfaceView with a secure surface
/// by calling before attaching the secure view to
/// its containing window.
/// </p>
/// <p>
/// An application can use the absence of this flag as a hint that it should not create
/// secure surfaces or protected buffers on this display because the content may
/// not be visible.  For example, if the flag is not set then the application may
/// choose not to show content on this display, show an informative error message,
/// select an alternate content stream or adopt a different strategy for decoding
/// content that does not rely on secure surfaces or protected buffers.
/// </p>
///
/// See [Display.flag]
const int FLAG_SECURE = 1 << 1;

/// Display flag: Indicates that the display is private.  Only the application that
/// owns the display and apps that are already on the display can create windows on it.
///
/// See [Display.flag]
const int FLAG_PRIVATE = 1 << 2;

/// Rotation constant: 0 degree rotation (natural orientation)
const int ROTATION_0 = 0;

/// Rotation constant: 90 degree rotation.
const int ROTATION_90 = 1;

/// Rotation constant: 180 degree rotation.
const int ROTATION_180 = 2;

/// Rotation constant: 270 degree rotation.
const int ROTATION_270 = 3;

/// Provides information about of a logical display.
/// <p>
/// A logical display does not necessarily represent a particular physical display device
/// such as the built-in screen or an external monitor.  The contents of a logical
/// display may be presented on one or more physical displays according to the devices
/// that are currently attached and whether mirroring has been enabled.
/// Use the following methods to query the real display area:
/// [Display.displayId], [Display.flag], [Display.rotation], [Display.name]
/// </p>
///
class Display {
  /// Gets the display id.
  /// <p>
  /// Each logical display has a unique id.
  /// The default display has id [DEFAULT_DISPLAY]
  /// </p>
  int displayId = DEFAULT_DISPLAY;

  /// Returns a combination of flags that describe the capabilities of the display.
  /// @return The display flags.
  ///
  /// See [FLAG_SUPPORTS_PROTECTED_BUFFERS], [FLAG_SECURE], [FLAG_PRIVATE]
  int? flag;

  /// Returns the rotation of the screen from its "natural" orientation.
  /// The returned value may be [ROTATION_0]
  /// (no rotation), [ROTATION_90], [ROTATION_180], or [ROTATION_270].  For
  /// example, if a device has a naturally tall screen, and the user has
  /// turned it on its side to go into a landscape orientation, the value
  /// returned here may be either [ROTATION_90] or [ROTATION_270] depending on
  /// the direction it was turned.  The angle is the rotation of the drawn
  /// graphics on the screen, which is the opposite direction of the physical
  /// rotation of the device.  For example, if the device is rotated 90
  /// degrees counter-clockwise, to compensate rendering will be rotated by
  /// 90 degrees clockwise and thus the returned value here will be
  /// [ROTATION_90].
  int? rotation;

  /// Gets the name of the display.
  /// <p>
  /// Note that some displays may be renamed by the user.
  /// </p>
  ///
  /// @return The display's name.
  String name;

  Display(
      {required this.displayId, this.flag, required this.name, this.rotation});
}
