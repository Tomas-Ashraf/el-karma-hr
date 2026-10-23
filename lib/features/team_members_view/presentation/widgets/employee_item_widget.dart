class EmployeeItem {
  const EmployeeItem({
    required this.name,
    required this.job,
    required this.isActive,
  });

  final String name;
  final String job;
  final bool isActive;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts[0][0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }
}

const sampleEmployees = <EmployeeItem>[
  EmployeeItem(name: 'Mina Samy', job: 'Pharmacist', isActive: true),
  EmployeeItem(name: 'Sara Adel', job: 'Cashier', isActive: true),
  EmployeeItem(name: 'Ahmed Hany', job: 'Delivery', isActive: true),
  EmployeeItem(name: 'Mariam Nabil', job: 'Pharmacist', isActive: true),
  EmployeeItem(name: 'Omar Khaled', job: 'Storekeeper', isActive: false),
  EmployeeItem(name: 'Nour Ashraf', job: 'Cashier', isActive: true),
  EmployeeItem(name: 'Youssef Magdy', job: 'Delivery', isActive: true),
  EmployeeItem(name: 'Hana Tarek', job: 'Pharmacist', isActive: false),
];
