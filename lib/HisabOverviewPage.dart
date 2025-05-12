import 'dart:async';

import 'package:customtoastflutter/customtoast.dart';
import 'package:flutter/material.dart';
import 'package:hisabkitab/Details.dart';

import 'HiveService.dart';

class HisabOverviewPage extends StatefulWidget {
  @override
  State<HisabOverviewPage> createState() => _HisabOverviewPageState();
}

class _HisabOverviewPageState extends State<HisabOverviewPage> {
  final Color primaryColor = Color(0xFF4B3FEC);

  final Color primaryColor2 = Color(0xFF512DA8);
 // purple
  final Color lightIconBox = Color(0xFFFFF3E6);
 // light orange background
  final Color red = Color(0xFFFF4C61);

  final Color green = Color(0xFF4CD964);
  final hiveService = HiveService();
  late List<Map<dynamic, dynamic>> transactions;
  var namecontroller = TextEditingController();
  double totalgot =0.0;
  double totalgave = 0.0;

  bool loading = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    inithive();
  }

  void inithive() async
  {
    await hiveService.initHive();


    getdata();
  }

  List<Map<String, dynamic>> getUserSummaries() {

    // Get all users from Hive
    final allUsers = hiveService.getAllUsers();

    // Get all transactions from Hive
    final allTransactions = hiveService.getAllTransactions();

     totalgot =0.0;
     totalgave = 0.0;

    // This will store each user's summary
    List<Map<String, dynamic>> userSummaries = [];

    print("all transaction- $allTransactions");

    for(var data in allTransactions)
      {
        totalgot += data["received"];
        totalgave += data["give"];
      }

    // Go through each user
    for (var user in allUsers) {
      int userId = user['id'];


      // Get only this user's transactions
      List userTransactions = allTransactions.where((tx) => tx['userid'] == userId).toList();

      // Total money given
      double totalGiven = 0;
      // Total money received
      double totalReceived = 0;


      print("id wise- $userTransactions");

      // Calculate totals
      for (var tx in userTransactions) {


        if (tx['type'] == 'Give') {
          totalGiven += tx['amount'] ?? 0;

        } else if (tx['type'] == 'Received') {
          totalReceived += tx['amount'] ?? 0;
        }

        print("type- ${tx['type']}   amount- ${tx['amount']} $totalGiven  $totalReceived"  );
      }

      // Add user's summary to the list
      userSummaries.add({
        'id': userId,
        'name': user['name'],
        'give': totalGiven,
        'received': totalReceived,

      });
    }

    return userSummaries;
  }


  void getdata()
  {

    setState(() {
      loading = true;
    });


    transactions =getUserSummaries();

    print("getdata - $transactions");


    setState(() {
      loading = false;
    });

  }


  Future<bool> adddata()
  async {

    // final newTransactiondemo = {
    //   'name': namecontroller.text,
    //   'type': 'new', // or 'income'
    //
    //   'give': 0.0,
    //   'received': 0.0,
    //   'title': '',
    //   'description': '',
    //   'date': DateTime.now().toString(),
    //   'category': '',
    //   'balanceAfterTransaction': 0.0,
    //   'paymentMethod': '',
    //   'isSettled': false,
    //   'tags': <String>[],
    // };

    final newTransactiondemo = {
      'name': namecontroller.text,
    };

    hiveService.addUser(newTransactiondemo);

    return true;
  }



  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final totalUsers = 2;
    final totalGive = 200;
    final totalReceive = 300;

    final netBalance = totalgot - totalgave;
    final netLabel = netBalance > 0 ? "You owe" : netBalance < 0 ? "You will receive" : "Settled";

    final users = [
      {'name': 'Ramesh', 'give': 500.0, 'receive': 0.0},
      {'name': 'Suresh', 'give': 0.0, 'receive': 1000.0},
      {'name': 'Anita', 'give': 1000.0, 'receive': 1000.0},
    ];





    void showAddDialog() async {
      await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: lightIconBox,
              contentPadding: EdgeInsets.all(20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      "Add Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: red,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Input field for User/Transaction Type
                  TextFormField(
                    controller: namecontroller,
                    decoration: InputDecoration(
                      labelText: 'Add User / Transaction Type',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: red),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Padding inside text field
                    ),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submission
                        if (namecontroller.text.isEmpty) {
                          FlutterCustomToast.showToast(
                            context: context,
                            message: "Please enter username",
                            backgroundColor: red,
                            textStyle: TextStyle(fontSize: 14, color: Colors.white),
                          );
                        } else {
                          adddata().then((value) {
                            if (value) {
                              Navigator.pop(context);
                              namecontroller.text = "";
                              getdata();
                              Future.delayed(Duration(milliseconds: 1)).then((value) {

                              });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3, // Add shadow to the button
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }




    return Scaffold(

    floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text(
          "Add User",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor2, // Use your primary color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        onPressed: showAddDialog),

      body: SafeArea(
        child:loading ? Center(child: CircularProgressIndicator(color: red,)) :  Column(

          children: [

            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(8, 0, 8, 20),
              padding: EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryColor2,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "💰 Hisab Manager",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 26, vertical: 0),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightIconBox,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){

                      final newTransaction = {

                        'title': 'New Expendwdwdwe',
                        'amount': 100.0,

                      };

                      hiveService.addTransaction(newTransaction);



                     // hiveService.clearAllTransactions();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        overviewTile("Total Users", "${transactions.length}", Icons.people, iconBg: primaryColor),
                        overviewTile("You Gave", "₹$totalgave", Icons.arrow_upward, iconBg: red),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: (){

                      //hiveService.printAllTransactions();

                     // var data = hiveService.getAllTransactions();
                     // print("before- $data");
                     //
                     // var idata = hiveService.getTransactionById(data[2]["id"]);
                     // idata!["title"] = "lllll";
                     //  print("after by id - $idata" );
                     //
                     // hiveService.updateTransaction( idata!["id"], idata);
                     print("all dta - ${hiveService.getAllTransactions()}");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        overviewTile("You Got", "₹$totalgot", Icons.arrow_downward, iconBg: green),
                        overviewTile("$netLabel", "₹${netBalance.abs()}", Icons.account_balance_wallet, iconBg: netBalance > 0 ? red : netBalance < 0 ? green : primaryColor2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // User list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 80),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final user = transactions[index];
                  final name = user['name'];
                  final gave = user['give'] ?? 0;
                  final got = user['received'] ?? 0;
                  final balance = gave - got;

                  print("give- $gave received- $got");

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Details(data: user)),
                      ).then((value) {
                        getdata();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: primaryColor2.withOpacity(0.15),
                          child: Text(
                            name.toString()[0],
                            style: TextStyle(
                              color: primaryColor2,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          name.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black
                          ),
                        ),
                        subtitle: Text(
                          balance > 0 ? "You will receive" :   balance < 0 ? "You owe" : "Settled",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "₹${balance.abs()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: balance >= 0 ? green : red,

                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget overviewTile(String title, String value, IconData icon, {required Color iconBg}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconBg, size: 24),
        ),
        SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }
}