import QtQuick

/*
 * Text-based fallback for the native cached outline text renderer. It keeps
 * the Text API and cache mode names used by the existing QML components.
 */
Text {
  enum CacheMode {
    NoCaching = 0,
    ReleaseLater = 1,
    ReleaseImmediately = 2
  }

  property int cacheMode: CachedOutlineText.NoCaching
  property bool debugOverlay: false
}
