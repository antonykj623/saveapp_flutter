import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:new_project_2025/services/API_services/API_services.dart';
import 'package:new_project_2025/services/connectivity_service/connectivity_service.dart';
import 'package:new_project_2025/view/home/widget/report_screen/Recharge_report/Recharge_report_model.dart';

class RechargeReportPage extends StatefulWidget {
  const RechargeReportPage({Key? key}) : super(key: key);

  @override
  _RechargeReportPageState createState() => _RechargeReportPageState();
}

class _RechargeReportPageState extends State<RechargeReportPage>
    with TickerProviderStateMixin {
  final List<RechargeHistoryData> reports = [];
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Connectivity listener
    ConnectivityUtils.connectivityStream().listen((isConnected) {
      if (!isConnected && mounted) {
        debugPrint('📡 Connection lost');
      } else if (isConnected && mounted) {
        debugPrint('📡 Connection restored');
      }
    });

    _setupAnimations();
    getRechargeReports();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF027771)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading Reports...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToInvoice(RechargeHistoryData report) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                RechargeInvoicePage(reportData: report),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF027771), Color(0xFF105461), Color(0xFF1a1a2e)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: getRechargeReports,
          backgroundColor: const Color(0xFF027771),
          icon: const Icon(Icons.refresh, color: Colors.white),
          label: const Text(
            'Refresh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Recharge Reports",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              '${reports.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _fadeInAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: reports.isEmpty ? _buildEmptyState() : _buildReportsGrid(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF027771).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 80,
              color: Color(0xFF027771),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No recharge reports available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Pull down to refresh or check back later",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        double childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.85;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return _buildReportCard(reports[index], index);
          },
        );
      },
    );
  }

  Widget _buildReportCard(RechargeHistoryData report, int index) {
    final operator = ApiHelper.dthOperators.firstWhere(
      (op) =>
          op['code'].toString().toUpperCase() ==
          (report.operatorName ?? '').toUpperCase(),
      orElse:
          () => {
            'name': 'Unknown',
            'asset': 'assets/default.jpg',
            'color': Colors.grey,
            'gradient': [Colors.grey, Colors.grey],
            'description': 'Unknown operator',
          },
    );

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: _buildCardContent(report, operator),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(
    RechargeHistoryData report,
    Map<String, dynamic> operator,
  ) {
    return Hero(
      tag: 'report_${report.id}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _navigateToInvoice(report),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: operator['gradient'] as List<Color>,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardHeader(operator),
                        const SizedBox(height: 8),
                        _buildCardBody(report),
                        const SizedBox(height: 8),
                        _buildCardFooter(report),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> operator) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            operator['asset'] as String,
            height: 16,
            width: 16,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.sim_card, size: 16, color: Colors.white);
            },
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            operator['name'] as String,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody(RechargeHistoryData report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          report.accountNumber ?? "N/A",
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          "₹ ${report.amount.toString()}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(RechargeHistoryData report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusChip(
          text:
              report.paymentStatus.toString() == "5"
                  ? "Payment Success"
                  : "Payment Failed",
          isSuccess: report.paymentStatus.toString() == "5",
        ),
        const SizedBox(height: 2),
        _buildStatusChip(
          text: _getRechargeStatusText(report.status.toString()),
          isSuccess: report.status.toString() == "1",
        ),
        const SizedBox(height: 4),
        Text(
          report.rechargeDate.toString(),
          style: const TextStyle(fontSize: 8, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusChip({required String text, required bool isSuccess}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color:
            isSuccess
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSuccess ? Colors.green[200]! : Colors.red[200]!,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSuccess ? Colors.green[200] : Colors.red[200],
          fontSize: 7,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getRechargeStatusText(String status) {
    switch (status) {
      case "1":
        return "Recharge Success";
      case "0":
        return "Recharge Failed";
      case "2":
        return "Recharge Pending";
      default:
        return "Refunded";
    }
  }

  // -- INTERNET CONNECTIVITY ENHANCED FUNCTION --
  Future<void> getRechargeReports() async {
    bool isConnected = await ConnectivityUtils.isConnected();

    if (!isConnected) {
      if (mounted) {
        ConnectivityUtils.showNoInternetDialog(context);
      }
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoaderDialog(context);
    });

    try {
      final apiHelper = ApiHelper();
      final response = await apiHelper.getApiResponse(
        'getRechargeHistoryReports.php?d=${DateTime.now().microsecondsSinceEpoch}',
      );

      debugPrint(
        'Raw API Response: ${const JsonEncoder.withIndent('  ').convert(jsonDecode(response))}',
      );

      final rechargeHistoryEntity = RechargeHistoryEntity.fromJson(
        jsonDecode(response),
      );

      debugPrint(
        'Parsed RechargeHistoryEntity: ${rechargeHistoryEntity.toString()}',
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });

      if (rechargeHistoryEntity.status == 1) {
        setState(() {
          reports.clear();
          reports.addAll(rechargeHistoryEntity.data ?? []);
        });
        _animationController.forward();
        Future.delayed(const Duration(milliseconds: 800), () {
          _fabAnimationController.forward();
        });
      } else {
        setState(() {
          reports.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(rechargeHistoryEntity.message ?? "No data available"),
            backgroundColor: const Color(0xFF027771),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });

      bool stillConnected = await ConnectivityUtils.isConnected();
      if (!stillConnected && mounted) {
        ConnectivityUtils.showNoInternetSnackbar(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      debugPrint('Error fetching recharge reports: $e');
    }
  }
}

// -------------------------------------------------------------------
// INVOICE PAGE
// -------------------------------------------------------------------
class RechargeInvoicePage extends StatefulWidget {
  final RechargeHistoryData reportData;

  const RechargeInvoicePage({Key? key, required this.reportData})
    : super(key: key);

  @override
  _RechargeInvoicePageState createState() => _RechargeInvoicePageState();
}

class _RechargeInvoicePageState extends State<RechargeInvoicePage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF027771),
        elevation: 0,
        title: const Text(
          'Recharge Invoice',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Hero(
            tag: 'report_${widget.reportData.id}',
            child: _buildInvoiceContent(),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice download feature coming soon!'),
                  backgroundColor: Color(0xFF027771),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF027771),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.download, color: Colors.white),
            label: const Text(
              'Download Invoice',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceContent() {
    final operator = ApiHelper.dthOperators.firstWhere(
      (op) =>
          op['code'].toString().toUpperCase() ==
          (widget.reportData.operatorName ?? '').toUpperCase(),
      orElse: () => {'name': 'Unknown', 'asset': 'assets/default.jpg'},
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInvoiceHeader(),
          _buildCompanyInfo(),
          _buildInvoiceDetails(operator),
          _buildTransactionDetails(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF027771), Color(0xFF105461)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'INVOICE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'SP Key: ${widget.reportData.id ?? "N/A"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Date: ${widget.reportData.rechargeDate ?? "N/A"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Century Gate Software Solutions Pvt Ltd.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Integra ERP, Cosmopolitan Road',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            'Awsini Junction, Thrissur, Kerala – 680020',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            'Phone: 04872322006, 9846109500',
            style: TextStyle(fontSize: 13),
          ),
          Text(
            'mail@mysaving.in, mail@integraerp.in',
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 8),
          Text(
            'GSTIN: 32AADCC3668C1Z2',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(
            'State: 32 Kerala',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails(Map<String, dynamic> operator) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDetailRow('Transaction Order', widget.reportData.id ?? "N/A"),
          _buildDetailRow(
            'Account Number',
            widget.reportData.accountNumber ?? "N/A",
          ),
          _buildDetailRow('Operator', operator['name'] as String),
          const SizedBox(height: 16),
          _buildServiceTable(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              border: TableBorder.all(color: Colors.grey, width: 0.5),
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Expanded(
                    child: Text(
                      'Particulars',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Qty',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Rate',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
              rows: [
                DataRow(
                  cells: [
                    const DataCell(
                      Text('Mobile Recharge', style: TextStyle(fontSize: 12)),
                    ),
                    const DataCell(Text('1', style: TextStyle(fontSize: 12))),
                    DataCell(
                      Text(
                        '₹${widget.reportData.amount}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${widget.reportData.amount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Amount in words:',
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(
                            _convertAmountToWords(
                              widget.reportData.amount ?? "0",
                            ),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const DataCell(
                      Text(
                        'Net Total',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const DataCell(Text('')),
                    DataCell(
                      Text(
                        '₹${widget.reportData.amount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _convertAmountToWords(String amountStr) {
    try {
      double amount = double.parse(amountStr);
      // Simple conversion - you can enhance this with a proper number-to-words library
      if (amount < 100) {
        return '${amount.toInt()} INR Only';
      } else if (amount < 1000) {
        return '${amount.toInt()} INR Only';
      } else if (amount < 100000) {
        return '${(amount / 1000).toStringAsFixed(1)} Thousand INR Only';
      } else {
        return '${(amount / 100000).toStringAsFixed(1)} Lakh INR Only';
      }
    } catch (e) {
      return '$amountStr INR Only';
    }
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF027771),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'Payment Status',
            widget.reportData.paymentStatus.toString() == "5"
                ? "Success"
                : "Failed",
            widget.reportData.paymentStatus.toString() == "5",
          ),
          _buildStatusRow(
            'Recharge Status',
            _getRechargeStatusText(widget.reportData.status.toString()),
            widget.reportData.status.toString() == "1",
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaction Date:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.reportData.rechargeDate ?? "N/A",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isSuccess
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSuccess ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        children: [
          Text(
            'Thank you for using our service!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF027771),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Century Gate Software Solutions Private Limited.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'www.mysaving.in',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF027771),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getRechargeStatusText(String status) {
    switch (status) {
      case "1":
        return "Success";
      case "0":
        return "Failed";
      case "2":
        return "Pending";
      default:
        return "Refunded";
    }
  }
}
