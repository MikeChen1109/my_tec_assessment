import '../../domain/entities/room_pricing.dart';

class RoomPricingModel extends RoomPricing {
  const RoomPricingModel({
    required super.roomCode,
    required super.bestPricingStrategyName,
    required super.initialPrice,
    required super.finalPrice,
    required super.currencyCode,
    required super.isPackageApplicable,
  });

  factory RoomPricingModel.fromJson(Map<String, dynamic> json) {
    return RoomPricingModel(
      roomCode: json['roomCode'] as String? ?? '',
      bestPricingStrategyName: json['bestPricingStrategyName'] as String? ?? '',
      initialPrice: json['initialPrice'] as num? ?? 0,
      finalPrice: json['finalPrice'] as num? ?? 0,
      currencyCode: json['currencyCode'] as String? ?? '',
      isPackageApplicable: json['isPackageApplicable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomCode': roomCode,
      'bestPricingStrategyName': bestPricingStrategyName,
      'initialPrice': initialPrice,
      'finalPrice': finalPrice,
      'currencyCode': currencyCode,
      'isPackageApplicable': isPackageApplicable,
    };
  }
}
