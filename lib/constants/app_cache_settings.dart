class AppCacheSettings {
  //vendor types listing (home/welcome screen) - 4 hours
  static const int vendorTypesTtlMinutes = 4 * 60;

  //categories listing - 24 hours
  static const int categoriesTtlMinutes = 24 * 60;

  //banners (home/vendor type screens) - 12 hours
  static const int bannersTtlMinutes = 12 * 60;

  //single vendor details ("show" endpoint), including checkout - 15 minutes
  static const int vendorDetailsTtlMinutes = 15;

  //wallet transactions, first page only - 30 minutes
  static const int walletTransactionsTtlMinutes = 30;

  static Duration get vendorTypesTtl =>
      Duration(minutes: vendorTypesTtlMinutes);
  static Duration get categoriesTtl => Duration(minutes: categoriesTtlMinutes);
  static Duration get bannersTtl => Duration(minutes: bannersTtlMinutes);
  static Duration get vendorDetailsTtl =>
      Duration(minutes: vendorDetailsTtlMinutes);
  static Duration get walletTransactionsTtl =>
      Duration(minutes: walletTransactionsTtlMinutes);
}
