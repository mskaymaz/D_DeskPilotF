enum ZLayer {
  base(0),
  surface(1),
  elevated(2),
  overlay(3),
  dialog(4),
  snackbar(5),
  tooltip(6),
  modal(7);

  final int value;
  const ZLayer(this.value);
}

class AppZLayers {
  static const double base = 0.0;
  static const double surface = 1.0;
  static const double elevated = 2.0;
  static const double overlay = 3.0;
  static const double dialog = 4.0;
  static const double snackbar = 5.0;
  static const double tooltip = 6.0;
  static const double modal = 7.0;

  AppZLayers._();
}
