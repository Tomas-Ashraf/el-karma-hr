enum PaymentMethod {
  cash('Cash'),
  bankTransfer('Bank transfer'),
  wallet('Wallet');

  const PaymentMethod(this.label);
  final String label;

  static PaymentMethod fromLabel(String label) =>
      values.firstWhere((e) => e.label == label);
}

enum EmployeeStatus {
  active('Active'),
  inactive('Inactive'),
  onLeave('On leave');

  const EmployeeStatus(this.label);
  final String label;

  static EmployeeStatus fromLabel(String label) =>
      values.firstWhere((e) => e.label == label);
}

enum UserType {
  employee('Employee'),
  supervisor('Supervisor'),
  admin('Admin');

  const UserType(this.label);
  final String label;

  static UserType fromLabel(String label) =>
      values.firstWhere((e) => e.label == label);
}
