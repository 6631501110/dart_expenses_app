// for http connection
import 'package:http/http.dart' as http;
import 'dart:convert';
// for stdin
import 'dart:io';

void main() async {
  print("===== Login =====");

  // Get username and password
  stdout.write("Username: ");
  String? username = stdin.readLineSync()?.trim();
  stdout.write("Password: ");
  String? password = stdin.readLineSync()?.trim();

  if (username == null || password == null) {
    print("Incomplete input");
    return;
  }

  final loginBody = {"username": username, "password": password};
  final loginUrl = Uri.parse('http://localhost:3000/login');

  final loginResponse = await http.post(
    loginUrl,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(loginBody),
  );

  if (loginResponse.statusCode == 200) {
    try {
      final result = json.decode(loginResponse.body);
      print(result["message"]); // "Login OK"
      int userId = result["userId"]; // capture userId

      // Menu loop
      while (true) {
        print("\n========= Expense Tracking App ========");
        print("1. Show all expenses");
        print("2. Today's expenses");
        print("3. search expenses");
        print("4. Add new expense");
        print("5. Delete expense");
        print("6. Exit");
        stdout.write("Choose... ");
        String? choice = stdin.readLineSync()?.trim();

        if (choice == null || choice.isEmpty) {
          print("Invalid choice");
          continue;
        }

        // ---------------- Show all ----------------
        if (choice == '1') {
          final allExpensesUrl = Uri.parse(
            'http://localhost:3000/expenses/$userId',
          );
          final response = await http.get(allExpensesUrl);

          if (response.statusCode == 200) {
            final jsonResult =
                json.decode(response.body) as List<dynamic>;
            int total = 0;
            print("-------------All Expenses---------");
            for (var exp in jsonResult) {
              final dt = DateTime.tryParse(exp['date'].toString());
              final dtLocal = dt?.toLocal();
              print(
                "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
              );
              total += int.tryParse(exp['paid'].toString()) ?? 0;
            }
            print("Total expenses = $total฿");
          } else {
            print("Failed to fetch all expenses");
          }

        // ---------------- Today's expenses ----------------
        } else if (choice == '2') {
          final todayExpensesUrl = Uri.parse(
            'http://localhost:3000/expenses/$userId/today',
          );
          final response = await http.get(todayExpensesUrl);

          if (response.statusCode == 200) {
            final jsonResult =
                json.decode(response.body) as List<dynamic>;
            int total = 0;
            print("------------Today's Expenses-----------");
            for (var exp in jsonResult) {
              final dt = DateTime.tryParse(exp['date'].toString());
              final dtLocal = dt?.toLocal();
              print(
                "${exp['id']}. ${exp['item']} : ${exp['paid']}฿ @ ${dtLocal ?? exp['date']}",
              );
              total += int.tryParse(exp['paid'].toString()) ?? 0;
            }
            print("Total expenses = $total฿");
          } else {
            print("Failed to fetch today's expenses");
          }

       //---------------search expenses----------------
       
       
        // ---------------- Add new expense ----------------
        

        // ---------------- Delete expense ----------------



        // ---------------- Exit ----------------
        } else if (choice == '5') {
          print("-----Bye--------");
          break;
        } else {
          print("Invalid choice, please try again.");
        }
      }
    } catch (e) {
      print("Invalid JSON response: ${loginResponse.body}");
    }
  } else {
    print("Login failed. Status code: ${loginResponse.statusCode}");
    print(loginResponse.body);
  }
}
