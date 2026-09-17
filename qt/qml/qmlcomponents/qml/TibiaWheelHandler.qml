import QtQuick

WheelHandler {
  // Qt6 changed the default from PointerDevice.AllDevices to PointerDevice.Mouse
  // it seems that some systems like Wayland deliver a Touch-Event which results in the effect that no more
  // events are processed by the WheelHandler. So we subclass it and set our own default
  // see: TIBIA-36551
  acceptedDevices: PointerDevice.AllDevices
}
