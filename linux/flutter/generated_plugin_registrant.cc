//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_linux/file_selector_plugin.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <smart_auth/smart_auth_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) flutter_webrtc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FlutterWebRTCPlugin");
  flutter_web_r_t_c_plugin_register_with_registrar(flutter_webrtc_registrar);
  g_autoptr(FlPluginRegistrar) smart_auth_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SmartAuthPlugin");
  smart_auth_plugin_register_with_registrar(smart_auth_registrar);
}
