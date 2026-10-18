import 'package:el_karma_ph/features/team/presentation/view/team_list_page.dart';
import 'package:flutter/material.dart';

class TestDataMenu extends StatelessWidget {
  const TestDataMenu({super.key, required this.onSelected});

  final ValueChanged<TestDataAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TestDataAction>(
      tooltip: 'Test data',
      icon: const Icon(Icons.more_vert),
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: TestDataAction.add10,
          child: Text('Add 10 members'),
        ),
        PopupMenuItem(
          value: TestDataAction.add50,
          child: Text('Add 50 members'),
        ),
        PopupMenuItem(
          value: TestDataAction.add200,
          child: Text('Add 200 members'),
        ),
        PopupMenuItem(
          value: TestDataAction.deleteAll,
          child: Text('Delete all members'),
        ),
      ],
    );
  }
}
