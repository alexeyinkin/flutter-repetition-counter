import 'dart:collection';

class CircularBuffer<T> extends ListBase<T> {
  final List<T> _source;
  int _head = 0; // The index of the NEWEST value

  CircularBuffer(this._source);

  static CircularBuffer<List<T>> ofLists<T>(
    int itemCount,
    int itemLength,
    T fill,
  ) => CircularBuffer([
    for (int i = itemCount; --i >= 0;)
      List<T>.filled(itemLength, fill, growable: false),
  ]);

  @override
  int get length => _source.length;

  @override
  T operator [](int index) {
    int realIndex = _head - index;

    if (realIndex < 0) {
      realIndex += _source.length;
    }
    return _source[realIndex];
  }

  @override
  void operator []=(int index, T value) {
    throw UnsupportedError("No random writes");
  }

  @override
  set length(int newLength) {
    throw UnsupportedError("This list is not growable");
  }

  @override
  T add(T element) {
    _head = (_head + 1) % length;
    final old = _source[_head];
    _source[_head] = element;
    return old;
  }

  @override
  T removeLast() {
    final result = _source[_head];
    _head = (_head - 1) % length;
    return result;
  }

  List<T> shallowCopyList() => List.of(this);
}
