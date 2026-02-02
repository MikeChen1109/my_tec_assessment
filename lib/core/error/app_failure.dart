import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.network({String? message}) = _NetworkFailure;
  const factory AppFailure.server({int? statusCode, String? message}) =
      _ServerFailure;
  const factory AppFailure.decoding({String? message}) = _DecodingFailure;
  const factory AppFailure.unknown({String? message}) = _UnknownFailure;
}
