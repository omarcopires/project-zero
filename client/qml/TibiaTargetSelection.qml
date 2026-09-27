import QtQuick

/* Compatibility surface; map targeting is not wired to a world controller yet. */
Item {
  signal targetSelected(int mouseX, int mouseY)
}
