
/// Currently supported brands by this plugin.
///  /// Brands Names [ VISA , MASTER , MADA , STC_PAY , APPLEPAY]
enum BrandType {
  visa,

  master,

  mada,

  applepay,
  STC_PAY,

  /// If no brand is chosen, use none to avoid
  /// any unnecessary errors.
  none,
}
