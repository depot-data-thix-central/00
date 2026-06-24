// 📁 lib/nav.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thix_id/auth/auth_controller.dart';
import 'package:thix_id/models/app_user.dart';

// ==================== THIX RESERVATION ====================
import 'presentation/thix_reservation/thix_reservation_page.dart';
import 'presentation/thix_reservation/pages/reservation_vols.dart';
import 'presentation/thix_reservation/pages/vol_recherche.dart';
import 'presentation/thix_reservation/pages/vol_liste.dart';
import 'presentation/thix_reservation/pages/vol_details.dart';
import 'presentation/thix_reservation/pages/vol_passagers.dart';
import 'presentation/thix_reservation/pages/vol_paiement.dart';
import 'presentation/thix_reservation/pages/vol_confirmation.dart';
import 'presentation/thix_reservation/pages/reservation_hotels.dart';
import 'presentation/thix_reservation/pages/hotel_recherche.dart';
import 'presentation/thix_reservation/pages/hotel_liste.dart';
import 'presentation/thix_reservation/pages/hotel_details.dart';
import 'presentation/thix_reservation/pages/hotel_reservation.dart';
import 'presentation/thix_reservation/pages/reservation_bus.dart';
import 'presentation/thix_reservation/pages/bus_recherche.dart';
import 'presentation/thix_reservation/pages/bus_liste.dart';
import 'presentation/thix_reservation/pages/bus_reservation.dart';
import 'presentation/thix_reservation/pages/reservation_taxi.dart';
import 'presentation/thix_reservation/pages/taxi_commande.dart';
import 'presentation/thix_reservation/pages/taxi_trajets.dart';
import 'presentation/thix_reservation/pages/reservation_colis.dart';
import 'presentation/thix_reservation/pages/colis_envoi.dart';
import 'presentation/thix_reservation/pages/colis_suivi.dart';
import 'presentation/thix_reservation/pages/reservation_event.dart';
import 'presentation/thix_reservation/pages/reservation_restaurant.dart';
import 'presentation/thix_reservation/pages/mes_reservations.dart';
import 'presentation/thix_reservation/pages/favoris.dart';
import 'presentation/thix_reservation/pages/profil.dart';

// ==================== THIX INFO ====================
import 'package:thix_id/presentation/thix_info/thix_info_home.dart';
import 'package:thix_id/presentation/thix_info/article_detail_page.dart';
import 'package:thix_id/presentation/thix_info/search_page.dart';
import 'package:thix_id/presentation/thix_info/category_articles_page.dart';
import 'package:thix_id/presentation/thix_info/saved_articles_page.dart';
import 'package:thix_id/presentation/thix_info/breaking_news_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_news_dashboard.dart';
import 'package:thix_id/presentation/admin/pages/admin_news_page.dart';
import 'package:thix_id/presentation/admin/pages/create_news_page.dart';

// ==================== IMPORTS EXISTANTS (hors THIX SANTÉ) ====================
import 'presentation/home/home_page.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/personal_registration_page.dart';
import 'presentation/auth/enterprise_registration_page.dart';
import 'presentation/payment/payment_gateway_page.dart';
import 'presentation/payment/activation_receipt_page.dart';
import 'presentation/profile/public_profile_page.dart';
import 'presentation/dashboard/user_dashboard_page.dart';
import 'presentation/enterprise/enterprise_dashboard_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_portal_page.dart';
import 'package:thix_id/presentation/enterprise/enterprise_dashboard_shell_page.dart';
import 'presentation/vault/document_vault_page.dart';
import 'presentation/settings/settings_page.dart';

// ==================== RÉSEAU PRO ====================
import 'presentation/network/network_pro_home.dart';
import 'presentation/network/member_profile.dart';
import 'presentation/network/post_detail_page.dart';
import 'presentation/network/search_network_page.dart';
import 'presentation/network/community_detail_page.dart';
import 'presentation/network/settings_network_page.dart';
import 'presentation/network/blocked_users_page.dart';
import 'presentation/network/network_groups_list.dart';
import 'presentation/network/messages/conversations_list.dart';
import 'presentation/network/messages/chat_screen.dart';
import 'presentation/network/notifications/notifications_page.dart';
import 'presentation/network/connections_list_page.dart';
import 'presentation/network/my_posts_page.dart';
import 'presentation/network/reels_page.dart';
import 'presentation/network/hashtag_page.dart';
import 'presentation/network/saved_posts_page.dart';
import 'presentation/network/reposted_posts_page.dart';
import 'presentation/network/profile_settings_page.dart';
import 'presentation/network/followers_list_page.dart';
import 'presentation/network/following_list_page.dart';
import 'presentation/network/liked_posts_page.dart';
import 'presentation/network/profile_page.dart';

// ==================== THIX SANTÉ (NOUVELLES ROUTES) ====================
// Patient
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_home_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_tracking_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_appointments_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_medical_record_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_messages_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_profile_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_settings_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_family_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_consents_screen.dart';
import 'package:thix_id/presentation/thix_sante/patient/screens/patient_notifications_screen.dart';

// Doctor
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_dashboard_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_patient_list_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_patient_detail_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_prescription_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_teleconsultation_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_teleexpertise_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_schedule_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_messages_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_profile_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_analytics_screen.dart';
import 'package:thix_id/presentation/thix_sante/doctor/screens/doctor_notes_screen.dart';

// Pharmacy
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_dashboard_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_orders_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_inventory_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_delivery_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_prescription_detail_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_messages_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_profile_screen.dart';
import 'package:thix_id/presentation/thix_sante/pharmacy/screens/pharmacy_reports_screen.dart';

// ==================== THIX MONEY (NOUVELLE ARCHITECTURE) ====================
import 'presentation/thix_money/screens/shared/dashboard_screen.dart';
import 'presentation/thix_money/screens/shared/transaction_history_screen.dart';
import 'presentation/thix_money/screens/user/accounts_screen.dart';
import 'presentation/thix_money/screens/user/transfer_screen.dart';
import 'presentation/thix_money/screens/user/split_payment_screen.dart';
import 'presentation/thix_money/screens/user/bill_payment_screen.dart';
import 'presentation/thix_money/screens/user/savings_screen.dart';
import 'presentation/thix_money/screens/user/credit_screen.dart';
import 'presentation/thix_money/screens/user/currency_exchange_screen.dart';
import 'presentation/thix_money/screens/user/tontine_screen.dart';
import 'presentation/thix_money/screens/user/donation_screen.dart';
import 'presentation/thix_money/screens/user/settings_screen.dart';
import 'presentation/thix_money/screens/merchant/merchant_qr_code_screen.dart';

// ==================== THIX ÉVÉNEMENT ====================
import 'package:thix_id/presentation/thix_event/thix_event_home.dart';
import 'package:thix_id/presentation/thix_event/event_detail_page.dart';
import 'package:thix_id/presentation/thix_event/event_search_page.dart';
import 'package:thix_id/presentation/thix_event/event_category_page.dart';
import 'package:thix_id/presentation/thix_event/event_reservation_page.dart';
import 'package:thix_id/presentation/thix_event/my_tickets_page.dart';
import 'package:thix_id/presentation/thix_event/favorite_events_page.dart';
import 'package:thix_id/presentation/thix_event/seat_selection_page.dart';
import 'package:thix_id/presentation/thix_event/waiting_queue_page.dart';

// ==================== THIX MARKET ====================
import 'presentation/thix_market/pages/market_home_page.dart';
import 'presentation/thix_market/pages/search_page.dart';
import 'presentation/thix_market/pages/shops_page.dart';
import 'presentation/thix_market/pages/buy_page.dart';
import 'presentation/thix_market/pages/sell_page.dart';
import 'presentation/thix_market/pages/messages_page.dart';
import 'presentation/thix_market/pages/live_page.dart';
import 'presentation/thix_market/pages/my_activity_page.dart';
import 'presentation/thix_market/pages/market_settings_page.dart';
import 'presentation/thix_market/pages/help_support_page.dart';
import 'presentation/thix_market/pages/product_detail_page.dart';
import 'presentation/thix_market/pages/product_comparator_page.dart';
import 'presentation/thix_market/pages/price_alerts_page.dart';
import 'presentation/thix_market/cart/cart_page.dart';
import 'presentation/thix_market/checkout/checkout_page.dart';
import 'presentation/thix_market/pages/order_history_page.dart';
import 'presentation/thix_market/pages/order_detail_page.dart';
import 'presentation/thix_market/pages/create_shop_page.dart';
import 'presentation/thix_market/pages/manage_shop_page.dart';
import 'presentation/thix_market/pages/shop_statistics_page.dart';
import 'presentation/thix_market/pages/publish_announcement_page.dart';
import 'presentation/thix_market/pages/edit_announcement_page.dart';
import 'presentation/thix_market/pages/live_stream_page.dart';
import 'presentation/thix_market/pages/create_live_page.dart';
import 'presentation/thix_market/pages/live_replay_page.dart';
import 'presentation/thix_market/pages/auction_page.dart';
import 'presentation/thix_market/pages/chat_page.dart';
import 'presentation/thix_market/pages/dispute_detail_page.dart';
import 'presentation/thix_market/pages/notification_page.dart';

// ==================== AUTRES SERVICES ====================
import 'presentation/jobs/jobs_page.dart';
import 'package:thix_id/presentation/jobs/job_apply_page.dart';
import 'package:thix_id/presentation/jobs/job_details_page.dart';
import 'package:thix_id/presentation/jobs/job_dashboard_page.dart';
import 'package:thix_id/presentation/recruiter/recruiter_portal_page.dart';
import 'package:thix_id/presentation/opportunities/opportunities_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_apply_page.dart';
import 'package:thix_id/presentation/opportunities/opportunity_details_page.dart';
import 'presentation/education/education_page.dart';
import 'package:thix_id/presentation/training/training_home_page.dart';
import 'package:thix_id/presentation/training/training_details_page.dart';
import 'package:thix_id/presentation/training/learning_dashboard_page.dart';
import 'package:thix_id/presentation/training/lesson_player_page.dart';
import 'package:thix_id/presentation/admin/admin_page.dart';
import 'package:thix_id/presentation/admin/admin_routes.dart';
import 'package:thix_id/presentation/thix_media/thix_media_page.dart';
import 'package:thix_id/presentation/admin/pages/admin_media_page.dart';

// ==================== CHAT ====================
import 'package:thix_id/presentation/chat/home_page.dart' as new_chat;
import 'package:thix_id/presentation/chat/conversation_page.dart' as new_chat_conv;
import 'package:thix_id/presentation/chat/ephemeral/ephemeral_settings.dart';
import 'package:thix_id/presentation/chat/translation/auto_translate_settings.dart';
import 'package:thix_id/presentation/chat/themes/theme_selector_sheet.dart';
import 'package:thix_id/presentation/chat/themes/bubble_customizer.dart';
import 'package:thix_id/presentation/chat/themes/notification_sounds_settings.dart';
import 'package:thix_id/presentation/chat/themes/chat_wallpaper_picker.dart';
import 'package:thix_id/presentation/chat/themes/font_size_selector.dart';
import 'package:thix_id/presentation/chat/themes/theme_preview.dart';
import 'package:thix_id/presentation/chat/online_status/last_seen_settings.dart';
import 'package:thix_id/presentation/chat/online_status/availability_schedule.dart';
import 'package:thix_id/presentation/chat/online_status/status_presets.dart';
import 'package:thix_id/presentation/chat/archive/archive_page.dart';
import 'package:thix_id/presentation/chat/archive/export_chat_page.dart';
import 'package:thix_id/presentation/chat/data_saver/low_data_mode_toggle.dart';
import 'package:thix_id/presentation/chat/home_widgets/chat_widget_config.dart';
import 'package:thix_id/presentation/chat/home_widgets/widget_preview.dart';
import 'package:thix_id/presentation/chat/audio_video/outgoing_call_screen.dart';
import 'package:thix_id/presentation/chat/audio_video/incoming_call_screen.dart';
import 'package:thix_id/presentation/chat/chat_status_page.dart';
import 'package:thix_id/presentation/chat/chat_status_update.dart';
import 'package:thix_id/presentation/chat/chat_spaces_page.dart';

/// Enveloppe un widget dans une page avec AppBar (pour les widgets qui ne sont pas des pages complètes)
Widget _wrapPage(Widget child, String title) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: child,
  );
}

/// Page sans transition (pour GoRouter)
class NoTransitionPage<T> extends Page<T> {
  final Widget child;
  const NoTransitionPage({required this.child, super.key});

  @override
  Route<T> createRoute(BuildContext context) {
    return MaterialPageRoute(builder: (context) => child, settings: this);
  }
}

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String personalReg = '/personal-reg';
  static const String enterpriseReg = '/enterprise-reg';
  static const String enterprise = '/enterprise';
  static const String payment = '/payment';
  static const String activationReceipt = '/activation-receipt';
  static const String publicProfile = '/public-profile';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  static const String enterprisePortalBasePath = '/company';
  static const String chat = '/chat';
  static const String vault = '/vault';
  static const String settings = '/settings';
  
  // ==================== THIX CHAT (routes) ====================
  static const String chatConversation = '/chat/conversation/:id';
  static const String ephemeralSettings = '/chat/ephemeral/settings';
  static const String translationSettings = '/chat/translation/settings';
  static const String chatThemes = '/chat/themes';
  static const String bubbleCustomizer = '/chat/bubble/customize';
  static const String notificationSounds = '/chat/notification/sounds';
  static const String chatWallpaper = '/chat/wallpaper';
  static const String fontSize = '/chat/font/size';
  static const String themePreview = '/chat/theme/preview';
  static const String statusSettings = '/chat/status/settings';
  static const String availabilitySchedule = '/chat/availability/schedule';
  static const String statusPresets = '/chat/status/presets';
  static const String chatArchive = '/chat/archive';
  static const String exportChat = '/chat/export/:id';
  static const String dataSaver = '/chat/data/saver';
  static const String widgetsConfig = '/chat/widgets/config';
  static const String widgetsPreview = '/chat/widgets/preview';
  static const String chatCall = '/chat/call';
  static const String chatIncomingCall = '/chat/incoming';
  static const String chatStatus = '/chat/status';
  static const String chatStatusUpdate = '/chat/status/update';
  static const String chatSpaces = '/chat/spaces';
  
  // ==================== RÉSEAU PRO ====================
  static const String networkPro = '/network-pro';
  static const String networkProfile = '/network/profile/:userId';
  static const String networkPost = '/network/post/:postId';
  static const String networkSearch = '/network/search';
  static const String networkCommunity = '/network/community/:communityId';
  static const String networkSettings = '/network/settings';
  static const String networkBlocked = '/network/blocked';
  static const String networkGroups = '/network/groups';
  static const String networkMessages = '/network/messages';
  static const String networkChat = '/network/chat/:userId';
  static const String networkNotifications = '/network/notifications';
  static const String networkConnections = '/network/connections';
  static const String networkMyPosts = '/network/my-posts';
  static const String networkReels = '/network/reels';
  static const String networkHashtag = '/hashtag/:tag';
  static const String networkSaved = '/network/saved';
  static const String networkReposted = '/network/reposted';
  static const String networkProfileSettings = '/network/profile-settings';
  static const String networkFollowers = '/network/followers/:userId';
  static const String networkFollowing = '/network/following/:userId';
  static const String networkLiked = '/network/liked';
  static const String networkProfilePage = '/network/profile-page/:userId';
  
  // ==================== THIX SANTÉ (NOUVELLES ROUTES) ====================
  // Patient
  static const String patientHome = '/patient';
  static const String patientTracking = '/patient/tracking';
  static const String patientAppointments = '/patient/appointments';
  static const String patientMedicalRecord = '/patient/medical-record';
  static const String patientMessages = '/patient/messages';
  static const String patientProfile = '/patient/profile';
  static const String patientSettings = '/patient/settings';
  static const String patientFamily = '/patient/family';
  static const String patientConsents = '/patient/consents';
  static const String patientNotifications = '/patient/notifications';

  // Doctor
  static const String doctorHome = '/doctor';
  static const String doctorPatients = '/doctor/patients';
  static const String doctorPatientDetail = '/doctor/patient/:id';
  static const String doctorPrescription = '/doctor/prescription';
  static const String doctorTeleconsultation = '/doctor/teleconsultation';
  static const String doctorTeleexpertise = '/doctor/teleexpertise';
  static const String doctorSchedule = '/doctor/schedule';
  static const String doctorMessages = '/doctor/messages';
  static const String doctorProfile = '/doctor/profile';
  static const String doctorAnalytics = '/doctor/analytics';
  static const String doctorNotes = '/doctor/notes';

  // Pharmacy
  static const String pharmacyHome = '/pharmacy';
  static const String pharmacyOrders = '/pharmacy/orders';
  static const String pharmacyInventory = '/pharmacy/inventory';
  static const String pharmacyDelivery = '/pharmacy/delivery';
  static const String pharmacyPrescriptionDetail = '/pharmacy/prescription/:id';
  static const String pharmacyMessages = '/pharmacy/messages';
  static const String pharmacyProfile = '/pharmacy/profile';
  static const String pharmacyReports = '/pharmacy/reports';
  
  // ==================== THIX MONEY ====================
  static const String thixMoney = '/thix-money';
  static const String thixMoneyTransactions = '/thix-money/transactions';
  static const String thixMoneyScanner = '/thix-money/scanner';
  static const String thixMoneyServices = '/thix-money/services';
  static const String thixMoneyProfile = '/thix-money/profile';
  static const String thixMoneyTransfer = '/thix-money/transfer';
  static const String thixMoneyWithdraw = '/thix-money/withdraw';
  static const String thixMoneyDeposit = '/thix-money/deposit';
  static const String thixMoneyCredit = '/thix-money/credit';
  static const String thixMoneyCreditRequest = '/thix-money/credit/request';
  static const String thixMoneySavings = '/thix-money/savings';
  static const String thixMoneyGroupSavings = '/thix-money/group-savings';
  static const String thixMoneyTontine = '/thix-money/tontine';
  static const String thixMoneyCreateTontine = '/thix-money/tontine/create';
  static const String thixMoneyTontineDetails = '/thix-money/tontine/:tontineId';
  static const String thixMoneyInvestment = '/thix-money/investment';
  static const String thixMoneyInvestmentDetails = '/thix-money/investment/:investmentId';
  static const String thixMoneyInsurance = '/thix-money/insurance';
  static const String thixMoneyInternationalTransfer = '/thix-money/international-transfer';
  static const String thixMoneyCards = '/thix-money/cards';
  static const String thixMoneyNotifications = '/thix-money/notifications';
  static const String thixMoneyHistory = '/thix-money/history';

  // ==================== THIX RESERVATION ====================
  static const String reservation = '/reservation';
  static const String reservationVols = '/reservation/vols';
  static const String reservationVolsRecherche = '/reservation/vols/recherche';
  static const String reservationVolsListe = '/reservation/vols/liste';
  static const String reservationVolsDetails = '/reservation/vols/details';
  static const String reservationVolsPassagers = '/reservation/vols/passagers';
  static const String reservationVolsPaiement = '/reservation/vols/paiement';
  static const String reservationVolsConfirmation = '/reservation/vols/confirmation';
  static const String reservationHotels = '/reservation/hotels';
  static const String reservationHotelsRecherche = '/reservation/hotels/recherche';
  static const String reservationHotelsListe = '/reservation/hotels/liste';
  static const String reservationHotelsDetails = '/reservation/hotels/details';
  static const String reservationHotelsReservation = '/reservation/hotels/reservation';
  static const String reservationBus = '/reservation/bus';
  static const String reservationBusRecherche = '/reservation/bus/recherche';
  static const String reservationBusListe = '/reservation/bus/liste';
  static const String reservationBusReservation = '/reservation/bus/reservation';
  static const String reservationTaxi = '/reservation/taxi';
  static const String reservationTaxiCommande = '/reservation/taxi/commande';
  static const String reservationTaxiTrajets = '/reservation/taxi/trajets';
  static const String reservationColis = '/reservation/colis';
  static const String reservationColisEnvoi = '/reservation/colis/envoi';
  static const String reservationColisSuivi = '/reservation/colis/suivi';
  static const String reservationEvent = '/reservation/event';
  static const String reservationRestaurant = '/reservation/restaurant';
  static const String reservationMesReservations = '/reservation/mes-reservations';
  static const String reservationFavoris = '/reservation/favoris';
  static const String reservationProfil = '/reservation/profil';
  
  // ==================== THIX ÉVÉNEMENT ====================
  static const String thixEvent = '/thix-event';
  static const String thixEventDetail = '/thix-event/event/:eventId';
  static const String thixEventSearch = '/thix-event/search';
  static const String thixEventCategory = '/thix-event/category/:category';
  static const String thixEventReservation = '/thix-event/reservation/:eventId';
  static const String thixEventMyTickets = '/thix-event/my-tickets';
  static const String thixEventFavorites = '/thix-event/favorites';
  static const String thixEventSeatSelection = '/thix-event/seat-selection/:eventId';
  static const String thixEventWaitingQueue = '/thix-event/waiting-queue/:eventId';
  
  // ==================== THIX INFO ====================
  static const String thixInfo = '/thix-info';
  static const String thixInfoArticle = '/thix-info/article/:articleId';
  static const String thixInfoSearch = '/thix-info/search';
  static const String thixInfoCategory = '/thix-info/category/:category';
  static const String thixInfoSaved = '/thix-info/saved';
  static const String thixInfoBreaking = '/thix-info/breaking';
  static const String thixInfoAdmin = '/thix-info/admin';
  static const String thixInfoCreate = '/thix-info/admin/create';
  static const String thixInfoEdit = '/thix-info/admin/edit/:articleId';

  // ==================== THIX MARKET ====================
  static const String thixMarket = '/market';
  static const String thixMarketHome = '/market/home';
  static const String thixMarketSearch = '/market/search';
  static const String thixMarketShops = '/market/shops';
  static const String thixMarketBuy = '/market/buy';
  static const String thixMarketSell = '/market/sell';
  static const String thixMarketMessages = '/market/messages';
  static const String thixMarketLive = '/market/live';
  static const String thixMarketActivity = '/market/activity';
  static const String thixMarketSettings = '/market/settings';
  static const String thixMarketHelp = '/market/help';
  static const String thixMarketProductDetail = '/market/product/:productId';
  static const String thixMarketProductComparator = '/market/compare';
  static const String thixMarketPriceAlerts = '/market/price-alerts';
  static const String thixMarketCart = '/market/cart';
  static const String thixMarketCheckout = '/market/checkout';
  static const String thixMarketOrders = '/market/orders';
  static const String thixMarketOrderDetail = '/market/order/:orderId';
  static const String thixMarketCreateShop = '/market/shop/create';
  static const String thixMarketManageShop = '/market/shop/:shopId/manage';
  static const String thixMarketShopStats = '/market/shop/:shopId/stats';
  static const String thixMarketPublishAnnouncement = '/market/announcement/publish';
  static const String thixMarketEditAnnouncement = '/market/announcement/:announcementId/edit';
  static const String thixMarketLiveStream = '/market/live/:liveId';
  static const String thixMarketCreateLive = '/market/live/create';
  static const String thixMarketLiveReplay = '/market/live/:liveId/replay';
  static const String thixMarketAuction = '/market/auction/:auctionId';
  static const String thixMarketChat = '/market/chat/:conversationId';
  static const String thixMarketDispute = '/market/dispute/:disputeId';
  static const String thixMarketNotifications = '/market/notifications';
  
  // ==================== AUTRES SERVICES ====================
  static const String jobs = '/jobs';
  static const String jobDashboard = '/jobs/dashboard';
  static const String recruiter = '/recruiter';
  static const String opportunities = '/opportunities';
  static const String events = '/events';
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String trainingDetails = '/training/:trainingId';
  static const String learningDashboard = '/learn';
  static const String lessonPlayer = '/lesson/:enrollmentId';
  static const String admin = '/admin';
  static const String thixMedia = '/thix-media';
  static const String adminMedia = '/admin/media';
  
  // ==================== MESSAGES & PROFIL PRINCIPAUX ====================
  static const String messages = '/messages';
  static const String profile = '/profile';
  
  static String enterprisePortalBase(String slug) => '$enterprisePortalBasePath/$slug';
  static String enterprisePortalDashboard(String slug, String section) => '/company/$slug/dashboard/$section';
}

class AppRouter {
  static GoRouter create(AuthController auth, {Listenable? extraRefreshListenable}) {
    final refresh = extraRefreshListenable ?? auth;
    return GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: refresh,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isLoggedIn = auth.isAuthenticated;
        final isAuthPage = location == AppRoutes.login ||
            location == AppRoutes.personalReg ||
            location == AppRoutes.enterpriseReg;
        final isAdmin = location == AppRoutes.admin || location.startsWith('${AppRoutes.admin}/');
        final isThixInfoAdmin = location == AppRoutes.thixInfoAdmin || location.startsWith('${AppRoutes.thixInfoAdmin}/');
        final isEnterprisePortal = location.startsWith('${AppRoutes.enterprisePortalBasePath}/') ||
            location == AppRoutes.enterprisePortalBasePath;
        final isPublic = location == AppRoutes.home ||
            location == AppRoutes.publicProfile ||
            location == AppRoutes.jobs ||
            location == AppRoutes.opportunities ||
            location == AppRoutes.education ||
            location == AppRoutes.trainingHome ||
            location.startsWith('/training/') ||
            location.startsWith('/reservation') ||
            location.startsWith('/thix-info/') ||
            location.startsWith('/thix-event/') ||
            location.startsWith('/hashtag/');

        final isProtected = !isPublic && !isAuthPage;
        if (!isLoggedIn && isProtected) return AppRoutes.login;

        if ((isAdmin || isThixInfoAdmin) && !isLoggedIn) return AppRoutes.login;

        if (isLoggedIn) {
          final u = auth.currentUser;
          final isActivated = (u?.hasRealThixId ?? false);
          final hasActiveTrial = (u?.hasActiveTrial ?? false);
          final isPaymentOrReceipt = location == AppRoutes.payment || location == AppRoutes.activationReceipt;
          final isDashboard = location == AppRoutes.userDashboard || location == AppRoutes.enterpriseDashboard;
          if (!isActivated && !hasActiveTrial && !isAuthPage && !isPublic && !isPaymentOrReceipt && !isDashboard) {
            final receiptReturn = Uri.encodeComponent(AppRoutes.activationReceipt);
            return '${AppRoutes.payment}?returnTo=$receiptReturn';
          }
        }

        if (isLoggedIn) {
          final t = auth.currentUser?.accountType;
          if (location == AppRoutes.userDashboard && t == AccountType.enterprise) return AppRoutes.enterpriseDashboard;
          if (location == AppRoutes.enterpriseDashboard && t == AccountType.personal) return AppRoutes.userDashboard;
        }

        if (isLoggedIn && isAuthPage) {
          final t = auth.currentUser?.accountType;
          return t == AccountType.enterprise ? AppRoutes.enterpriseDashboard : AppRoutes.userDashboard;
        }

        if (isEnterprisePortal) return null;
        return null;
      },
      routes: [
        // ==================== PAGE D'ACCUEIL ====================
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          pageBuilder: (context, state) => NoTransitionPage(child: HomePagePremium()),
        ),

        // ==================== AUTHENTIFICATION ====================
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          pageBuilder: (context, state) => NoTransitionPage(child: LoginPage()),
        ),
        GoRoute(
          path: AppRoutes.personalReg,
          name: 'personalReg',
          pageBuilder: (context, state) {
            final stepStr = state.uri.queryParameters['step'];
            final step = int.tryParse(stepStr ?? '') ?? 1;
            return NoTransitionPage(child: PersonalRegistrationPage(initialStep: step));
          },
        ),
        GoRoute(
          path: AppRoutes.enterpriseReg,
          name: 'enterpriseReg',
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseRegistrationPage()),
        ),
        GoRoute(
          path: AppRoutes.payment,
          name: 'payment',
          pageBuilder: (context, state) {
            final returnTo = state.uri.queryParameters['returnTo'];
            return NoTransitionPage(child: PaymentGatewayPage(returnTo: returnTo));
          },
        ),
        GoRoute(
          path: AppRoutes.activationReceipt,
          name: 'activationReceipt',
          pageBuilder: (context, state) {
            final qp = state.uri.queryParameters;
            final paidAt = DateTime.tryParse((qp['paidAt'] ?? '').trim());
            return NoTransitionPage(
              child: ActivationReceiptPage(
                txRef: qp['txRef'],
                method: qp['method'],
                amount: qp['amount'],
                currency: qp['currency'],
                paidAt: paidAt,
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.publicProfile,
          name: 'publicProfile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: PublicProfilePage(initialThixId: state.uri.queryParameters['thixId']),
          ),
        ),
        GoRoute(
          path: AppRoutes.userDashboard,
          name: 'userDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: UserDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.enterpriseDashboard,
          name: 'enterpriseDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: EnterpriseDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.enterprise,
          name: 'enterpriseEntry',
          redirect: (context, state) {
            final isLoggedIn = auth.isAuthenticated;
            if (!isLoggedIn) return AppRoutes.login;
            final t = auth.currentUser?.accountType;
            if (t == AccountType.enterprise) return AppRoutes.enterpriseDashboard;
            return AppRoutes.enterpriseReg;
          },
        ),
        GoRoute(
          path: '/entreprise/:slug',
          name: 'enterprisePortalAliasFr',
          redirect: (context, state) {
            final slug = (state.pathParameters['slug'] ?? '').trim();
            return '${AppRoutes.enterprisePortalBase(slug)}/dashboard/overview';
          },
        ),
        GoRoute(
          path: '${AppRoutes.enterprisePortalBasePath}/:slug',
          name: 'enterprisePortal',
          pageBuilder: (context, state) {
            final slug = (state.pathParameters['slug'] ?? '').trim();
            return NoTransitionPage(child: EnterprisePortalPage(companySlug: slug));
          },
          routes: [
            GoRoute(
              path: 'dashboard/:section',
              name: 'enterprisePortalDashboard',
              pageBuilder: (context, state) {
                final slug = (state.pathParameters['slug'] ?? '').trim();
                final section = (state.pathParameters['section'] ?? 'overview').trim();
                return NoTransitionPage(child: EnterpriseDashboardShellPage(companySlug: slug, section: section));
              },
            ),
            GoRoute(
              path: 'dashboard',
              name: 'enterprisePortalDashboardRoot',
              redirect: (context, state) {
                final slug = (state.pathParameters['slug'] ?? '').trim();
                return '${AppRoutes.enterprisePortalBase(slug)}/dashboard/overview';
              },
            ),
          ],
        ),
        
        // ==================== CHAT ====================
        GoRoute(
          path: AppRoutes.chat,
          name: 'chat',
          pageBuilder: (context, state) => NoTransitionPage(child: const new_chat.ChatHomePage()),
        ),
        GoRoute(
          path: AppRoutes.chatConversation,
          name: 'chatConversation',
          pageBuilder: (context, state) {
            final conversationId = state.pathParameters['id']!;
            return NoTransitionPage(child: new_chat_conv.ConversationPage(conversationId: conversationId));
          },
        ),
        GoRoute(
          path: AppRoutes.ephemeralSettings,
          name: 'ephemeralSettings',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const EphemeralSettings(onDurationSelected: null), 'Messages éphémères'),
          ),
        ),
        GoRoute(
          path: AppRoutes.translationSettings,
          name: 'translationSettings',
          pageBuilder: (context, state) => NoTransitionPage(child: const AutoTranslateSettings()),
        ),
        GoRoute(
          path: AppRoutes.chatThemes,
          name: 'chatThemes',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const ThemeSelectorSheet(), 'Thèmes'),
          ),
        ),
        GoRoute(
          path: AppRoutes.bubbleCustomizer,
          name: 'bubbleCustomizer',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const BubbleCustomizer(), 'Personnalisation des bulles'),
          ),
        ),
        GoRoute(
          path: AppRoutes.notificationSounds,
          name: 'notificationSounds',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const NotificationSoundsSettings(), 'Sons de notification'),
          ),
        ),
        GoRoute(
          path: AppRoutes.chatWallpaper,
          name: 'chatWallpaper',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const ChatWallpaperPicker(), 'Fond d\'écran'),
          ),
        ),
        GoRoute(
          path: AppRoutes.fontSize,
          name: 'fontSize',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const FontSizeSelector(), 'Taille de police'),
          ),
        ),
        GoRoute(
          path: AppRoutes.themePreview,
          name: 'themePreview',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const ThemePreview(), 'Aperçu du thème'),
          ),
        ),
        GoRoute(
          path: AppRoutes.statusSettings,
          name: 'statusSettings',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const LastSeenSettings(), 'Dernière activité'),
          ),
        ),
        GoRoute(
          path: AppRoutes.availabilitySchedule,
          name: 'availabilitySchedule',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const AvailabilitySchedule(), 'Planification de disponibilité'),
          ),
        ),
        GoRoute(
          path: AppRoutes.statusPresets,
          name: 'statusPresets',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const StatusPresets(), 'Préréglages de statut'),
          ),
        ),
        GoRoute(
          path: AppRoutes.chatArchive,
          name: 'chatArchive',
          pageBuilder: (context, state) => NoTransitionPage(child: const ArchivePage()),
        ),
        GoRoute(
          path: AppRoutes.exportChat,
          name: 'exportChat',
          pageBuilder: (context, state) {
            final conversationId = state.pathParameters['id']!;
            final conversationName = state.uri.queryParameters['name'] ?? 'Conversation';
            return NoTransitionPage(
              child: ExportChatPage(conversationId: conversationId, conversationName: conversationName),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.dataSaver,
          name: 'dataSaver',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const LowDataModeToggle(), 'Économie de données'),
          ),
        ),
        GoRoute(
          path: AppRoutes.widgetsConfig,
          name: 'widgetsConfig',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const ChatWidgetConfig(), 'Configuration des widgets'),
          ),
        ),
        GoRoute(
          path: AppRoutes.widgetsPreview,
          name: 'widgetsPreview',
          pageBuilder: (context, state) => NoTransitionPage(
            child: _wrapPage(const WidgetPreview(), 'Aperçu des widgets'),
          ),
        ),
        GoRoute(
          path: AppRoutes.chatCall,
          name: 'chatCall',
          pageBuilder: (context, state) => NoTransitionPage(child: const OutgoingCallScreen(
            calleeName: 'Appel sortant',
            calleeAvatarUrl: null,
            isVideoCall: false,
            onCancel: null,
          )),
        ),
        GoRoute(
          path: AppRoutes.chatIncomingCall,
          name: 'chatIncomingCall',
          pageBuilder: (context, state) => NoTransitionPage(child: const IncomingCallScreen(
            callerName: 'Appel entrant',
            callerAvatarUrl: null,
            isVideoCall: false,
            onAccept: null,
            onDecline: null,
          )),
        ),
        GoRoute(
          path: AppRoutes.chatStatus,
          name: 'chatStatus',
          pageBuilder: (context, state) => NoTransitionPage(child: const ChatStatusPage()),
        ),
        GoRoute(
          path: AppRoutes.chatStatusUpdate,
          name: 'chatStatusUpdate',
          pageBuilder: (context, state) => NoTransitionPage(child: const ChatStatusUpdatePage()),
        ),
        GoRoute(
          path: AppRoutes.chatSpaces,
          name: 'chatSpaces',
          pageBuilder: (context, state) => NoTransitionPage(child: const ChatSpacesPage()),
        ),

        // ==================== MESSAGES & PROFIL PRINCIPAUX ====================
        GoRoute(
          path: AppRoutes.messages,
          name: 'messages',
          pageBuilder: (context, state) => NoTransitionPage(child: const new_chat.ChatHomePage()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: 'profile',
          pageBuilder: (context, state) => NoTransitionPage(child: UserDashboardPage()),
        ),
        
        // ==================== AUTRES ROUTES ====================
        GoRoute(
          path: AppRoutes.vault,
          name: 'vault',
          pageBuilder: (context, state) => NoTransitionPage(child: DocumentVaultPage()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          pageBuilder: (context, state) => NoTransitionPage(child: SettingsPage()),
        ),
        
        // ==================== RÉSEAU PRO ====================
        GoRoute(
          path: AppRoutes.networkPro,
          name: 'network-pro',
          pageBuilder: (context, state) => NoTransitionPage(child: const NetworkProHome()),
        ),
        GoRoute(
          path: AppRoutes.networkProfile,
          name: 'network-profile',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return NoTransitionPage(child: MemberProfile(userId: userId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkPost,
          name: 'network-post',
          pageBuilder: (context, state) {
            final postId = state.pathParameters['postId']!;
            return NoTransitionPage(child: PostDetailPage(postId: postId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkSearch,
          name: 'network-search',
          pageBuilder: (context, state) => NoTransitionPage(child: const SearchNetworkPage()),
        ),
        GoRoute(
          path: AppRoutes.networkCommunity,
          name: 'network-community',
          pageBuilder: (context, state) {
            final communityId = state.pathParameters['communityId']!;
            return NoTransitionPage(child: CommunityDetailPage(communityId: communityId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkSettings,
          name: 'network-settings',
          pageBuilder: (context, state) => NoTransitionPage(child: const SettingsNetworkPage()),
        ),
        GoRoute(
          path: AppRoutes.networkBlocked,
          name: 'network-blocked',
          pageBuilder: (context, state) => NoTransitionPage(child: const BlockedUsersPage()),
        ),
        GoRoute(
          path: AppRoutes.networkGroups,
          name: 'network-groups',
          pageBuilder: (context, state) => NoTransitionPage(child: const NetworkGroupsList()),
        ),
        GoRoute(
          path: AppRoutes.networkMessages,
          name: 'network-messages',
          pageBuilder: (context, state) => NoTransitionPage(child: const ConversationsList()),
        ),
        GoRoute(
          path: AppRoutes.networkChat,
          name: 'network-chat',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final userName = state.extra as String? ?? '';
            return NoTransitionPage(child: ChatScreen(userId: userId, userName: userName));
          },
        ),
        GoRoute(
          path: AppRoutes.networkNotifications,
          name: 'network-notifications',
          pageBuilder: (context, state) => NoTransitionPage(child: const NotificationsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkConnections,
          name: 'network-connections',
          pageBuilder: (context, state) => NoTransitionPage(child: const ConnectionsListPage()),
        ),
        GoRoute(
          path: AppRoutes.networkMyPosts,
          name: 'network-my-posts',
          pageBuilder: (context, state) => NoTransitionPage(child: const MyPostsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkReels,
          name: 'network-reels',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReelsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkHashtag,
          name: 'network-hashtag',
          pageBuilder: (context, state) {
            final tag = state.pathParameters['tag']!;
            return NoTransitionPage(child: HashtagPage(tag: tag));
          },
        ),
        GoRoute(
          path: AppRoutes.networkSaved,
          name: 'network-saved',
          pageBuilder: (context, state) => NoTransitionPage(child: const SavedPostsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkReposted,
          name: 'network-reposted',
          pageBuilder: (context, state) => NoTransitionPage(child: const RepostedPostsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkProfileSettings,
          name: 'network-profile-settings',
          pageBuilder: (context, state) => NoTransitionPage(child: const ProfileSettingsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkFollowers,
          name: 'network-followers',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return NoTransitionPage(child: FollowersListPage(userId: userId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkFollowing,
          name: 'network-following',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return NoTransitionPage(child: FollowingListPage(userId: userId));
          },
        ),
        GoRoute(
          path: AppRoutes.networkLiked,
          name: 'network-liked',
          pageBuilder: (context, state) => NoTransitionPage(child: const LikedPostsPage()),
        ),
        GoRoute(
          path: AppRoutes.networkProfilePage,
          name: 'network-profile-page',
          pageBuilder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return NoTransitionPage(child: ProfilePage(userId: userId));
          },
        ),
        
        // ==================== THIX ÉVÉNEMENT ====================
        GoRoute(
          path: AppRoutes.thixEvent,
          name: 'thixEvent',
          pageBuilder: (context, state) => NoTransitionPage(child: const ThixEventHome()),
        ),
        GoRoute(
          path: AppRoutes.thixEventDetail,
          name: 'thixEventDetail',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            return NoTransitionPage(child: EventDetailPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: AppRoutes.thixEventSearch,
          name: 'thixEventSearch',
          pageBuilder: (context, state) => NoTransitionPage(child: const EventSearchPage()),
        ),
        GoRoute(
          path: AppRoutes.thixEventCategory,
          name: 'thixEventCategory',
          pageBuilder: (context, state) {
            final category = state.pathParameters['category']!;
            return NoTransitionPage(child: EventCategoryPage(category: category));
          },
        ),
        GoRoute(
          path: AppRoutes.thixEventReservation,
          name: 'thixEventReservation',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final quantity = int.tryParse(state.uri.queryParameters['quantity'] ?? '1') ?? 1;
            return NoTransitionPage(child: EventReservationPage(eventId: eventId, quantity: quantity));
          },
        ),
        GoRoute(
          path: AppRoutes.thixEventMyTickets,
          name: 'thixEventMyTickets',
          pageBuilder: (context, state) => NoTransitionPage(child: const MyTicketsPage()),
        ),
        GoRoute(
          path: AppRoutes.thixEventFavorites,
          name: 'thixEventFavorites',
          pageBuilder: (context, state) => NoTransitionPage(child: const FavoriteEventsPage()),
        ),
        GoRoute(
          path: AppRoutes.thixEventSeatSelection,
          name: 'thixEventSeatSelection',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            return NoTransitionPage(child: SeatSelectionPage(eventId: eventId));
          },
        ),
        GoRoute(
          path: AppRoutes.thixEventWaitingQueue,
          name: 'thixEventWaitingQueue',
          pageBuilder: (context, state) {
            final eventId = state.pathParameters['eventId']!;
            final quantity = int.tryParse(state.uri.queryParameters['quantity'] ?? '1') ?? 1;
            return NoTransitionPage(child: WaitingQueuePage(eventId: eventId, requestedQuantity: quantity));
          },
        ),

        // ==================== THIX SANTÉ (NOUVELLES ROUTES) ====================
        // Patient
        GoRoute(
          path: AppRoutes.patientHome,
          name: 'patientHome',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientHomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientTracking,
          name: 'patientTracking',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientTrackingScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientAppointments,
          name: 'patientAppointments',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientAppointmentsScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientMedicalRecord,
          name: 'patientMedicalRecord',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientMedicalRecordScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientMessages,
          name: 'patientMessages',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientMessagesScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientProfile,
          name: 'patientProfile',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientSettings,
          name: 'patientSettings',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientSettingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientFamily,
          name: 'patientFamily',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientFamilyScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientConsents,
          name: 'patientConsents',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientConsentsScreen()),
        ),
        GoRoute(
          path: AppRoutes.patientNotifications,
          name: 'patientNotifications',
          pageBuilder: (context, state) => NoTransitionPage(child: const PatientNotificationsScreen()),
        ),

        // Doctor
        GoRoute(
          path: AppRoutes.doctorHome,
          name: 'doctorHome',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorDashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorPatients,
          name: 'doctorPatients',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorPatientListScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorPatientDetail,
          name: 'doctorPatientDetail',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return NoTransitionPage(child: DoctorPatientDetailScreen(patientId: id));
          },
        ),
        GoRoute(
          path: AppRoutes.doctorPrescription,
          name: 'doctorPrescription',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorPrescriptionScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorTeleconsultation,
          name: 'doctorTeleconsultation',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorTeleconsultationScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorTeleexpertise,
          name: 'doctorTeleexpertise',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorTeleexpertiseScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorSchedule,
          name: 'doctorSchedule',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorScheduleScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorMessages,
          name: 'doctorMessages',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorMessagesScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorProfile,
          name: 'doctorProfile',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorAnalytics,
          name: 'doctorAnalytics',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorAnalyticsScreen()),
        ),
        GoRoute(
          path: AppRoutes.doctorNotes,
          name: 'doctorNotes',
          pageBuilder: (context, state) => NoTransitionPage(child: const DoctorNotesScreen()),
        ),

        // Pharmacy
        GoRoute(
          path: AppRoutes.pharmacyHome,
          name: 'pharmacyHome',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyDashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyOrders,
          name: 'pharmacyOrders',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyOrdersScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyInventory,
          name: 'pharmacyInventory',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyInventoryScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyDelivery,
          name: 'pharmacyDelivery',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyDeliveryScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyPrescriptionDetail,
          name: 'pharmacyPrescriptionDetail',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return NoTransitionPage(child: PharmacyPrescriptionDetailScreen(prescriptionId: id));
          },
        ),
        GoRoute(
          path: AppRoutes.pharmacyMessages,
          name: 'pharmacyMessages',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyMessagesScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyProfile,
          name: 'pharmacyProfile',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyProfileScreen()),
        ),
        GoRoute(
          path: AppRoutes.pharmacyReports,
          name: 'pharmacyReports',
          pageBuilder: (context, state) => NoTransitionPage(child: const PharmacyReportsScreen()),
        ),

        // ==================== THIX MONEY (NOUVELLE ARCHITECTURE) ====================
        GoRoute(
          path: AppRoutes.thixMoney,
          name: 'thixMoney',
          pageBuilder: (context, state) => NoTransitionPage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyTransactions,
          name: 'thixMoneyTransactions',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransactionHistoryScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyScanner,
          name: 'thixMoneyScanner',
          pageBuilder: (context, state) => NoTransitionPage(child: const MerchantQrCodeScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyServices,
          name: 'thixMoneyServices',
          pageBuilder: (context, state) => NoTransitionPage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyProfile,
          name: 'thixMoneyProfile',
          pageBuilder: (context, state) => NoTransitionPage(child: const SettingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyTransfer,
          name: 'thixMoneyTransfer',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransferScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyWithdraw,
          name: 'thixMoneyWithdraw',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransferScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyDeposit,
          name: 'thixMoneyDeposit',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransferScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyCredit,
          name: 'thixMoneyCredit',
          pageBuilder: (context, state) => NoTransitionPage(child: const CreditScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyCreditRequest,
          name: 'thixMoneyCreditRequest',
          pageBuilder: (context, state) => NoTransitionPage(child: const CreditScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneySavings,
          name: 'thixMoneySavings',
          pageBuilder: (context, state) => NoTransitionPage(child: const SavingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyGroupSavings,
          name: 'thixMoneyGroupSavings',
          pageBuilder: (context, state) => NoTransitionPage(child: const SavingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyTontine,
          name: 'thixMoneyTontine',
          pageBuilder: (context, state) => NoTransitionPage(child: const TontineScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyCreateTontine,
          name: 'thixMoneyCreateTontine',
          pageBuilder: (context, state) => NoTransitionPage(child: const TontineScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyInvestment,
          name: 'thixMoneyInvestment',
          pageBuilder: (context, state) => NoTransitionPage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyInsurance,
          name: 'thixMoneyInsurance',
          pageBuilder: (context, state) => NoTransitionPage(child: const DashboardScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyInternationalTransfer,
          name: 'thixMoneyInternationalTransfer',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransferScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyCards,
          name: 'thixMoneyCards',
          pageBuilder: (context, state) => NoTransitionPage(child: const SettingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyNotifications,
          name: 'thixMoneyNotifications',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransactionHistoryScreen()),
        ),
        GoRoute(
          path: AppRoutes.thixMoneyHistory,
          name: 'thixMoneyHistory',
          pageBuilder: (context, state) => NoTransitionPage(child: const TransactionHistoryScreen()),
        ),

        // ==================== THIX RESERVATION ====================
        GoRoute(
          path: AppRoutes.reservation,
          name: 'reservation',
          pageBuilder: (context, state) => NoTransitionPage(child: const ThixReservationPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVols,
          name: 'reservationVols',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationVolsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsRecherche,
          name: 'reservationVolsRecherche',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolRecherchePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsListe,
          name: 'reservationVolsListe',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolListePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsDetails,
          name: 'reservationVolsDetails',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolDetailsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsPassagers,
          name: 'reservationVolsPassagers',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolPassagersPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsPaiement,
          name: 'reservationVolsPaiement',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolPaiementPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationVolsConfirmation,
          name: 'reservationVolsConfirmation',
          pageBuilder: (context, state) => NoTransitionPage(child: const VolConfirmationPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationHotels,
          name: 'reservationHotels',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationHotelsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationHotelsRecherche,
          name: 'reservationHotelsRecherche',
          pageBuilder: (context, state) => NoTransitionPage(child: const HotelRecherchePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationHotelsListe,
          name: 'reservationHotelsListe',
          pageBuilder: (context, state) => NoTransitionPage(child: const HotelListePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationHotelsDetails,
          name: 'reservationHotelsDetails',
          pageBuilder: (context, state) => NoTransitionPage(child: const HotelDetailsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationHotelsReservation,
          name: 'reservationHotelsReservation',
          pageBuilder: (context, state) => NoTransitionPage(child: const HotelReservationPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationBus,
          name: 'reservationBus',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationBusPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationBusRecherche,
          name: 'reservationBusRecherche',
          pageBuilder: (context, state) => NoTransitionPage(child: const BusRecherchePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationBusListe,
          name: 'reservationBusListe',
          pageBuilder: (context, state) => NoTransitionPage(child: const BusListePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationBusReservation,
          name: 'reservationBusReservation',
          pageBuilder: (context, state) => NoTransitionPage(child: const BusReservationPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationTaxi,
          name: 'reservationTaxi',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationTaxiPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationTaxiCommande,
          name: 'reservationTaxiCommande',
          pageBuilder: (context, state) => NoTransitionPage(child: const TaxiCommandePage()),
        ),
        GoRoute(
          path: AppRoutes.reservationTaxiTrajets,
          name: 'reservationTaxiTrajets',
          pageBuilder: (context, state) => NoTransitionPage(child: const TaxiTrajetsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationColis,
          name: 'reservationColis',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationColisPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationColisEnvoi,
          name: 'reservationColisEnvoi',
          pageBuilder: (context, state) => NoTransitionPage(child: const ColisEnvoiPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationColisSuivi,
          name: 'reservationColisSuivi',
          pageBuilder: (context, state) => NoTransitionPage(child: const ColisSuiviPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationEvent,
          name: 'reservationEvent',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationEventPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationRestaurant,
          name: 'reservationRestaurant',
          pageBuilder: (context, state) => NoTransitionPage(child: const ReservationRestaurantPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationMesReservations,
          name: 'reservationMesReservations',
          pageBuilder: (context, state) => NoTransitionPage(child: const MesReservationsPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationFavoris,
          name: 'reservationFavoris',
          pageBuilder: (context, state) => NoTransitionPage(child: const FavorisPage()),
        ),
        GoRoute(
          path: AppRoutes.reservationProfil,
          name: 'reservationProfil',
          pageBuilder: (context, state) => NoTransitionPage(child: const ProfilPage()),
        ),

        // ==================== THIX INFO ====================
        GoRoute(
          path: AppRoutes.thixInfo,
          name: 'thixInfo',
          pageBuilder: (context, state) => NoTransitionPage(child: const ThixInfoHome()),
        ),
        GoRoute(
          path: AppRoutes.thixInfoArticle,
          name: 'thixInfoArticle',
          pageBuilder: (context, state) {
            final articleId = state.pathParameters['articleId']!;
            return NoTransitionPage(child: ArticleDetailPage(articleId: articleId));
          },
        ),
        GoRoute(
          path: AppRoutes.thixInfoSearch,
          name: 'thixInfoSearch',
          pageBuilder: (context, state) => NoTransitionPage(child: const SearchPage()),
        ),
        GoRoute(
          path: AppRoutes.thixInfoCategory,
          name: 'thixInfoCategory',
          pageBuilder: (context, state) {
            final category = state.pathParameters['category']!;
            return NoTransitionPage(child: CategoryArticlesPage(category: category));
          },
        ),
        GoRoute(
          path: AppRoutes.thixInfoSaved,
          name: 'thixInfoSaved',
          pageBuilder: (context, state) => NoTransitionPage(child: const SavedArticlesPage()),
        ),
        GoRoute(
          path: AppRoutes.thixInfoBreaking,
          name: 'thixInfoBreaking',
          pageBuilder: (context, state) => NoTransitionPage(child: const BreakingNewsPage()),
        ),
        GoRoute(
          path: AppRoutes.thixInfoAdmin,
          name: 'thixInfoAdmin',
          pageBuilder: (context, state) => NoTransitionPage(child: const AdminNewsDashboard()),
        ),
        GoRoute(
          path: AppRoutes.thixInfoCreate,
          name: 'thixInfoCreate',
          pageBuilder: (context, state) => NoTransitionPage(child: const CreateNewsPage()),
        ),
        
        // ==================== THIX MARKET ====================
        GoRoute(
          path: AppRoutes.thixMarket,
          name: 'thixMarket',
          pageBuilder: (context, state) => NoTransitionPage(child: const MarketHomePage()),
          routes: [
            GoRoute(
              path: 'home',
              name: 'marketHome',
              pageBuilder: (context, state) => NoTransitionPage(child: const MarketHomePage()),
            ),
            GoRoute(
              path: 'search',
              name: 'marketSearch',
              pageBuilder: (context, state) => NoTransitionPage(child: const SearchPage()),
            ),
            GoRoute(
              path: 'shops',
              name: 'marketShops',
              pageBuilder: (context, state) => NoTransitionPage(child: const ShopsPage()),
            ),
            GoRoute(
              path: 'buy',
              name: 'marketBuy',
              pageBuilder: (context, state) => NoTransitionPage(child: const BuyPage()),
            ),
            GoRoute(
              path: 'sell',
              name: 'marketSell',
              pageBuilder: (context, state) => NoTransitionPage(child: const SellPage()),
            ),
            GoRoute(
              path: 'messages',
              name: 'marketMessages',
              pageBuilder: (context, state) => NoTransitionPage(child: const MessagesPage()),
            ),
            GoRoute(
              path: 'live',
              name: 'marketLive',
              pageBuilder: (context, state) => NoTransitionPage(child: const LivePage()),
            ),
            GoRoute(
              path: 'activity',
              name: 'marketActivity',
              pageBuilder: (context, state) => NoTransitionPage(child: const MyActivityPage()),
            ),
            GoRoute(
              path: 'settings',
              name: 'marketSettings',
              pageBuilder: (context, state) => NoTransitionPage(child: const MarketSettingsPage()),
            ),
            GoRoute(
              path: 'help',
              name: 'marketHelp',
              pageBuilder: (context, state) => NoTransitionPage(child: const HelpSupportPage()),
            ),
            GoRoute(
              path: 'product/:productId',
              name: 'marketProductDetail',
              pageBuilder: (context, state) {
                final productId = state.pathParameters['productId']!;
                return NoTransitionPage(child: ProductDetailPage(productId: productId));
              },
            ),
            GoRoute(
              path: 'compare',
              name: 'marketProductComparator',
              pageBuilder: (context, state) => NoTransitionPage(child: const ProductComparatorPage()),
            ),
            GoRoute(
              path: 'price-alerts',
              name: 'marketPriceAlerts',
              pageBuilder: (context, state) => NoTransitionPage(child: const PriceAlertsPage()),
            ),
            GoRoute(
              path: 'cart',
              name: 'marketCart',
              pageBuilder: (context, state) => NoTransitionPage(child: const CartPage()),
            ),
            GoRoute(
              path: 'checkout',
              name: 'marketCheckout',
              pageBuilder: (context, state) => NoTransitionPage(child: const CheckoutPage()),
            ),
            GoRoute(
              path: 'orders',
              name: 'marketOrders',
              pageBuilder: (context, state) => NoTransitionPage(child: const OrderHistoryPage()),
            ),
            GoRoute(
              path: 'order/:orderId',
              name: 'marketOrderDetail',
              pageBuilder: (context, state) {
                final orderId = state.pathParameters['orderId']!;
                return NoTransitionPage(child: OrderDetailPage(orderId: orderId));
              },
            ),
            GoRoute(
              path: 'shop/create',
              name: 'marketCreateShop',
              pageBuilder: (context, state) => NoTransitionPage(child: const CreateShopPage()),
            ),
            GoRoute(
              path: 'shop/:shopId/manage',
              name: 'marketManageShop',
              pageBuilder: (context, state) {
                final shopId = state.pathParameters['shopId']!;
                return NoTransitionPage(child: ManageShopPage(shopId: shopId));
              },
            ),
            GoRoute(
              path: 'shop/:shopId/stats',
              name: 'marketShopStats',
              pageBuilder: (context, state) {
                final shopId = state.pathParameters['shopId']!;
                return NoTransitionPage(child: ShopStatisticsPage(shopId: shopId));
              },
            ),
            GoRoute(
              path: 'announcement/publish',
              name: 'marketPublishAnnouncement',
              pageBuilder: (context, state) => NoTransitionPage(child: const PublishAnnouncementPage()),
            ),
            GoRoute(
              path: 'announcement/:announcementId/edit',
              name: 'marketEditAnnouncement',
              pageBuilder: (context, state) {
                final announcementId = state.pathParameters['announcementId']!;
                return NoTransitionPage(child: EditAnnouncementPage(announcementId: announcementId));
              },
            ),
            GoRoute(
              path: 'live/:liveId',
              name: 'marketLiveStream',
              pageBuilder: (context, state) {
                final liveId = state.pathParameters['liveId']!;
                return NoTransitionPage(child: LiveStreamPage(liveId: liveId));
              },
            ),
            GoRoute(
              path: 'live/create',
              name: 'marketCreateLive',
              pageBuilder: (context, state) => NoTransitionPage(child: const CreateLivePage()),
            ),
            GoRoute(
              path: 'live/:liveId/replay',
              name: 'marketLiveReplay',
              pageBuilder: (context, state) {
                final liveId = state.pathParameters['liveId']!;
                return NoTransitionPage(child: LiveReplayPage(liveId: liveId));
              },
            ),
            GoRoute(
              path: 'auction/:auctionId',
              name: 'marketAuction',
              pageBuilder: (context, state) {
                final auctionId = state.pathParameters['auctionId']!;
                return NoTransitionPage(child: AuctionPage(auctionId: auctionId));
              },
            ),
            GoRoute(
              path: 'chat/:conversationId',
              name: 'marketChat',
              pageBuilder: (context, state) {
                final conversationId = state.pathParameters['conversationId']!;
                return NoTransitionPage(child: ChatPage(conversationId: conversationId));
              },
            ),
            GoRoute(
              path: 'dispute/:disputeId',
              name: 'marketDispute',
              pageBuilder: (context, state) {
                final disputeId = state.pathParameters['disputeId']!;
                return NoTransitionPage(child: DisputeDetailPage(disputeId: disputeId));
              },
            ),
            GoRoute(
              path: 'notifications',
              name: 'marketNotifications',
              pageBuilder: (context, state) => NoTransitionPage(child: const NotificationPage()),
            ),
          ],
        ),

        // ==================== THIX MEDIA ====================
        GoRoute(
          path: AppRoutes.thixMedia,
          name: 'thixMedia',
          pageBuilder: (context, state) => NoTransitionPage(child: const ThixMediaPage()),
        ),

        // ==================== JOB ROUTES ====================
        GoRoute(
          path: AppRoutes.jobs,
          name: 'jobs',
          pageBuilder: (context, state) => NoTransitionPage(child: const JobsPage()),
        ),
        GoRoute(
          path: '/jobs/:jobId',
          name: 'jobDetails',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: JobDetailsPage(jobId: jobId, applied: applied));
          },
        ),
        GoRoute(
          path: '/jobs/:jobId/apply',
          name: 'jobApply',
          pageBuilder: (context, state) {
            final jobId = state.pathParameters['jobId'] ?? '';
            return NoTransitionPage(child: JobApplyPage(jobId: jobId));
          },
        ),
        GoRoute(
          path: AppRoutes.jobDashboard,
          name: 'jobDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: const JobDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.recruiter,
          name: 'recruiter',
          pageBuilder: (context, state) => NoTransitionPage(child: const RecruiterPortalPage()),
        ),

        // ==================== OPPORTUNITIES ROUTES ====================
        GoRoute(
          path: AppRoutes.opportunities,
          name: 'opportunities',
          pageBuilder: (context, state) => NoTransitionPage(child: const OpportunitiesPage()),
        ),
        GoRoute(
          path: '/opportunities/:opportunityId',
          name: 'opportunityDetails',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            final applied = (state.uri.queryParameters['applied'] ?? '').trim() == '1';
            return NoTransitionPage(child: OpportunityDetailsPage(opportunityId: opportunityId, applied: applied));
          },
        ),
        GoRoute(
          path: '/opportunities/:opportunityId/apply',
          name: 'opportunityApply',
          pageBuilder: (context, state) {
            final opportunityId = state.pathParameters['opportunityId'] ?? '';
            return NoTransitionPage(child: OpportunityApplyPage(opportunityId: opportunityId));
          },
        ),

        // ==================== TRAINING ROUTES ====================
        GoRoute(
          path: AppRoutes.trainingHome,
          name: 'trainingHome',
          pageBuilder: (context, state) => NoTransitionPage(child: const TrainingHomePage()),
        ),
        GoRoute(
          path: '/training/:trainingId',
          name: 'trainingDetails',
          pageBuilder: (context, state) {
            final trainingId = state.pathParameters['trainingId'] ?? '';
            return NoTransitionPage(child: TrainingDetailsPage(trainingId: trainingId));
          },
        ),
        GoRoute(
          path: AppRoutes.learningDashboard,
          name: 'learningDashboard',
          pageBuilder: (context, state) => NoTransitionPage(child: const LearningDashboardPage()),
        ),
        GoRoute(
          path: '/lesson/:enrollmentId',
          name: 'lessonPlayer',
          pageBuilder: (context, state) {
            final enrollmentId = state.pathParameters['enrollmentId'] ?? '';
            return NoTransitionPage(child: LessonPlayerPage(enrollmentId: enrollmentId));
          },
        ),

        // ==================== EDUCATION ROUTE ====================
        GoRoute(
          path: AppRoutes.education,
          name: 'education',
          pageBuilder: (context, state) => NoTransitionPage(child: const EducationPage()),
        ),

        // ==================== ADMIN ROUTES ====================
        GoRoute(
          path: '${AppRoutes.admin}/:module',
          name: 'admin',
          pageBuilder: (context, state) {
            final module = AdminModuleX.fromSlug(state.pathParameters['module']);
            return NoTransitionPage(child: AdminPage(module: module));
          },
        ),
        GoRoute(
          path: AppRoutes.admin,
          name: 'adminRoot',
          redirect: (_, __) => '${AppRoutes.admin}/${AdminModule.overview.slug}',
        ),
        GoRoute(
          path: AppRoutes.adminMedia,
          name: 'adminMedia',
          pageBuilder: (context, state) => NoTransitionPage(child: const AdminMediaPage()),
        ),
      ],
    );
  }
}

extension GoRouterBackHelpers on BuildContext {
  void popOrGo(String fallbackLocation) {
    final router = GoRouter.of(this);
    if (router.canPop()) {
      pop();
      return;
    }
    go(fallbackLocation);
  }
}
