import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:new_project_2025/view_model/VisitingCard/addVisitingcard.dart';
import 'package:new_project_2025/view_model/VisitingCard/visitingcard.dart';
import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class AddVisitingCard extends StatefulWidget {
  const AddVisitingCard({Key? key}) : super(key: key);

  @override
  State<AddVisitingCard> createState() => _AddVisitingCardState();
}

class _AddVisitingCardState extends State<AddVisitingCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();

    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final loadedCards = await _dbHelper.getVisitingCards();
      setState(() {
        cards = loadedCards;
      });
    } catch (e) {
      print("Error loading cards: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading cards: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Your Visiting Cards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              width: 50,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 30),
                            if (cards.isEmpty)
                              Center(
                                child: Text(
                                  "No visiting cards found. Add a new one!",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            else
                              ...cards.map((card) {
                                final cardData =
                                    card['parsed_data']
                                        as Map<String, dynamic>? ??
                                    {};
                                final logoImage =
                                    card['logoimage'] as Uint8List?;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Row(
                                        children: [
                                          Hero(
                                            tag:
                                                'profile_image_${card['keyid']}',
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 10,
                                                    offset: Offset(0, 5),
                                                  ),
                                                ],
                                                image: DecorationImage(
                                                  image:
                                                      logoImage != null
                                                          ? MemoryImage(
                                                            logoImage,
                                                          )
                                                          : AssetImage(
                                                                'assets/placeholder_logo.png',
                                                              )
                                                              as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildInfoRow(
                                                  Icons.person,
                                                  cardData['name'] ?? "Unknown",
                                                  Color(0xFF667eea),
                                                ),
                                                SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.phone,
                                                  cardData['phone'] ??
                                                      "No Phone",
                                                  Color(0xFF764ba2),
                                                ),
                                                SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.web,
                                                  cardData['website'] ??
                                                      "No Website",
                                                  Color(0xFFF093fb),
                                                ),
                                                SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.work,
                                                  cardData['designation'] ??
                                                      "No Designation",
                                                  Color(0xFF667eea),
                                                ),
                                                SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    _buildActionButton(
                                                      "Edit",
                                                      Icons.edit,
                                                      Colors.blue,
                                                      () => _editCard(card),
                                                    ),
                                                    SizedBox(width: 10),
                                                    _buildActionButton(
                                                      "Delete",
                                                      Icons.delete_outline,
                                                      Colors.red,
                                                      () => _showDeleteDialog(
                                                        card['keyid'],
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    _buildActionButton(
                                                      "View",
                                                      Icons.visibility,
                                                      Colors.green,
                                                      () => _viewCard(card),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    "Share Card",
                                    Icons.share,
                                    Colors.blue,
                                    _shareCard,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: _buildActionButton(
                                    "Add New Card",
                                    Icons.add,
                                    Colors.green,
                                    _addNewCard,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _addNewCard,
          icon: Icon(Icons.add, color: Colors.white, size: 24),
          label: Text(
            "Add New Card",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text("Delete Card"),
          content: Text("Are you sure you want to delete this visiting card?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete"),
              onPressed: () async {
                await _dbHelper.deleteVisitingCard(id);
                Navigator.of(context).pop();
                await _loadCards();
              },
            ),
          ],
        );
      },
    );
  }

  void _shareCard() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Select a card to share")));
  }

  void _editCard(Map<String, dynamic> card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VisitingCard(
              cardData: card['parsed_data'] as Map<String, dynamic>?,
              cardId: card['keyid'],
              logoImage: card['logoimage'] as Uint8List?,
              cardImage: card['cardimg'] as Uint8List?,
            ),
      ),
    ).then((result) {
      if (result == true) {
        _loadCards();
      }
    });
  }

  void _viewCard(Map<String, dynamic> card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VisitingCardPage(
              imageUrl: card['cardimg'] != null ? 'memory' : 'assets/1.jpg',
              cardData: card['parsed_data'] as Map<String, dynamic>?,
              visitingCardId: card['keyid'],
            ),
      ),
    );
  }

  void _addNewCard() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => VisitingCard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    ).then((result) {
      if (result == true) {
        _loadCards();
      }
    });
  }
}
