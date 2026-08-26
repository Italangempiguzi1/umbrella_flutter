import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/app_models.dart';
import '../repositories/app_repositories.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return SecureStorageService(storage);
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(secureStorageProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider), ref.watch(secureStorageProvider)));
final creatorRepositoryProvider = Provider<CreatorRepository>((ref) => CreatorRepository(ref.watch(apiClientProvider)));
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) => SubscriptionRepository(ref.watch(apiClientProvider)));
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => PaymentRepository(ref.watch(apiClientProvider)));
final contentRepositoryProvider = Provider<ContentRepository>((ref) => ContentRepository(ref.watch(apiClientProvider)));
final reelsRepositoryProvider = Provider<ReelsRepository>((ref) => ReelsRepository(ref.watch(apiClientProvider)));
final engagementRepositoryProvider = Provider<EngagementRepository>((ref) => EngagementRepository(ref.watch(apiClientProvider)));
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) => AnalyticsRepository(ref.watch(apiClientProvider), ref.watch(secureStorageProvider)));
final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) => RewardsRepository(ref.watch(apiClientProvider)));
final moderationRepositoryProvider = Provider<ModerationRepository>((ref) => ModerationRepository(ref.watch(apiClientProvider)));
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository(ref.watch(apiClientProvider)));

class AuthState {
  const AuthState({this.user, this.isBootstrapping = true, this.isLoading = false, this.error});

  final User? user;
  final bool isBootstrapping;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isBootstrapping, bool? isLoading, String? error, bool clearUser = false, bool clearError = false}) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> bootstrap() async {
    final hasToken = await _repo.hasSavedToken();
    if (!hasToken) {
      state = state.copyWith(isBootstrapping: false, clearUser: true, clearError: true);
      return;
    }
    try {
      final user = await _repo.me();
      state = AuthState(user: user, isBootstrapping: false);
    } catch (error) {
      await _repo.logout();
      state = AuthState(isBootstrapping: false, error: error.toString());
    }
  }

  Future<void> login({required String username, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.login(username: username, password: password);
      state = AuthState(user: user, isBootstrapping: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> register({required String username, required String email, required String phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repo.register(username: username, email: email, phone: phone, password: password);
      state = AuthState(user: user, isBootstrapping: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      rethrow;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.me();
      state = state.copyWith(user: user, clearError: true);
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<User> updateProfile({String? username, String? email, String? phone, String? avatarUrl}) async {
    final user = await _repo.updateProfile(username: username, email: email, phone: phone, avatarUrl: avatarUrl);
    state = state.copyWith(user: user, clearError: true);
    return user;
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isBootstrapping: false);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref.watch(authRepositoryProvider)));

final plansProvider = FutureProvider<List<Plan>>((ref) => ref.watch(subscriptionRepositoryProvider).plans());
final currentSubscriptionProvider = FutureProvider<CurrentSubscription>((ref) => ref.watch(subscriptionRepositoryProvider).current());
final paymentHistoryProvider = FutureProvider<List<PaymentRecord>>((ref) => ref.watch(paymentRepositoryProvider).list());
final categoriesProvider = FutureProvider<List<Category>>((ref) => ref.watch(contentRepositoryProvider).categories());
final contentItemsProvider = FutureProvider<List<ContentItem>>((ref) => ref.watch(contentRepositoryProvider).list());
final contentDetailProvider = FutureProvider.family<ContentItem, String>((ref, id) => ref.watch(contentRepositoryProvider).detail(id));
final reelsFeedProvider = FutureProvider<List<ReelItem>>((ref) => ref.watch(reelsRepositoryProvider).feed());
final allReelsProvider = FutureProvider<List<ReelItem>>((ref) => ref.watch(reelsRepositoryProvider).list());
final creatorProfileProvider = FutureProvider<CreatorProfile?>((ref) => ref.watch(creatorRepositoryProvider).myProfile());
final creatorDashboardProvider = FutureProvider<CreatorDashboard>((ref) => ref.watch(creatorRepositoryProvider).dashboard());
final earningsProvider = FutureProvider<List<CreatorEarning>>((ref) => ref.watch(rewardsRepositoryProvider).earnings());
final payoutsProvider = FutureProvider<List<PayoutRecord>>((ref) => ref.watch(rewardsRepositoryProvider).payouts());
final reportsProvider = FutureProvider<List<ReportItem>>((ref) => ref.watch(moderationRepositoryProvider).reports());
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) => ref.watch(notificationRepositoryProvider).list());
final commentsProvider = FutureProvider.family<List<CommentItem>, ({String targetType, String targetId})>((ref, args) {
  return ref.watch(engagementRepositoryProvider).comments(targetType: args.targetType, targetId: args.targetId);
});
