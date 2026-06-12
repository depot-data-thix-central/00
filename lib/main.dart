// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/auth/supabase_auth_manager.dart';
import 'package:thix_id/l10n/app_localizations.dart';
import 'package:thix_id/l10n/locale_controller.dart';
import 'package:thix_id/nav.dart';
import 'package:thix_id/supabase/supabase_config.dart';
import 'package:thix_id/theme.dart';
import 'package:thix_id/services/cart_service.dart';
import 'package:thix_id/services/network_service.dart';
import 'package:thix_id/providers/feed_provider.dart';
import 'package:thix_id/services/event_service.dart';
import 'package:thix_id/providers/event_provider.dart';
import 'package:thix_id/services/news_service.dart';
import 'package:thix_id/providers/news_provider.dart';
import 'package:thix_id/services/notification_service.dart';
import 'package:thix_id/services/notification_counters_service.dart';

// ============================================================
// IMPORTS POUR THIX CHAT
// ============================================================
// Providers
import 'package:thix_id/providers/chat_provider.dart';
import 'package:thix_id/providers/ephemeral_provider.dart';
import 'package:thix_id/providers/poll_provider.dart';
import 'package:thix_id/providers/scheduled_provider.dart';
import 'package:thix_id/providers/translation_provider.dart';
import 'package:thix_id/providers/voice_provider.dart';
import 'package:thix_id/providers/location_provider.dart';
import 'package:thix_id/providers/read_receipt_provider.dart';
import 'package:thix_id/providers/group_provider.dart';
import 'package:thix_id/providers/theme_provider.dart';
import 'package:thix_id/providers/status_provider.dart';
import 'package:thix_id/providers/call_provider.dart';
import 'package:thix_id/providers/data_saver_provider.dart';
import 'package:thix_id/providers/archive_provider.dart';

// Services (pour les providers qui en ont besoin)
import 'package:thix_id/services/chat_service.dart';
import 'package:thix_id/services/ephemeral_service.dart';
import 'package:thix_id/services/poll_service.dart';
import 'package:thix_id/services/scheduled_service.dart';
import 'package:thix_id/services/translation_service.dart';
import 'package:thix_id/services/voice_service.dart';
import 'package:thix_id/services/location_service.dart';
import 'package:thix_id/services/read_receipt_service.dart';
import 'package:thix_id/services/group_service.dart';
import 'package:thix_id/services/theme_service.dart';
import 'package:thix_id/services/status_service.dart';
import 'package:thix_id/services/call_service.dart';
import 'package:thix_id/services/data_saver_service.dart';
import 'package:thix_id/services/archive_service.dart';

/// Main entry point for the application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) debugPrint(details.stack.toString());
  };
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('ErrorWidget: ${details.exceptionAsString()}');
    if (details.stack != null) debugPrint(details.stack.toString());
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Une erreur est survenue.\n\n${kDebugMode ? details.exceptionAsString() : ''}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  try {
    await SupabaseConfig.initialize();
  } catch (e, st) {
    debugPrint('Main: SupabaseConfig.initialize failed err=$e');
    debugPrint(st.toString());
  }

  final auth = AuthController(auth: SupabaseAuthManager());
  try {
    await auth.init();
  } catch (e, st) {
    debugPrint('Main: auth.init failed err=$e');
    debugPrint(st.toString());
  }
  runApp(MyApp(auth: auth));
}

class MyApp extends StatefulWidget {
  final AuthController auth;
  const MyApp({super.key, required this.auth});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LocaleController _localeController;
  late final _router;
  
  // Services existants
  late final NetworkService _networkService;
  late final EventService _eventService;
  late final NewsService _newsService;
  
  // ============================================================
  // SERVICES POUR THIX CHAT
  // ============================================================
  late final ChatService _chatService;
  late final EphemeralService _ephemeralService;
  late final PollService _pollService;
  late final ScheduledService _scheduledService;
  late final TranslationService _translationService;
  late final VoiceService _voiceService;
  late final LocationService _locationService;
  late final ReadReceiptService _readReceiptService;
  late final GroupService _groupService;
  late final ThemeService _themeService;
  late final StatusService _statusService;
  late final CallService _callService;
  late final DataSaverService _dataSaverService;
  late final ArchiveService _archiveService;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController()..init();
    
    final supabaseClient = SupabaseConfig.client;
    
    // Services existants
    _networkService = NetworkService(supabaseClient);
    _eventService = EventService(supabaseClient);
    _newsService = NewsService(supabaseClient);
    
    // ============================================================
    // INITIALISATION DES SERVICES THIX CHAT
    // ============================================================
    _chatService = ChatService(supabaseClient);
    _ephemeralService = EphemeralService(supabaseClient);
    _pollService = PollService(supabaseClient);
    _scheduledService = ScheduledService(supabaseClient);
    _translationService = TranslationService(supabaseClient);
    _voiceService = VoiceService(supabaseClient);
    _locationService = LocationService(supabaseClient);
    _readReceiptService = ReadReceiptService(supabaseClient);
    _groupService = GroupService(supabaseClient);
    _themeService = ThemeService();
    _statusService = StatusService(supabaseClient);
    _callService = CallService(supabaseClient);
    _dataSaverService = DataSaverService();
    _archiveService = ArchiveService(supabaseClient);
    
    _router = AppRouter.create(widget.auth, extraRefreshListenable: _localeController);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ============================================================
        // PROVIDERS EXISTANTS
        // ============================================================
        ChangeNotifierProvider.value(value: widget.auth),
        ChangeNotifierProvider.value(value: _localeController),
        ChangeNotifierProvider(create: (_) => CartService()),
        
        // Network providers
        Provider<NetworkService>.value(value: _networkService),
        ChangeNotifierProxyProvider<NetworkService, FeedProvider>(
          create: (context) => FeedProvider(_networkService),
          update: (context, networkService, previous) =>
              previous ?? FeedProvider(networkService),
        ),
        
        // EventProvider
        Provider<EventService>.value(value: _eventService),
        ChangeNotifierProxyProvider<EventService, EventProvider>(
          create: (context) => EventProvider(_eventService),
          update: (context, eventService, previous) =>
              previous ?? EventProvider(eventService),
        ),
        
        // NewsProvider
        Provider<NewsService>.value(value: _newsService),
        ChangeNotifierProxyProvider<NewsService, NewsProvider>(
          create: (context) => NewsProvider(_newsService),
          update: (context, newsService, previous) =>
              previous ?? NewsProvider(newsService),
        ),
        
        // Notification services
        Provider<NotificationService>.value(value: NotificationService()),
        Provider<NotificationCountersService>.value(value: NotificationCountersService()),
        
        // ============================================================
        // PROVIDERS THIX CHAT
        // ============================================================
        
        // 1. Chat Provider
        Provider<ChatService>.value(value: _chatService),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        
        // 2. Ephemeral Provider
        Provider<EphemeralService>.value(value: _ephemeralService),
        ChangeNotifierProvider(create: (_) => EphemeralProvider()),
        
        // 3. Poll Provider
        Provider<PollService>.value(value: _pollService),
        ChangeNotifierProvider(create: (_) => PollProvider()),
        
        // 4. Scheduled Provider
        Provider<ScheduledService>.value(value: _scheduledService),
        ChangeNotifierProvider(create: (_) => ScheduledProvider()),
        
        // 5. Translation Provider
        Provider<TranslationService>.value(value: _translationService),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        
        // 6. Voice Provider
        Provider<VoiceService>.value(value: _voiceService),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
        
        // 7. Location Provider
        Provider<LocationService>.value(value: _locationService),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        
        // 8. Read Receipt Provider
        Provider<ReadReceiptService>.value(value: _readReceiptService),
        ChangeNotifierProvider(create: (_) => ReadReceiptProvider()),
        
        // 9. Group Provider
        Provider<GroupService>.value(value: _groupService),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        
        // 10. Theme Provider (sans service nécessaire)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // 11. Status Provider
        Provider<StatusService>.value(value: _statusService),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        
        // 12. Call Provider
        Provider<CallService>.value(value: _callService),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        
        // 13. Data Saver Provider
        Provider<DataSaverService>.value(value: _dataSaverService),
        ChangeNotifierProvider(create: (_) => DataSaverProvider()),
        
        // 14. Archive Provider
        Provider<ArchiveService>.value(value: _archiveService),
        ChangeNotifierProvider(create: (_) => ArchiveProvider()),
      ],
      child: Builder(
        builder: (context) {
          final locale = context.watch<LocaleController>().locale;
          return MaterialApp.router(
            title: 'THIX ID',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _router,
            locale: locale,
            supportedLocales: LocaleController.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
