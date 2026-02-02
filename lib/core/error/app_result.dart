import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_failure.dart';

part 'app_result.freezed.dart';

@freezed
class AppResult<T> with _$AppResult<T> {
  const factory AppResult.success(T data) = _Success<T>;
  const factory AppResult.failure(AppFailure failure) = _Failure<T>;
}
