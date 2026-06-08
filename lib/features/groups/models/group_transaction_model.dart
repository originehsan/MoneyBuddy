// MoneyBuddy

/// Request model for adding a group expense via /groups/add-expense
class GroupTransactionRequest {
  final String groupId;
  final String description;
  final double amount;
  final String date;

  const GroupTransactionRequest({
    required this.groupId,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'groupId':     groupId,
    'description': description,
    'amount':      amount,
    'date':        date,
  };
}