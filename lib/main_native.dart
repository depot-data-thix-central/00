// 📁 lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

// ==================== THIX CHAT ====================
import 'package:thix_id/presentation/chat/core/chat_bloc.dart';
import 'package:thix_id/presentation/chat/core/chat_repository.dart';
import 'package:thix_id/core/auth/token_service.dart';

// ==================== THIX MARKET ====================
import 'package:thix_id/presentation/thix_market/providers/market_provider.dart';
import 'package:thix_id/presentation/thix_market/providers/shop_provider.dart';
import 'package:thix_id/presentation/thix_market/providers/product_provider.dart';
import 'package:thix_id/presentation/thix_market/providers/search_provider.dart';
import 'package:thix_id/presentation/thix_market/providers/live_provider.dart';
import 'package:thix_id/presentation/thix_market/providers/message_provider.dart';
import 'package:thix_id/presentation/thix_market/cart/cart_provider.dart';
import 'package:thix_id/presentation/thix_market/checkout/checkout_provider.dart';
import 'package:thix_id/presentation/thix_market/delivery/delivery_provider.dart';
import 'package:thix_id/presentation/thix_market/admin/admin_provider.dart';

// ==================== THIX MONEY ====================
import 'package:thix_id/presentation/thix_money/providers/thix_money_provider.dart';
import 'package:thix_id/presentation/thix_money/providers/transaction_provider.dart';
import 'package:thix_id/presentation/thix_money/providers/card_provider.dart';
import 'package:thix_id/presentation/thix_money/providers/merchant_provider.dart';
import 'package:thix_id/services/thix_money/balance_service.dart';
import 'package:thix_id/services/thix_money/transaction_service.dart';
import 'package:thix_id/services/thix_money/card_service.dart';
import 'package:thix_id/services/thix_money/merchant_service.dart';

// ==================== THIX SANTÉ ====================
// Providers
import 'package:thix_id/presentation/thix_sante/common/providers/symptom_provider.dart';
import 'package:thix_id/presentation/thix_sante/common/providers/constant_provider.dart';
import 'package:thix_id/presentation/thix_sante/common/providers/medication_provider.dart';
import 'package:thix_id/presentation/thix_sante/common/providers/ai_provider.dart';
import 'package:thix_id/presentation/thix_sante/common/providers/alert_provider.dart';

import 'package:thix_id/presentation/thix_sante/patient/providers/patient_dashboard_provider.dart';
import 'package:thix_id/presentation/thix_sante/patient/providers/patient_data_provider.dart';

import 'package:thix_id/presentation/thix_sante/doctor/providers/doctor_dashboard_provider.dart';
import 'package:thix_id/presentation/thix_sante/doctor/providers/doctor_patient_provider.dart';
import 'package:thix_id/presentation/thix_sante/doctor/providers/doctor_prescription_provider.dart';

import 'package:thix_id/presentation/thix_sante/pharmacy/providers/pharmacy_order_provider.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/providers/pharmacy_inventory_provider.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/providers/pharmacy_delivery_provider.dart';

// Repositories
import 'package:thix_id/data/repositories/symptom_repository.dart';
import 'package:thix_id/data/repositories/constant_repository.dart';
import 'package:thix_id/data/repositories/medication_repository.dart';
import 'package:thix_id/data/repositories/alert_repository.dart';
import 'package:thix_id/data/repositories/patient_repository.dart';
import 'package:thix_id/data/repositories/appointment_repository.dart';
import 'package:thix_id/data/repositories/prescription_repository.dart';
import 'package:thix_id/data/repositories/drug_repository.dart';
import 'package:thix_id/data/repositories/delivery_repository.dart';

// Services IA
import 'package:thix_id/services/ai/openai_service.dart';

// Shared Providers
import 'package:thix_id/presentation/shared/providers/role_provider.dart';


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

  // Initialisation du token JWT pour les Edge Functions
  await TokenService.getToken();

  runApp(ProviderScope(child: MyApp(auth: auth)));
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

  // ==================== SERVICES EXISTANTS ====================
  late final NetworkService _networkService;
  late final EventService _eventService;
  late final NewsService _newsService;

  // Services chat
  late final ChatRepository _chatRepository;
  late final ChatBloc _chatBloc;

  // ==================== SERVICES THIX MONEY ====================
  late final BalanceService _balanceService;
  late final TransactionService _transactionService;
  late final CardService _cardService;
  late final MerchantService _merchantService;

  // ==================== SERVICES THIX SANTÉ ====================
  late final SymptomRepository _symptomRepository;
  late final ConstantRepository _constantRepository;
  late final MedicationRepository _medicationRepository;
  late final AlertRepository _alertRepository;
  late final PatientRepository _patientRepository;
  late final AppointmentRepository _appointmentRepository;
  late final PrescriptionRepository _prescriptionRepository;
  late final DrugRepository _drugRepository;
  late final DeliveryRepository _deliveryRepository;
  late final OpenAIService _openAIService;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController()..init();

    final supabaseClient = SupabaseConfig.client;

    // ==================== SERVICES EXISTANTS ====================
    _networkService = NetworkService(supabaseClient);
    _eventService = EventService(supabaseClient);
    _newsService = NewsService(supabaseClient);

    _chatRepository = ChatRepository();
    _chatBloc = ChatBloc(_chatRepository);

    // ==================== SERVICES THIX MONEY ====================
    _balanceService = BalanceService();
    _transactionService = TransactionService();
    _cardService = CardService();
    _merchantService = MerchantService();

    // ==================== SERVICES THIX SANTÉ ====================
    _symptomRepository = SymptomRepository();
    _constantRepository = ConstantRepository();
    _medicationRepository = MedicationRepository();
    _alertRepository = AlertRepository();
    _patientRepository = PatientRepository();
    _appointmentRepository = AppointmentRepository();
    _prescriptionRepository = PrescriptionRepository();
    _drugRepository = DrugRepository();
    _deliveryRepository = DeliveryRepository();
    _openAIService = OpenAIService();

    // ==================== ROUTER ====================
    _router = AppRouter.create(widget.auth, extraRefreshListenable: _localeController);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ==================== AUTH ====================
        ChangeNotifierProvider.value(value: widget.auth),
        ChangeNotifierProvider.value(value: _localeController),

        // ==================== ROLE PROVIDER (Riverpod) ====================
        Provider<RoleNotifier>.value(
          value: RoleNotifier()..loadRoleFromStorage(),
        ),

        // ==================== SERVICES EXISTANTS ====================
        ChangeNotifierProvider(create: (_) => CartService()),
        Provider<NetworkService>.value(value: _networkService),
        ChangeNotifierProxyProvider<NetworkService, FeedProvider>(
          create: (context) => FeedProvider(_networkService),
          update: (context, networkService, previous) =>
              previous ?? FeedProvider(networkService),
        ),
        Provider<EventService>.value(value: _eventService),
        ChangeNotifierProxyProvider<EventService, EventProvider>(
          create: (context) => EventProvider(_eventService),
          update: (context, eventService, previous) =>
              previous ?? EventProvider(eventService),
        ),
        Provider<NewsService>.value(value: _newsService),
        ChangeNotifierProxyProvider<NewsService, NewsProvider>(
          create: (context) => NewsProvider(_newsService),
          update: (context, newsService, previous) =>
              previous ?? NewsProvider(newsService),
        ),
        Provider<NotificationService>.value(value: NotificationService()),
        Provider<NotificationCountersService>.value(value: NotificationCountersService()),
        Provider<ChatRepository>(create: (_) => _chatRepository),

        // ==================== THIX MARKET ====================
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => LiveProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),

        // ==================== THIX MONEY ====================
        Provider<BalanceService>.value(value: _balanceService),
        Provider<TransactionService>.value(value: _transactionService),
        Provider<CardService>.value(value: _cardService),
        Provider<MerchantService>.value(value: _merchantService),
        ChangeNotifierProvider(
          create: (context) => ThixMoneyProvider(
            balanceService: context.read<BalanceService>(),
            transactionService: context.read<TransactionService>(),
          )..loadData(),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionProvider(
            transactionService: context.read<TransactionService>(),
          )..loadAllTransactions(),
        ),
        ChangeNotifierProvider(
          create: (context) => CardProvider(
            cardService: context.read<CardService>(),
          )..loadCard(),
        ),
        ChangeNotifierProvider(
          create: (context) => MerchantProvider(
            merchantService: context.read<MerchantService>(),
          )..loadMerchantStatus(),
        ),

        // ==================== THIX SANTÉ - REPOSITORIES ====================
        Provider<SymptomRepository>.value(value: _symptomRepository),
        Provider<ConstantRepository>.value(value: _constantRepository),
        Provider<MedicationRepository>.value(value: _medicationRepository),
        Provider<AlertRepository>.value(value: _alertRepository),
        Provider<PatientRepository>.value(value: _patientRepository),
        Provider<AppointmentRepository>.value(value: _appointmentRepository),
        Provider<PrescriptionRepository>.value(value: _prescriptionRepository),
        Provider<DrugRepository>.value(value: _drugRepository),
        Provider<DeliveryRepository>.value(value: _deliveryRepository),
        Provider<OpenAIService>.value(value: _openAIService),

        // ==================== THIX SANTÉ - PROVIDERS COMMUNS ====================
        // Note: Les providers Riverpod sont gérés via ProviderScope, pas via MultiProvider
        // Mais on peut ajouter des ChangeNotifier si nécessaire.

        // ==================== THIX SANTÉ - PATIENT PROVIDERS ====================
        ChangeNotifierProvider(
          create: (context) => PatientDashboardNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PatientDataNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),

        // ==================== THIX SANTÉ - DOCTOR PROVIDERS ====================
        ChangeNotifierProvider(
          create: (context) => DoctorDashboardNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DoctorPatientNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DoctorPrescriptionNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),

        // ==================== THIX SANTÉ - PHARMACY PROVIDERS ====================
        ChangeNotifierProvider(
          create: (context) => PharmacyOrderNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PharmacyInventoryNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PharmacyDeliveryNotifier(
            ref: ProviderScope.containerOf(context),
          ),
        ),
      ],
      child: BlocProvider<ChatBloc>.value(
        value: _chatBloc,
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
      ),
    );
  }
}
