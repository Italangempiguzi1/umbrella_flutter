class ApiPaths {
  const ApiPaths._();

  static const authRegister = '/auth/register/';
  static const authToken = '/auth/token/';
  static const authRefresh = '/auth/token/refresh/';
  static const authLogout = '/auth/token/logout/';
  static const authMe = '/auth/me/';

  static const creatorMe = '/creators/me/';
  static const creatorDashboard = '/creators/dashboard/';

  static const plans = '/subscriptions/plans/';
  static const currentSubscription = '/subscriptions/current/';
  static const activateDevSubscription = '/subscriptions/activate-dev/';

  static const payments = '/payments/';
  static const paymentInitiate = '/payments/initiate/';

  static const categories = '/content/categories/';
  static const contentItems = '/content/items/';
  static String contentDetail(String id) => '/content/items/$id/';
  static String contentStream(String id) => '/content/items/$id/stream/';
  static String contentSubmit(String id) => '/content/items/$id/submit_for_review/';
  static String contentApprove(String id) => '/content/items/$id/approve/';

  static const reels = '/reels/';
  static const reelsFeed = '/reels/feed/';
  static String reelDetail(String id) => '/reels/$id/';
  static String reelStream(String id) => '/reels/$id/stream/';
  static String reelSubmit(String id) => '/reels/$id/submit_for_review/';
  static String reelApprove(String id) => '/reels/$id/approve/';

  static const likeToggle = '/engagement/likes/toggle/';
  static const votes = '/engagement/votes/';
  static const followToggle = '/engagement/follows/toggle/';
  static const awards = '/engagement/awards/';
  static const comments = '/engagement/comments/';

  static const watchStart = '/analytics/watch/start/';
  static const watchEnd = '/analytics/watch/end/';

  static const earnings = '/rewards/earnings/';
  static const payouts = '/rewards/payouts/';

  static const reports = '/moderation/reports/';
  static const reportCreate = '/moderation/reports/create/';

  static const notifications = '/notifications/';
  static String notificationMarkRead(String id) => '/notifications/$id/mark_read/';
}
