import '../../core/constants/api_paths.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/app_models.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<User> login({required String username, required String password}) async {
    final data = await _api.post(ApiPaths.authToken, data: {'username': username, 'password': password}) as Map<String, dynamic>;
    await _storage.saveTokens(access: data['access'].toString(), refresh: data['refresh'].toString());
    return me();
  }

  Future<User> register({required String username, required String email, required String phone, required String password}) async {
    await _api.post(ApiPaths.authRegister, data: {'username': username, 'email': email, 'phone': phone, 'password': password});
    return login(username: username, password: password);
  }

  Future<User> me() async {
    final data = await _api.get(ApiPaths.authMe) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<User> updateProfile({String? username, String? email, String? phone, String? avatarUrl}) async {
    final payload = <String, dynamic>{
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
    final data = await _api.patch(ApiPaths.authMe, data: payload) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    final refresh = await _storage.getRefreshToken();
    try {
      if (refresh != null && refresh.isNotEmpty) {
        await _api.post(ApiPaths.authLogout, data: {'refresh': refresh});
      }
    } catch (_) {
      // Local logout must still work even if token blacklist endpoint fails.
    }
    await _storage.clearTokens();
  }

  Future<bool> hasSavedToken() async => (await _storage.getAccessToken())?.isNotEmpty == true;
}

class CreatorRepository {
  CreatorRepository(this._api);

  final ApiClient _api;

  Future<CreatorProfile?> myProfile() async {
    try {
      final data = await _api.get(ApiPaths.creatorMe) as Map<String, dynamic>;
      return CreatorProfile.fromJson(data);
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<CreatorProfile> createProfile(Map<String, dynamic> payload) async {
    final data = await _api.post(ApiPaths.creatorMe, data: payload) as Map<String, dynamic>;
    return CreatorProfile.fromJson(data);
  }

  Future<CreatorProfile> updateProfile(Map<String, dynamic> payload) async {
    final data = await _api.patch(ApiPaths.creatorMe, data: payload) as Map<String, dynamic>;
    return CreatorProfile.fromJson(data);
  }

  Future<CreatorDashboard> dashboard() async {
    final data = await _api.get(ApiPaths.creatorDashboard) as Map<String, dynamic>;
    return CreatorDashboard.fromJson(data);
  }

  Future<CreatorProfile> publicProfile(String id) async {
    final data = await _api.get('/creators/$id/') as Map<String, dynamic>;
    return CreatorProfile.fromJson(data);
  }
}

class SubscriptionRepository {
  SubscriptionRepository(this._api);

  final ApiClient _api;

  Future<List<Plan>> plans() async {
    final data = await _api.get(ApiPaths.plans);
    return extractList(data).whereType<Map<String, dynamic>>().map(Plan.fromJson).toList();
  }

  Future<CurrentSubscription> current() async {
    final data = await _api.get(ApiPaths.currentSubscription) as Map<String, dynamic>;
    return CurrentSubscription.fromJson(data);
  }

  Future<Subscription> activateDev(String planCode) async {
    final data = await _api.post(ApiPaths.activateDevSubscription, data: {'plan_code': planCode}) as Map<String, dynamic>;
    return Subscription.fromJson(data);
  }
}

class PaymentRepository {
  PaymentRepository(this._api);

  final ApiClient _api;

  Future<List<PaymentRecord>> list() async {
    final data = await _api.get(ApiPaths.payments);
    return extractList(data).whereType<Map<String, dynamic>>().map(PaymentRecord.fromJson).toList();
  }

  Future<PaymentRecord> initiate({required String planCode, required String provider, String phone = ''}) async {
    final data = await _api.post(ApiPaths.paymentInitiate, data: {
      'plan_code': planCode,
      'provider': provider,
      'phone': phone,
    }) as Map<String, dynamic>;
    final payment = data['payment'] as Map<String, dynamic>;
    return PaymentRecord.fromJson(payment);
  }
}

class ContentRepository {
  ContentRepository(this._api);

  final ApiClient _api;

  Future<List<Category>> categories() async {
    final data = await _api.get(ApiPaths.categories);
    return extractList(data).whereType<Map<String, dynamic>>().map(Category.fromJson).toList();
  }

  Future<List<ContentItem>> list() async {
    final data = await _api.get(ApiPaths.contentItems);
    return extractList(data).whereType<Map<String, dynamic>>().map(ContentItem.fromJson).toList();
  }

  Future<ContentItem> detail(String id) async {
    final data = await _api.get(ApiPaths.contentDetail(id)) as Map<String, dynamic>;
    return ContentItem.fromJson(data);
  }

  Future<ContentItem> create(Map<String, dynamic> payload) async {
    final data = await _api.post(ApiPaths.contentItems, data: payload) as Map<String, dynamic>;
    return ContentItem.fromJson(data);
  }

  Future<ContentItem> submitForReview(String id) async {
    final data = await _api.post(ApiPaths.contentSubmit(id)) as Map<String, dynamic>;
    return ContentItem.fromJson(data);
  }

  Future<ContentItem> approve(String id) async {
    final data = await _api.post(ApiPaths.contentApprove(id)) as Map<String, dynamic>;
    return ContentItem.fromJson(data);
  }

  Future<StreamInfo> stream(String id) async {
    final data = await _api.get(ApiPaths.contentStream(id)) as Map<String, dynamic>;
    return StreamInfo.fromContentJson(data);
  }
}

class ReelsRepository {
  ReelsRepository(this._api);

  final ApiClient _api;

  Future<List<ReelItem>> list() async {
    final data = await _api.get(ApiPaths.reels);
    return extractList(data).whereType<Map<String, dynamic>>().map(ReelItem.fromJson).toList();
  }

  Future<List<ReelItem>> feed() async {
    final data = await _api.get(ApiPaths.reelsFeed);
    return extractList(data).whereType<Map<String, dynamic>>().map(ReelItem.fromJson).toList();
  }

  Future<ReelItem> detail(String id) async {
    final data = await _api.get(ApiPaths.reelDetail(id)) as Map<String, dynamic>;
    return ReelItem.fromJson(data);
  }

  Future<ReelItem> create(Map<String, dynamic> payload) async {
    final data = await _api.post(ApiPaths.reels, data: payload) as Map<String, dynamic>;
    return ReelItem.fromJson(data);
  }

  Future<ReelItem> submitForReview(String id) async {
    final data = await _api.post(ApiPaths.reelSubmit(id)) as Map<String, dynamic>;
    return ReelItem.fromJson(data);
  }

  Future<ReelItem> approve(String id) async {
    final data = await _api.post(ApiPaths.reelApprove(id)) as Map<String, dynamic>;
    return ReelItem.fromJson(data);
  }

  Future<StreamInfo> stream(String id) async {
    final data = await _api.get(ApiPaths.reelStream(id)) as Map<String, dynamic>;
    return StreamInfo.fromReelJson(data);
  }
}

class EngagementRepository {
  EngagementRepository(this._api);

  final ApiClient _api;

  Future<bool> toggleLike({required String targetType, required String targetId}) async {
    final data = await _api.post(ApiPaths.likeToggle, data: {'target_type': targetType, 'target_id': targetId}) as Map<String, dynamic>;
    return boolValue(data['liked']);
  }

  Future<void> vote({required String targetType, required String targetId, required int score}) async {
    await _api.post(ApiPaths.votes, data: {'target_type': targetType, 'target_id': targetId, 'score': score});
  }

  Future<Map<String, dynamic>> toggleFollow(String creatorId) async {
    return await _api.post(ApiPaths.followToggle, data: {'creator_id': creatorId}) as Map<String, dynamic>;
  }

  Future<void> award({required String creatorId, required String targetType, required String targetId, required int points, String message = ''}) async {
    await _api.post(ApiPaths.awards, data: {
      'creator': creatorId,
      'target_type': targetType,
      'target_id': targetId,
      'points': points,
      'message': message,
    });
  }

  Future<List<CommentItem>> comments({required String targetType, required String targetId}) async {
    final data = await _api.get(ApiPaths.comments, queryParameters: {'target_type': targetType, 'target_id': targetId});
    return extractList(data).whereType<Map<String, dynamic>>().map(CommentItem.fromJson).toList();
  }

  Future<CommentItem> addComment({required String targetType, required String targetId, required String text}) async {
    final data = await _api.post(ApiPaths.comments, data: {'target_type': targetType, 'target_id': targetId, 'text': text}) as Map<String, dynamic>;
    return CommentItem.fromJson(data);
  }
}

class AnalyticsRepository {
  AnalyticsRepository(this._api, this._storage);

  final ApiClient _api;
  final SecureStorageService _storage;

  Future<WatchSession> startWatch({required String targetType, required String targetId}) async {
    final deviceId = await _storage.getOrCreateDeviceId();
    final data = await _api.post(ApiPaths.watchStart, data: {'target_type': targetType, 'target_id': targetId, 'device_id': deviceId}) as Map<String, dynamic>;
    return WatchSession.fromJson(data);
  }

  Future<WatchSession> endWatch({required String watchSessionId, required int secondsWatched, required bool completed}) async {
    final data = await _api.post(ApiPaths.watchEnd, data: {'watch_session_id': watchSessionId, 'seconds_watched': secondsWatched, 'completed': completed}) as Map<String, dynamic>;
    return WatchSession.fromJson(data);
  }
}

class RewardsRepository {
  RewardsRepository(this._api);

  final ApiClient _api;

  Future<List<CreatorEarning>> earnings() async {
    final data = await _api.get(ApiPaths.earnings);
    return extractList(data).whereType<Map<String, dynamic>>().map(CreatorEarning.fromJson).toList();
  }

  Future<List<PayoutRecord>> payouts() async {
    final data = await _api.get(ApiPaths.payouts);
    return extractList(data).whereType<Map<String, dynamic>>().map(PayoutRecord.fromJson).toList();
  }
}

class ModerationRepository {
  ModerationRepository(this._api);

  final ApiClient _api;

  Future<List<ReportItem>> reports() async {
    final data = await _api.get(ApiPaths.reports);
    return extractList(data).whereType<Map<String, dynamic>>().map(ReportItem.fromJson).toList();
  }

  Future<ReportItem> createReport({required String targetType, required String targetId, required String reason, required String description}) async {
    final data = await _api.post(ApiPaths.reportCreate, data: {
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'description': description,
    }) as Map<String, dynamic>;
    return ReportItem.fromJson(data);
  }
}

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  Future<List<AppNotification>> list({bool? isRead}) async {
    final data = await _api.get(ApiPaths.notifications, queryParameters: {if (isRead != null) 'is_read': isRead.toString()});
    return extractList(data).whereType<Map<String, dynamic>>().map(AppNotification.fromJson).toList();
  }

  Future<AppNotification> markRead(String id) async {
    final data = await _api.post(ApiPaths.notificationMarkRead(id)) as Map<String, dynamic>;
    return AppNotification.fromJson(data);
  }
}
