import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class HiveService {
  late Box<Map<dynamic, dynamic>> userBox;
  late Box<Map<dynamic, dynamic>> transactionBox;

  // Initialize Hive
  Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    userBox = await Hive.openBox<Map<dynamic, dynamic>>('users');
    transactionBox = await Hive.openBox<Map<dynamic, dynamic>>('transactions');
  }

  // Add a user
  Future<void> addUser(Map<String, dynamic> user) async {
    await userBox.add(user);
    print("User added: $user");
  }


  // Get all users
  List<Map<dynamic, dynamic>> getAllUsers() {
    return userBox.toMap().entries.map((entry) {
      final user =Map<String, dynamic>.from(entry.value);
      user['id'] = entry.key;
      return user;
    }).toList();
  }


  // Add a transaction
  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    await transactionBox.add( transaction);
    print("Transaction added: $transaction");
  }

  // Get all transactions
  List<Map<dynamic, dynamic>> getAllTransactions() {
    return transactionBox.toMap().entries.map((entry) {
      final transaction = entry.value;
      transaction['id'] = entry.key;
      return transaction;
    }).toList();
  }

  // Get transaction by ID
  Map<dynamic, dynamic>? getTransactionById(int id) {
    return transactionBox.get(id);
  }

  // List<Map<dynamic, dynamic>> getTransactionsByUserId(int userid) {
  //   return transactionBox.values
  //       .where((element) => element['userid'] == userid)
  //       .cast<Map<dynamic, dynamic>>()
  //       .toList();
  // }


  List<Map<String, dynamic>> getTransactionsByUserId(int userid) {
    final Map<dynamic, dynamic> allTx = transactionBox.toMap();

    return allTx.entries
        .where((entry) => entry.value['userid'] == userid)
        .map((entry) {
      final tx = Map<String, dynamic>.from(entry.value);
      tx['id'] = entry.key; // Add Hive auto-generated ID
      return tx;
    })
        .toList();
  }


  // Delete transaction
  Future<void> deleteTransaction(int id) async {
    await transactionBox.delete(id);
  }

  // Update transaction
  Future<void> updateTransaction(int id, Map<dynamic, dynamic> transaction) async {
    await transactionBox.put(id, transaction);
  }

  // Clear all transactions
  Future<void> clearAllTransactions() async {
    await userBox.clear();
    await transactionBox.clear();
  }



  // Delete a user
  Future<void> deleteUser(int id) async {
    await userBox.delete(id);
  }

  // Get user with transaction summary (simple version)
  List<Map<String, dynamic>> getUserSummaries() {
    final users = getAllUsers();
    final transactions = getAllTransactions();

    List<Map<String, dynamic>> userSummaries = [];

    for (var user in users) {
      final userId = user['id'];

      final userTransactions = transactions
          .where((tx) => tx['userId'] == userId)
          .toList();

      double totalGiven = 0;
      double totalReceived = 0;

      for (var tx in userTransactions) {
        if (tx['type'] == 'give') {
          totalGiven += tx['amount'] ?? 0;
        } else if (tx['type'] == 'recive') {
          totalReceived += tx['amount'] ?? 0;
        }
      }

      userSummaries.add({
        'id': userId,
        'name': user['name'],
        'totalGiven': totalGiven,
        'totalReceived': totalReceived,
        'balance': totalReceived - totalGiven,
      });
    }

    return userSummaries;
  }

  // For demo
  final newTransactiondemo = {
    'userId': 0, // make sure to set correct userId when using
    'type': 'expense',
    'title': 'Groceries',
    'amount': 150.0,
    'description': 'Purchased groceries for the week.',
    'date': DateTime.now().toString(),
    'category': 'Food',
    'balanceAfterTransaction': 350.0,
  };
}
