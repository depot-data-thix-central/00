import 'main_native.dart' if (dart.library.html) 'main_web.dart' as app;

Future<void> main() => app.main();
