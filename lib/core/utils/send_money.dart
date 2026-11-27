String localMobile(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('0020')) d = d.substring(4);
  if (d.startsWith('20') && d.length == 12) d = d.substring(2);
  if (d.length == 10 && d.startsWith('1')) d = '0$d';
  return d;
}

String plainAmount(double v) =>
    v % 1 == 0 ? '${v.toInt()}' : v.toStringAsFixed(2);
