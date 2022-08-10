extension ListExtensions<E> on Iterable<E> {
  List<E> withBetween(E separation) {
    return [
      ...take(1),
      ...skip(1).expand((e) => [separation, e]).toList(),
    ];
  }
}
