import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../errors/failures.dart';

enum AsyncStatus { idle, loading, success, failure }

@immutable
class AsyncState<T> {
  final AsyncStatus status;
  final T? data;
  final String? error;

  const AsyncState._({required this.status, this.data, this.error});

  const AsyncState.idle() : this._(status: AsyncStatus.idle);

  const AsyncState.loading() : this._(status: AsyncStatus.loading);

  const AsyncState.success(T? data) : this._(status: AsyncStatus.success, data: data);

  const AsyncState.failure(String error) : this._(status: AsyncStatus.failure, error: error);

  bool get isLoading => status == AsyncStatus.loading;
  bool get hasError => status == AsyncStatus.failure;
  bool get isSuccess => status == AsyncStatus.success;
}

class AsyncController<T> {
  final ValueNotifier<AsyncState<T>> state;
  final Future<Either<Failure, T?>> Function() loader;

  AsyncController({required this.loader}) : state = ValueNotifier(const AsyncState.idle());

  Future<void> load() async {
    state.value = const AsyncState.loading();
    final result = await loader();
    state.value = result.fold(
      (failure) => AsyncState.failure(failure.message),
      (data) => AsyncState.success(data),
    );
  }

  void dispose() => state.dispose();
}
