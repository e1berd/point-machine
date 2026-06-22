#include <cstdlib>

#include "my_application.h"

int main(int argc, char** argv) {
  // Default to the Impeller (Vulkan) backend for high-refresh rendering.
  // The Flutter tool sets these itself when launched with --enable-impeller,
  // so dev runs keep control; this only affects standalone bundles.
  setenv("FLUTTER_ENGINE_SWITCHES", "1", 0);
  setenv("FLUTTER_ENGINE_SWITCH_1", "enable-impeller=true", 0);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
