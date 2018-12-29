import 'dart:async';

import 'package:meta/meta.dart';

import '../../models/base/keyed_list_item.dart';
import 'observable_keyed_list.dart';

/// Base class for objects that process incoming events, build and update their
/// internal [list] based on these events or external factors, and notify the
/// subscribers about changes they made to [list].
abstract class KeyedListEventProcessor<TElement extends KeyedListItem,
    TInputEvent> {
  /// A list reflecting the current state of this KeyedListEventProcessor.
  /// Modify this list in processEvent() method or in response to external
  /// factors, to automatically notify subscribers about changes.
  @protected
  ObservableKeyedList<TElement> list;

  /// Events generated by this processor. See [ObservableKeyedList].
  Stream<ListEvent<TElement>> get events => _outgoingEventsController.stream;
  // This object should exist while there is at least one listener. The eventual
  // listeners are normally UI components, and will unsubscribe when gone (e.g.
  // in Flutter that would be dispose()).
  // ignore: close_sinks
  StreamController<ListEvent<TElement>> _outgoingEventsController;

  /// Current value of the list composed by this processor. See
  /// [ObservableKeyedList.value].
  List<TElement> get value => list.value;

  /// A subscription to input events. The processor automatically subscribes to
  /// the [source] stream when a listener is attached to this processor's
  /// [events] stream, and unsubscribes when the last listener is gone.
  // We cancel this subscription in onCancel of the outgoing events stream.
  // ignore: cancel_subscriptions
  StreamSubscription<TInputEvent> _inputEventsSubscription;

  /// The source of inbound events that this processor handles while there is
  /// at least one subscriber active on the [events] stream.
  final StreamGetter<TInputEvent> source;

  KeyedListEventProcessor(this.source) {
    _outgoingEventsController = StreamController<ListEvent<TElement>>.broadcast(
        onListen: () =>
            // Do not close _outgoingEventsController on source.onDone because
            // the source is renewable (it's a StreamGetter) and may resume when
            // listeners resubscribe to this processor.
            _inputEventsSubscription = source().listen(processEvent),
        onCancel: _inputEventsSubscription?.cancel,
        // Has to be synchronous to wait for all subscribers to process one
        // event before the underlying list changes in response to the next one.
        sync: true);
    list = ObservableKeyedList<TElement>(_outgoingEventsController.sink);
  }

  /// Process input [event] and update [list] accordingly, which will notify
  /// processor listeners via [events].
  @protected
  void processEvent(TInputEvent event);
}
