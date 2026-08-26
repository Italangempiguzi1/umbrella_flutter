import 'package:intl/intl.dart';

List<dynamic> extractList(dynamic data) {
  if (data is List) return data;
  if (data is Map<String, dynamic> && data['results'] is List) return data['results'] as List<dynamic>;
  return const [];
}

String stringValue(dynamic value, [String fallback = '']) => value == null ? fallback : value.toString();
int intValue(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double doubleValue(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

bool boolValue(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

DateTime? dateValue(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return DateTime.tryParse(value.toString());
}

String moneyTzs(num amount) => 'TZS ${NumberFormat('#,##0').format(amount)}';
String compactNumber(num value) => NumberFormat.compact().format(value);
String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) return '${hours}h ${minutes}m';
  return '${minutes}m';
}

class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.dateJoined,
  });

  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? dateJoined;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: stringValue(json['id']),
        username: stringValue(json['username']),
        email: stringValue(json['email']),
        phone: stringValue(json['phone']),
        role: stringValue(json['role'], 'viewer'),
        avatarUrl: stringValue(json['avatar_url']),
        isEmailVerified: boolValue(json['is_email_verified']),
        isPhoneVerified: boolValue(json['is_phone_verified']),
        dateJoined: dateValue(json['date_joined']),
      );
}

class CreatorProfile {
  const CreatorProfile({
    required this.id,
    required this.user,
    required this.username,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.profileImageUrl,
    required this.coverImageUrl,
    required this.verificationStatus,
    required this.payoutPhone,
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.totalFollowers,
    required this.isActive,
  });

  final String id;
  final String user;
  final String username;
  final String email;
  final String displayName;
  final String bio;
  final String profileImageUrl;
  final String coverImageUrl;
  final String verificationStatus;
  final String payoutPhone;
  final String bankName;
  final String bankAccountName;
  final String bankAccountNumber;
  final int totalFollowers;
  final bool isActive;

  bool get canUpload => isActive && (verificationStatus == 'pending' || verificationStatus == 'verified');

  factory CreatorProfile.fromJson(Map<String, dynamic> json) => CreatorProfile(
        id: stringValue(json['id']),
        user: stringValue(json['user']),
        username: stringValue(json['username']),
        email: stringValue(json['email']),
        displayName: stringValue(json['display_name']),
        bio: stringValue(json['bio']),
        profileImageUrl: stringValue(json['profile_image_url']),
        coverImageUrl: stringValue(json['cover_image_url']),
        verificationStatus: stringValue(json['verification_status']),
        payoutPhone: stringValue(json['payout_phone']),
        bankName: stringValue(json['bank_name']),
        bankAccountName: stringValue(json['bank_account_name']),
        bankAccountNumber: stringValue(json['bank_account_number']),
        totalFollowers: intValue(json['total_followers']),
        isActive: boolValue(json['is_active'], true),
      );
}

class CreatorDashboard {
  const CreatorDashboard({
    required this.totalLongFormContent,
    required this.totalReels,
    required this.totalFollowers,
    required this.totalWatchSeconds,
    required this.validViews,
    required this.estimatedPendingEarnings,
  });

  final int totalLongFormContent;
  final int totalReels;
  final int totalFollowers;
  final int totalWatchSeconds;
  final int validViews;
  final double estimatedPendingEarnings;

  factory CreatorDashboard.fromJson(Map<String, dynamic> json) => CreatorDashboard(
        totalLongFormContent: intValue(json['total_long_form_content']),
        totalReels: intValue(json['total_reels']),
        totalFollowers: intValue(json['total_followers']),
        totalWatchSeconds: intValue(json['total_watch_seconds']),
        validViews: intValue(json['valid_views']),
        estimatedPendingEarnings: doubleValue(json['estimated_pending_earnings']),
      );
}

class Plan {
  const Plan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.priceTzs,
    required this.maxDevices,
    required this.maxQuality,
    required this.downloadsEnabled,
    required this.earlyAccessEnabled,
    required this.monthlyAwardPoints,
    required this.isActive,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final double priceTzs;
  final int maxDevices;
  final String maxQuality;
  final bool downloadsEnabled;
  final bool earlyAccessEnabled;
  final int monthlyAwardPoints;
  final bool isActive;

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: stringValue(json['id']),
        code: stringValue(json['code']),
        name: stringValue(json['name']),
        description: stringValue(json['description']),
        priceTzs: doubleValue(json['price_tzs']),
        maxDevices: intValue(json['max_devices'], 1),
        maxQuality: stringValue(json['max_quality'], 'HD'),
        downloadsEnabled: boolValue(json['downloads_enabled']),
        earlyAccessEnabled: boolValue(json['early_access_enabled']),
        monthlyAwardPoints: intValue(json['monthly_award_points']),
        isActive: boolValue(json['is_active'], true),
      );
}

class Subscription {
  const Subscription({
    required this.id,
    required this.plan,
    required this.status,
    this.startedAt,
    this.expiresAt,
    required this.autoRenew,
    required this.providerReference,
    required this.isActiveNow,
  });

  final String id;
  final Plan? plan;
  final String status;
  final DateTime? startedAt;
  final DateTime? expiresAt;
  final bool autoRenew;
  final String providerReference;
  final bool isActiveNow;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: stringValue(json['id']),
        plan: json['plan'] is Map<String, dynamic> ? Plan.fromJson(json['plan'] as Map<String, dynamic>) : null,
        status: stringValue(json['status']),
        startedAt: dateValue(json['started_at']),
        expiresAt: dateValue(json['expires_at']),
        autoRenew: boolValue(json['auto_renew']),
        providerReference: stringValue(json['provider_reference']),
        isActiveNow: boolValue(json['is_active_now']),
      );
}

class CurrentSubscription {
  const CurrentSubscription({required this.active, this.subscription});

  final bool active;
  final Subscription? subscription;

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) => CurrentSubscription(
        active: boolValue(json['active']),
        subscription: json['subscription'] is Map<String, dynamic>
            ? Subscription.fromJson(json['subscription'] as Map<String, dynamic>)
            : null,
      );
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.plan,
    required this.provider,
    required this.status,
    required this.amount,
    required this.currency,
    required this.phone,
    required this.providerReference,
    required this.checkoutUrl,
    this.createdAt,
  });

  final String id;
  final String plan;
  final String provider;
  final String status;
  final double amount;
  final String currency;
  final String phone;
  final String providerReference;
  final String checkoutUrl;
  final DateTime? createdAt;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: stringValue(json['id']),
        plan: stringValue(json['plan']),
        provider: stringValue(json['provider']),
        status: stringValue(json['status']),
        amount: doubleValue(json['amount']),
        currency: stringValue(json['currency'], 'TZS'),
        phone: stringValue(json['phone']),
        providerReference: stringValue(json['provider_reference']),
        checkoutUrl: stringValue(json['checkout_url']),
        createdAt: dateValue(json['created_at']),
      );
}

class Category {
  const Category({required this.id, required this.name, required this.slug, required this.description, required this.isActive});

  final String id;
  final String name;
  final String slug;
  final String description;
  final bool isActive;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: stringValue(json['id']),
        name: stringValue(json['name']),
        slug: stringValue(json['slug']),
        description: stringValue(json['description']),
        isActive: boolValue(json['is_active'], true),
      );
}

class VideoAsset {
  const VideoAsset({
    required this.id,
    required this.sourceFileUrl,
    required this.hlsManifestUrl,
    required this.dashManifestUrl,
    required this.mp4Url,
    required this.qualityLabel,
    required this.processingStatus,
    required this.processingError,
  });

  final String id;
  final String sourceFileUrl;
  final String hlsManifestUrl;
  final String dashManifestUrl;
  final String mp4Url;
  final String qualityLabel;
  final String processingStatus;
  final String processingError;

  factory VideoAsset.fromJson(Map<String, dynamic> json) => VideoAsset(
        id: stringValue(json['id']),
        sourceFileUrl: stringValue(json['source_file_url']),
        hlsManifestUrl: stringValue(json['hls_manifest_url']),
        dashManifestUrl: stringValue(json['dash_manifest_url']),
        mp4Url: stringValue(json['mp4_url']),
        qualityLabel: stringValue(json['quality_label'], '720p'),
        processingStatus: stringValue(json['processing_status']),
        processingError: stringValue(json['processing_error']),
      );
}

class ContentItem {
  const ContentItem({
    required this.id,
    required this.creator,
    required this.creatorName,
    required this.category,
    required this.categoryName,
    required this.title,
    required this.slug,
    required this.description,
    required this.contentType,
    required this.language,
    required this.ageRating,
    required this.thumbnailUrl,
    required this.trailerUrl,
    required this.durationSeconds,
    required this.isPremium,
    required this.earlyAccess,
    required this.status,
    this.publishedAt,
    required this.totalViews,
    required this.totalWatchSeconds,
    this.videoAsset,
    this.createdAt,
  });

  final String id;
  final String creator;
  final String creatorName;
  final String category;
  final String categoryName;
  final String title;
  final String slug;
  final String description;
  final String contentType;
  final String language;
  final String ageRating;
  final String thumbnailUrl;
  final String trailerUrl;
  final int durationSeconds;
  final bool isPremium;
  final bool earlyAccess;
  final String status;
  final DateTime? publishedAt;
  final int totalViews;
  final int totalWatchSeconds;
  final VideoAsset? videoAsset;
  final DateTime? createdAt;

  String get typeLabel => contentType.replaceAll('_', ' ').split(' ').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');

  factory ContentItem.fromJson(Map<String, dynamic> json) => ContentItem(
        id: stringValue(json['id']),
        creator: stringValue(json['creator']),
        creatorName: stringValue(json['creator_name'], 'Umbrella Creator'),
        category: stringValue(json['category']),
        categoryName: stringValue(json['category_name']),
        title: stringValue(json['title']),
        slug: stringValue(json['slug']),
        description: stringValue(json['description']),
        contentType: stringValue(json['content_type'], 'movie'),
        language: stringValue(json['language'], 'Swahili'),
        ageRating: stringValue(json['age_rating'], 'General'),
        thumbnailUrl: stringValue(json['thumbnail_url']),
        trailerUrl: stringValue(json['trailer_url']),
        durationSeconds: intValue(json['duration_seconds']),
        isPremium: boolValue(json['is_premium'], true),
        earlyAccess: boolValue(json['early_access']),
        status: stringValue(json['status']),
        publishedAt: dateValue(json['published_at']),
        totalViews: intValue(json['total_views']),
        totalWatchSeconds: intValue(json['total_watch_seconds']),
        videoAsset: json['video_asset'] is Map<String, dynamic> ? VideoAsset.fromJson(json['video_asset'] as Map<String, dynamic>) : null,
        createdAt: dateValue(json['created_at']),
      );
}

class ReelItem {
  const ReelItem({
    required this.id,
    required this.creator,
    required this.creatorName,
    required this.category,
    required this.categoryName,
    required this.title,
    required this.caption,
    required this.videoUrl,
    required this.hlsManifestUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.status,
    this.publishedAt,
    required this.totalViews,
    required this.totalWatchSeconds,
  });

  final String id;
  final String creator;
  final String creatorName;
  final String category;
  final String categoryName;
  final String title;
  final String caption;
  final String videoUrl;
  final String hlsManifestUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final String status;
  final DateTime? publishedAt;
  final int totalViews;
  final int totalWatchSeconds;

  factory ReelItem.fromJson(Map<String, dynamic> json) => ReelItem(
        id: stringValue(json['id']),
        creator: stringValue(json['creator']),
        creatorName: stringValue(json['creator_name'], 'Creator'),
        category: stringValue(json['category']),
        categoryName: stringValue(json['category_name']),
        title: stringValue(json['title']),
        caption: stringValue(json['caption']),
        videoUrl: stringValue(json['video_url']),
        hlsManifestUrl: stringValue(json['hls_manifest_url']),
        thumbnailUrl: stringValue(json['thumbnail_url']),
        durationSeconds: intValue(json['duration_seconds']),
        status: stringValue(json['status']),
        publishedAt: dateValue(json['published_at']),
        totalViews: intValue(json['total_views']),
        totalWatchSeconds: intValue(json['total_watch_seconds']),
      );
}

class StreamInfo {
  const StreamInfo({required this.id, required this.title, required this.hlsUrl, required this.dashUrl, required this.mp4Url, required this.videoUrl, required this.qualityLabel});

  final String id;
  final String title;
  final String hlsUrl;
  final String dashUrl;
  final String mp4Url;
  final String videoUrl;
  final String qualityLabel;

  String get playableUrl {
    if (hlsUrl.isNotEmpty) return hlsUrl;
    if (mp4Url.isNotEmpty) return mp4Url;
    if (videoUrl.isNotEmpty) return videoUrl;
    return dashUrl;
  }

  factory StreamInfo.fromContentJson(Map<String, dynamic> json) => StreamInfo(
        id: stringValue(json['content_id']),
        title: stringValue(json['title']),
        hlsUrl: stringValue(json['hls_manifest_url']),
        dashUrl: stringValue(json['dash_manifest_url']),
        mp4Url: stringValue(json['mp4_url']),
        videoUrl: '',
        qualityLabel: stringValue(json['quality_label']),
      );

  factory StreamInfo.fromReelJson(Map<String, dynamic> json) => StreamInfo(
        id: stringValue(json['reel_id']),
        title: stringValue(json['title']),
        hlsUrl: stringValue(json['hls_manifest_url']),
        dashUrl: '',
        mp4Url: '',
        videoUrl: stringValue(json['video_url']),
        qualityLabel: 'Auto',
      );
}

class CommentItem {
  const CommentItem({required this.id, required this.username, required this.text, this.createdAt});

  final String id;
  final String username;
  final String text;
  final DateTime? createdAt;

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        id: stringValue(json['id']),
        username: stringValue(json['username'], 'User'),
        text: stringValue(json['text']),
        createdAt: dateValue(json['created_at']),
      );
}

class WatchSession {
  const WatchSession({required this.id, required this.isValidView, required this.secondsWatched});

  final String id;
  final bool isValidView;
  final int secondsWatched;

  factory WatchSession.fromJson(Map<String, dynamic> json) => WatchSession(
        id: stringValue(json['id']),
        isValidView: boolValue(json['is_valid_view']),
        secondsWatched: intValue(json['seconds_watched']),
      );
}

class CreatorEarning {
  const CreatorEarning({required this.id, this.periodStart, this.periodEnd, required this.amountTzs, required this.status, required this.creatorScore});

  final String id;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double amountTzs;
  final String status;
  final double creatorScore;

  factory CreatorEarning.fromJson(Map<String, dynamic> json) => CreatorEarning(
        id: stringValue(json['id']),
        periodStart: dateValue(json['period_start']),
        periodEnd: dateValue(json['period_end']),
        amountTzs: doubleValue(json['amount_tzs']),
        status: stringValue(json['status']),
        creatorScore: doubleValue(json['creator_score']),
      );
}

class PayoutRecord {
  const PayoutRecord({required this.id, required this.amountTzs, required this.status, required this.payoutReference, required this.notes, this.createdAt});

  final String id;
  final double amountTzs;
  final String status;
  final String payoutReference;
  final String notes;
  final DateTime? createdAt;

  factory PayoutRecord.fromJson(Map<String, dynamic> json) => PayoutRecord(
        id: stringValue(json['id']),
        amountTzs: doubleValue(json['amount_tzs']),
        status: stringValue(json['status']),
        payoutReference: stringValue(json['payout_reference']),
        notes: stringValue(json['notes']),
        createdAt: dateValue(json['created_at']),
      );
}

class ReportItem {
  const ReportItem({required this.id, required this.targetType, required this.targetId, required this.reason, required this.description, required this.status, this.createdAt});

  final String id;
  final String targetType;
  final String targetId;
  final String reason;
  final String description;
  final String status;
  final DateTime? createdAt;

  factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
        id: stringValue(json['id']),
        targetType: stringValue(json['target_type']),
        targetId: stringValue(json['target_id']),
        reason: stringValue(json['reason']),
        description: stringValue(json['description']),
        status: stringValue(json['status']),
        createdAt: dateValue(json['created_at']),
      );
}

class AppNotification {
  const AppNotification({required this.id, required this.type, required this.title, required this.body, required this.isRead, this.createdAt});

  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: stringValue(json['id']),
        type: stringValue(json['notification_type']),
        title: stringValue(json['title']),
        body: stringValue(json['body']),
        isRead: boolValue(json['is_read']),
        createdAt: dateValue(json['created_at']),
      );
}
