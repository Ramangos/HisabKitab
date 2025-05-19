import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'HiveService.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customtoastflutter/customtoast.dart';
import 'package:hisabkitab/Global.dart';


class Details extends StatefulWidget {

  var data;
   Details({super.key, this.data});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final Color primaryColor = Color(0xFF4B3FEC);

  final Color primaryColor2 = Color(0xFF512DA8);
  // purple
  final Color lightIconBox = Color(0xFFFFF3E6);
  // light orange background
  final Color red = Color(0xFFFF4C61);

  final Color green = Color(0xFF4CD964);
  final hiveService = HiveService();
 // late List<Map<dynamic, dynamic>> transactions;
  var namecontroller = TextEditingController();
  
  String selectedType = 'Give'; // 'Give' or 'Received'
  var titlecontroler = TextEditingController();
  var descriptioncontroller = TextEditingController();
  var amountcontroller  = TextEditingController();
  double totalgot =0.0;
  double totalgave = 0.0;
  double balance = 0.0;
  String label = '';
  bool? confirmDelete = false;
 




  String title = '';
  String description = '';
  double amount = 0.0;
  
  List txlist  = [];

  bool loading = true;

  final transactions = [
    {
      'title': 'Dinner at cafe',
      'description': 'Paid for friends',
      'amount': 250.0,
      'type': 'give',
    },
    {
      'title': 'Refund from Aman',
      'description': 'Got refund for snacks',
      'amount': 100.0,
      'type': 'recive',
    },
  ];

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

  void getdata()
  {
    print("user id ==> ${widget.data["id"]}");

    txlist = hiveService.getTransactionsByUserId(widget.data["id"]);

    totalgot =0.00;
    totalgave = 0.00;

    for(var data in txlist)
      {
        totalgot += data["received"];
        totalgave += data["give"];
      }

    balance = totalgot -totalgave;
    label =  balance > 0  ? "You owe" : balance < 0 ? "You will receive" : "Settled";

    setState(() {
      loading = false;
    });

    print(txlist);
  }

  Future<void> addtransaction({required int userid,
    required String type,
    required String title,
    required String description,
    required String date,
    required String category,
    required double amount,
    required double balance,
    required bool isSettled}) async
  {

  final newTransactiondemo = {
      'userid': userid,
      'type': type, // or 'income'
      'title': title,
      'description': description,
      'date': date,
      'category': category,
      'give': type == "Give" ? amount : 0.0,
      'received': type == "Give" ? 0.0 : amount,
      'amount': amount ,
      'balance': balance,
      'isSettled': isSettled,

    };


   await hiveService.addTransaction(newTransactiondemo);
  }


  void showdialog()
  {

    showDialog(context: context, builder: (context) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with background
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: selectedType.contains("Give") ?  red : green, // You can customize this
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  'Add Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Form content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  TextFormField(
                    controller: titlecontroler,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  
                  ),
                  SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: descriptioncontroller,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  
                  ),
                  SizedBox(height: 12),

                  // Type Dropdown (Give / Received)
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: ['Give', 'Received']
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      selectedType = value!;
                    }),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Amount
                  TextFormField(
                    controller: amountcontroller,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [

                     FilteringTextInputFormatter.digitsOnly
                    ],
                   
                  ),
                  SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {

                      if( amountcontroller.text.isEmpty)
                        {
                          FlutterCustomToast.showToast(context: context, message: "Please enter amount", textStyle: TextStyle(fontSize: 14, color: Colors.white), backgroundColor: red);
                        }
                      else
                        {
                          addtransaction(userid: widget.data["id"], type: selectedType, title: titlecontroler.text, description: descriptioncontroller.text, date: DateTime.now().toString(), category: "", amount: double.parse(amountcontroller.text), balance: 0.0, isSettled: false).then((value) {
                            Navigator.pop(context);
                            titlecontroler.text = "";
                            descriptioncontroller.text = "";
                            amountcontroller.text = "";
                            getdata();
                          },);
                        }

                    },
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:selectedType.contains("Give") ?  red : green,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

    },),);



  }


  String datafromat(String dateString )
  {
    try
    {
      DateTime parsedDate = DateTime.parse(dateString);
      String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
      return formattedDate;
    }catch(e)
    {
      return "N/A";
    }




  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text(
            "Add Transaction",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryColor2, // Use your primary color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          onPressed: (){

        showdialog();
      }),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        title: Text(
          "Transaction Details",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,

      ),

      body: SafeArea(
        child: loading ? Center(child: CircularProgressIndicator(color: red,))
            : Column(
          children: [
            // Top detail box
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [red.withOpacity(0.95), red.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Text(
                    widget.data["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "$label ₹${balance.abs()}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        detailTile("Total", "₹${totalgave + totalgot}"),
                        detailTile("Given", "₹$totalgave"),
                        detailTile("Received", "₹$totalgot"),
                      ],
                    ),
                  ),
                ],
              ),
            ),



            txlist.isEmpty ? Global.nodata() :  Expanded(
              child: ListView.builder(
                itemCount: txlist.length,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 80),

                itemBuilder: (context, index) {
                  final tx = txlist[index];
                  final isGive = tx['type'] == 'Give';

                  return Dismissible(
                      key: Key(tx['id'].toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (DismissDirection direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: const Text(
                                    "Are you sure you want to delete this item?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      hiveService.deleteTransaction(tx["id"]).then((value) {
                                        getdata();
                                      },);

                                      print(tx["id"]);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        else {
                          return false;
                        }
                      },


                      background: Container(
                        color: Colors.red, // Background color when swiped
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 16),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),

                      child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: isGive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          child: Icon(
                            isGive ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isGive ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Padding(padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                           "${tx['title'].toString() } ${tx["id"]}"   ,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['description'].toString() ,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  datafromat(tx['date'].toString()),
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),


                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              "₹${tx['amount'] }",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isGive ? Colors.red : Colors.green,
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isGive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tx['type'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isGive ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],)
                    ),
                  ));
                },
              ),
            )



          ],
        )

      ),
    );
  }

  Widget detailTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

}

