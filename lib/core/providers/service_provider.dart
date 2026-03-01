import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/station_service.dart';
import '../services/eurostar_service.dart';
import '../services/payment_service.dart';
import '../services/order_service.dart';
import '../services/itinerary_service.dart';
import '../services/user_service.dart';
import '../services/plan_service.dart';
import '../services/trip_service.dart';
import '../services/visa_service.dart';
import '../storage/secure_storage.dart';

/// Lazy singleton service locator — initialised once at app start.
class ServiceProvider {
  static final ServiceProvider _instance = ServiceProvider._();
  factory ServiceProvider() => _instance;
  ServiceProvider._();

  late final SecureStorageService storage;
  late final ApiClient apiClient;
  late final AuthService authService;
  late final StationService stationService;
  late final EurostarService eurostarService;
  late final PaymentService paymentService;
  late final OrderService orderService;
  late final ItineraryService itineraryService;
  late final UserService userService;
  late final PlanService planService;
  late final TripService tripService;
  late final VisaService visaService;

  bool _initialised = false;

  void init() {
    if (_initialised) return;
    storage = SecureStorageService();
    apiClient = ApiClient(storage: storage);
    authService = AuthService(api: apiClient, storage: storage);
    stationService = StationService(api: apiClient);
    eurostarService = EurostarService(api: apiClient);
    paymentService = PaymentService(api: apiClient);
    orderService = OrderService(api: apiClient);
    itineraryService = ItineraryService(api: apiClient);
    userService = UserService(api: apiClient);
    planService = PlanService(api: apiClient);
    tripService = TripService(api: apiClient);
    visaService = VisaService(api: apiClient);
    _initialised = true;
  }
}
