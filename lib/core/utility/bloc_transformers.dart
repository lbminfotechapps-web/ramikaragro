import 'dart:async';

import 'package:bloc/bloc.dart';

EventTransformer<E> debounceRestartable<E>(
  Duration duration,
) {
  return (
    events,
    mapper,
  ) {
    return events
        .debounce(duration)
        .switchMap(mapper);
  };
}

extension DebounceExtension<T>
    on Stream<T> {
  Stream<T> debounce(
    Duration duration,
  ) {
    Timer? timer;

    late StreamController<T>
        controller;

    controller =
        StreamController<T>(
      sync: true,

      onListen: () {
        final subscription =
            listen(
          (event) {
            timer?.cancel();

            timer =
                Timer(
              duration,
              () {
                controller.add(
                  event,
                );
              },
            );
          },

          onError:
              controller.addError,

          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );

        controller.onCancel =
            () async {
          timer?.cancel();
          await subscription.cancel();
        };
      },
    );

    return controller.stream;
  }

  Stream<R> switchMap<R>(
    Stream<R> Function(T value)
        mapper,
  ) {
    late StreamController<R>
        controller;

    StreamSubscription<T>?
        outer;

    StreamSubscription<R>?
        inner;

    controller =
        StreamController<R>(
      sync: true,

      onListen: () {
        outer =
            listen(
          (value) async {
            await inner?.cancel();

            inner =
                mapper(
              value,
            ).listen(
              controller.add,
              onError:
                  controller.addError,
            );
          },

          onError:
              controller.addError,

          onDone: () async {
            await inner?.cancel();
            await controller.close();
          },
        );
      },

      onCancel: () async {
        await outer?.cancel();
        await inner?.cancel();
      },
    );

    return controller.stream;
  }
}