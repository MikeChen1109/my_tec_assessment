class RoomPricing {
  const RoomPricing({
    required this.roomCode,
    required this.bestPricingStrategyName,
    required this.initialPrice,
    required this.finalPrice,
    required this.currencyCode,
    required this.isPackageApplicable,
  });

  final String roomCode;
  final String bestPricingStrategyName;
  final num initialPrice;
  final num finalPrice;
  final String currencyCode;
  final bool isPackageApplicable;
}
