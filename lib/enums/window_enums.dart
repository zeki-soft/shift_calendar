enum WindowEnums {
  all(displayName: '全体表示', value: '0'),
  single(displayName: 'シフト表示', value: '1'),
  ;

  final String displayName;
  final String value;

  const WindowEnums({required this.displayName, required this.value});
}
