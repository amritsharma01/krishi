//Centralization of Assets

class _AssetsImagesGen {
  const _AssetsImagesGen();
  static const _imagePath = "${Assets._basePath}/images";

  String get logo => "$_imagePath/logo.png";
  String get logo2 => "$_imagePath/logo2.png";
}

class Assets {
  Assets._();
  static const _basePath = "assets";
  static const images = _AssetsImagesGen();
}
