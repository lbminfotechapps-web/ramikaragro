class ApiClient {
  static const String baseUrl =
      "http://192.168.1.253:85/ramikar_agro/mobileapi/Mobile_app_for_businessplus_kotlin_new";
  static const String imageBaseUrl =
      "http://192.168.1.253:85/ramikar_agro/uploads/";
  static const String imageGalleryUrl =
      "http://192.168.1.253:85/ramikar_agro/uploads/gallery/";
  static const String login = "/user_login";
  static const String getLastThirtyNotVisited = "/getLastThiertyNotVisited";
  static const String getNearByOutlets = "/getNearByOutlets";
  static const String userMenu = "/getUserMenu_new";
  static const String punchStatus = "/getLastTransactionInOutStatus";
  static const String getEmployeeActivityDetails =
      '/getEmployeeActivityDetails_new';

  static const String getVisitReportDetails = "/getVisitReportDetails";
  static const String getEmployeeOutputReport = "/getEmployeeOutputReport";
  // ApiConfig.getEmployeeUrl() was using.
  static const String getEmployees = "/getAssignedEmployees";
  static const String organizationDetails = "/getOrganizationDetails";
  static const String getNotificationList = "/getNotificationList";

  static const String getMyLeaveList = "/getMyLeaveList";
  static const String addLeave = "/addLeave";
  static const String punchAddInOut = "/add_in_out_details";
  static const String getVehicleType = "/getVehicleType";
  static const String getGalleryDetails = "/getGalleryDetails";
  static const String getSchemedetails = "/getSchemes";
  static const String getTopTenDealerVisit = "/getHighestTopDealer";
  static const String getSocialMedia = "/getSocialMedia";
  static const String getMyEmployeeLeaveList = "/getMyEmployeeLeaveList";
  static const String updateLeaveStatus = "/updateLeaveStatus";
  static const String visitCountgraph = "/getEmployeevisitcount";
  static const String getState = "/get_state";
  static const String submitPaymentDetails = "/submitPaymentDetails";

  static const String getBankDetails = "/getBankDetails";
  static const String getTalukaWiseOutletForOrderNew =
      "/getTalukaWiseOutletForOrderNew";
  static const String getCategoryproductDetails =
      "/get_category_product_details";
  static const String getCollectionList = "/getCollectionList";
  static const String getCollectionWiseTarget = '/getCollectionWiseTarget';
  static const String getTargetDates = '/getTargetDates';
  static const String getCropsSchedule = '$baseUrl/getCropsSchedule';
  static const String getEmployeeVisitCount = '$baseUrl/getVisitCount';
}
