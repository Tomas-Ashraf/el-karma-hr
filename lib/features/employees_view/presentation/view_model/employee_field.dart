import 'package:flutter/material.dart';

/// Every value of an employee, in display order.
/// [options] is non-null for fields picked from a fixed list.
enum EmployeeField {
  name('Name'),
  email('Email'),
  job('Job'),
  phone('Phone number'),
  paymentMethod('Payment method', ['Cash', 'Bank transfer', 'Wallet']),
  salary('Salary'),
  deviceId('Device ID'),
  shift('Shift 1 period'),
  status('Status', ['Active', 'Inactive', 'On leave']),
  userType('User type', ['Employee', 'Supervisor', 'Admin']);

  const EmployeeField(this.label, [this.options]);

  final String label;
  final List<String>? options;

  TextInputType get keyboardType => switch (this) {
        email => TextInputType.emailAddress,
        phone => TextInputType.phone,
        salary => TextInputType.number,
        _ => TextInputType.text,
      };
}
