/// Centralized static text dictionary for the application.
/// Controls all UI strings, labels, validation messages, button text, and dialog copy.
class AppStrings {
  AppStrings._();

  // ── Application Identity ────────────────────────────
  static const String appName = 'ExpertMentor';
  static const String appTagline = 'Connect with Industrial & Engineering Experts';
  static const String poweredBy = 'Powered by Industrial Mentorship Network';

  // ── Roles ───────────────────────────────────────────
  static const String roleLearner = 'Learner';
  static const String roleExpert = 'Expert';
  static const String roleAdmin = 'Admin';
  static const String loginAs = 'Login as';
  static const String registerAs = 'Register as';
  static const String switchRole = 'Switch Role';
  static const String switchToLearner = 'Switch to Learner View';
  static const String switchToExpert = 'Switch to Expert View';
  static const String switchToLearnerDashboard = 'Switch to Learner Dashboard';
  static const String switchToExpertDashboard = 'Switch to Expert Dashboard';

  // ── Common Actions & Buttons ────────────────────────
  static const String login = 'Login';
  static const String signIn = 'Sign In';
  static const String register = 'Register';
  static const String signUp = 'Create Account';
  static const String logout = 'Logout';
  static const String continueText = 'Continue';
  static const String continueWithGoogle = 'Continue with Google';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String save = 'Save Changes';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String retry = 'Retry';
  static const String search = 'Search';
  static const String viewAll = 'View All';
  static const String seeMore = 'See More';
  static const String getStarted = 'Get Started';
  static const String skip = 'Skip';

  // ── Authentication Screens ──────────────────────────
  static const String welcomeBack = 'Welcome Back';
  static const String signInSubtitle = 'Sign in to continue your learning journey';
  static const String createAccountTitle = 'Create Account';
  static const String createAccountSubtitle = 'Connect with top industrial experts today';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordSubtitle =
      'Enter your registered email to receive a password reset link';
  static const String resetPassword = 'Reset Password';
  static const String otpVerification = 'OTP Verification';
  static const String enterOtpPrompt = 'Enter the 6-digit code sent to your email';
  static const String resendOtp = 'Resend Code';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String orDivider = 'OR';

  // ── Form Field Labels & Hints ───────────────────────
  static const String labelEmail = 'Email';
  static const String hintEmail = 'Enter your email';
  static const String labelPassword = 'Password';
  static const String hintPassword = 'Enter your password';
  static const String labelConfirmPassword = 'Confirm Password';
  static const String hintConfirmPassword = 'Re-enter your password';
  static const String labelFullName = 'Full Name';
  static const String hintFullName = 'Enter your full name';
  static const String labelPhoneNumber = 'Phone Number';
  static const String hintPhoneNumber = 'Enter 10-digit mobile number';

  // ── Navigation & Tabs ───────────────────────────────
  static const String tabDashboard = 'Dashboard';
  static const String tabSessions = 'Sessions';
  static const String tabMessages = 'Messages';
  static const String tabEarnings = 'Earnings';
  static const String tabProfile = 'Profile';
  static const String tabCommunity = 'Community';
  static const String tabRoadmap = 'Roadmap';
  static const String tabExperts = 'Explore Experts';
  static const String tabNotifications = 'Notifications';

  // ── Dashboard Sections ──────────────────────────────
  static const String expertDashboardTitle = 'Expert Dashboard';
  static const String learnerDashboardTitle = 'Learner Dashboard';
  static const String overview = 'Overview';
  static const String upcomingSessions = 'Upcoming Sessions';
  static const String pastSessions = 'Past Sessions';
  static const String recentMentors = 'Recent Mentors';
  static const String quickActions = 'Quick Actions';
  static const String earningsOverview = 'Earnings Overview';
  static const String activeLearners = 'Active Learners';
  static const String myBookings = 'My Bookings';
  static const String bookSession = 'Book Session';

  // ── Bookings & Payments ─────────────────────────────
  static const String bookingSummary = 'Booking Summary';
  static const String sessionType = 'Session Type';
  static const String duration = 'Duration';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String amount = 'Amount';
  static const String totalAmount = 'Total Amount';
  static const String payNow = 'Pay Now';
  static const String paymentSuccess = 'Payment Successful';
  static const String paymentFailed = 'Payment Failed';
  static const String bookingConfirmed = 'Booking Confirmed!';

  // ── Validation Messages ─────────────────────────────
  static const String errorFieldRequired = 'This field is required';
  static const String errorInvalidEmail = 'Please enter a valid email address';
  static const String errorPasswordLength = 'Password must be at least 6 characters';
  static const String errorPasswordMismatch = 'Passwords do not match';
  static const String errorFillAllFields = 'Please fill in all required fields';
  static const String errorSomethingWentWrong = 'Something went wrong. Please try again.';
  static const String errorNetworkIssue = 'Network error. Please check your internet connection.';

  // ── Empty States & Placeholders ─────────────────────
  static const String noSessionsFound = 'No sessions scheduled yet';
  static const String noNotificationsFound = 'No new notifications';
  static const String noMessagesFound = 'No conversations started yet';
  static const String noExpertsFound = 'No experts found matching your criteria';
  static const String noRoadmapFound = 'Generate your AI roadmap to get started';
}
