import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Financialrecord extends StatefulWidget {
  const Financialrecord({Key? key}) : super(key: key);

  @override
  State<Financialrecord> createState() => _FinancialrecordState();
}

class _FinancialrecordState extends State<Financialrecord> {
  String selectedPeriod = 'Today';
  final List<String> periods = ['Today', 'This Week', 'This Month'];

  // Financial data variables
  Map<String, dynamic> orderSummary = {
    'totalOrders': 0,
    'received': 0,
    'inProgress': 0,
    'completed': 0,
    'delivered': 0,
  };

  Map<String, dynamic> earnings = {
    'totalPayment': 0.0,
    'paymentReceived': 0.0,
    'pendingPayment': 0.0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFinancialData();
  }

  // FIXED: Better date range logic
  bool _isOrderInSelectedPeriod(DateTime orderDate) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    switch (selectedPeriod) {
      case 'Today':
        DateTime orderDay = DateTime(orderDate.year, orderDate.month, orderDate.day);
        return orderDay.isAtSameMomentAs(today);
        
      case 'This Week':
        // Get start of current week (Monday)
        DateTime startOfWeek = today.subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return orderDate.isAfter(startOfWeek.subtract(Duration(milliseconds: 1))) && 
               orderDate.isBefore(endOfWeek.add(Duration(milliseconds: 1)));
        
      case 'This Month':
        DateTime startOfMonth = DateTime(now.year, now.month, 1);
        DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));
        return orderDate.isAfter(startOfMonth.subtract(Duration(milliseconds: 1))) && 
               orderDate.isBefore(endOfMonth.add(Duration(milliseconds: 1)));
        
      default:
        return true;
    }
  }

  Future<void> _loadFinancialData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Reset counters
      orderSummary = {
        'totalOrders': 0,
        'received': 0,
        'inProgress': 0,
        'completed': 0,
        'delivered': 0,
      };

      earnings = {
        'totalPayment': 0.0,
        'paymentReceived': 0.0,
        'pendingPayment': 0.0,
      };

      // Get all customers
      QuerySnapshot customersSnapshot =
          await FirebaseFirestore.instance.collection('Customer').get();

      for (DocumentSnapshot customerDoc in customersSnapshot.docs) {
        // Get orders for each customer
        QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
            .collection('Customer')
            .doc(customerDoc.id)
            .collection('Orders')
            .get();

        for (DocumentSnapshot orderDoc in ordersSnapshot.docs) {
          Map<String, dynamic> orderData =
              orderDoc.data() as Map<String, dynamic>;

          // FIXED: Better date filtering logic
          Timestamp? orderTimestamp = orderData['timestamp'] as Timestamp?;
          if (orderTimestamp != null) {
            DateTime orderDate = orderTimestamp.toDate();
            if (!_isOrderInSelectedPeriod(orderDate)) {
              continue; // Skip this order if it's outside the selected period
            }
          } else if (selectedPeriod != 'Today') {
            // If no timestamp and not filtering for today, skip
            continue;
          }

          // Count orders by status
          String status = orderData['Status'] ?? 'Received';
          orderSummary['totalOrders']++;

          switch (status.toLowerCase()) {
            case 'received':
              orderSummary['received']++;
              break;
            case 'processing':
              orderSummary['inProgress']++;
              break;
            case 'completed':
              orderSummary['completed']++;
              break;
            case 'delivered':
              orderSummary['delivered']++;
              break;
            default:
              orderSummary['received']++;
          }

          // Calculate financial data
          double totalAmount =
              double.tryParse(orderData['Total Amount']?.toString() ?? '0') ??
                  0.0;
          double advanceAmount =
              double.tryParse(orderData['Advance Amount']?.toString() ?? '0') ??
                  0.0;
          double remainingAmount = double.tryParse(
                  orderData['Remaining Amount']?.toString() ?? '0') ??
              0.0;

          earnings['totalPayment'] += totalAmount;
          earnings['paymentReceived'] += advanceAmount;
          earnings['pendingPayment'] += remainingAmount;
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading financial data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildPeriodTab(String period) {
    bool isSelected = selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPeriod = period;
          });
          _loadFinancialData();
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightBlue : Colors.grey.shade200,
          ),
          child: Center(
            child: Text(
              period,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue, Colors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
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
            'Order Summary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          _buildSummaryRow(
              Icons.receipt_long, 'Total Orders:', orderSummary['totalOrders']),
          SizedBox(height: 12),
          _buildSummaryRow(
              Icons.inbox, 'Order Received:', orderSummary['received']),
          SizedBox(height: 12),
          _buildSummaryRow(
              Icons.autorenew, 'In Progress:', orderSummary['inProgress']),
          SizedBox(height: 12),
          _buildSummaryRow(Icons.check_circle_outline, 'Completed:',
              orderSummary['completed']),
          SizedBox(height: 12),
          _buildSummaryRow(Icons.local_shipping, 'Order Delivered:',
              orderSummary['delivered']),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(15),
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
            'Total Earning',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          _buildEarningRow(Icons.account_balance_wallet, 'Total Payment:',
              earnings['totalPayment']),
          SizedBox(height: 12),
          _buildEarningRow(
              Icons.payments, 'Payment Received:', earnings['paymentReceived']),
          SizedBox(height: 12),
          _buildEarningRow(Icons.pending_actions, 'Pending Payment:',
              earnings['pendingPayment']),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, int value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEarningRow(IconData icon, String label, double value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.white),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // Period selection tabs
          Container(
            color: Colors.white,
            child: Row(
              children:
                  periods.map((period) => _buildPeriodTab(period)).toList(),
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildOrderSummaryCard(),
                        _buildEarningsCard(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}