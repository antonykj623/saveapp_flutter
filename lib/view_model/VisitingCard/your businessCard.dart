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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

  Future<ImageProvider> _getCardImage(Map<String, dynamic> card) async {
    try {
      // Check for cardimg in card data with proper null checking
      if (card['cardimg'] != null &&
          card['cardimg'] is Uint8List &&
          (card['cardimg'] as Uint8List).isNotEmpty) {
        return MemoryImage(card['cardimg'] as Uint8List);
      }

      // Check for selected carousel image in database
      if (card['keyid'] != null && card['keyid'] is int) {
        final selectedImage = await _dbHelper.getSelectedCarouselImage(
          card['keyid'] as int,
        );
        if (selectedImage != null &&
            selectedImage['image_data'] != null &&
            selectedImage['image_data'] is Uint8List &&
            (selectedImage['image_data'] as Uint8List).isNotEmpty) {
          return MemoryImage(selectedImage['image_data'] as Uint8List);
        }
      }

      // Check for logoimage with proper validation
      final parsedData = card['parsed_data'];
      Map<String, dynamic> cardData = {};

      if (parsedData is Map<String, dynamic>) {
        cardData = parsedData;
      } else if (parsedData is String) {
        try {
          cardData = jsonDecode(parsedData) as Map<String, dynamic>;
        } catch (e) {
          print("Error parsing parsed_data JSON: $e");
          cardData = {};
        }
      }

      // Try logoimage from card data first
      final logoImage = card['logoimage'];
      if (logoImage != null && logoImage is Uint8List && logoImage.isNotEmpty) {
        return MemoryImage(logoImage);
      }

      // Try logoimage from parsed data
      final parsedLogoImage = cardData['logoimage'];
      if (parsedLogoImage != null &&
          parsedLogoImage is Uint8List &&
          parsedLogoImage.isNotEmpty) {
        return MemoryImage(parsedLogoImage);
      }

      // Fallback to placeholder
      return const AssetImage('assets/placeholder_card.png');
    } catch (e) {
      print("Error in _getCardImage: $e");
      return const AssetImage('assets/placeholder_card.png');
    }
  }

  Future<void> _loadCards() async {
    try {
      final loadedCards = await _dbHelper.getVisitingCards();
      setState(() {
        cards =
            loadedCards
                .map((card) {
                  try {
                    // Ensure keyid is properly handled
                    final keyid = card['keyid'];
                    if (keyid == null) {
                      print("Warning: Card found without keyid");
                      return null;
                    }

                    // Handle parsed_data safely
                    Map<String, dynamic> parsedData = {};
                    final rawParsedData = card['parsed_data'];

                    if (rawParsedData is Map<String, dynamic>) {
                      parsedData = rawParsedData;
                    } else if (rawParsedData is String &&
                        rawParsedData.isNotEmpty) {
                      try {
                        parsedData =
                            jsonDecode(rawParsedData) as Map<String, dynamic>;
                      } catch (e) {
                        print("Error parsing JSON for card $keyid: $e");
                        // Try to parse from 'data' field as fallback
                        final dataField = card['data'];
                        if (dataField is String && dataField.isNotEmpty) {
                          try {
                            parsedData =
                                jsonDecode(dataField) as Map<String, dynamic>;
                          } catch (e2) {
                            print(
                              "Error parsing fallback data for card $keyid: $e2",
                            );
                            parsedData = {
                              'name': 'Unknown Card',
                              'error': 'Data parsing failed',
                            };
                          }
                        } else {
                          parsedData = {
                            'name': 'Unknown Card',
                            'error': 'No valid data found',
                          };
                        }
                      }
                    } else {
                      // Try to get data from 'data' field
                      final dataField = card['data'];
                      if (dataField is String && dataField.isNotEmpty) {
                        try {
                          parsedData =
                              jsonDecode(dataField) as Map<String, dynamic>;
                        } catch (e) {
                          print("Error parsing data field for card $keyid: $e");
                          parsedData = {
                            'name': 'Unknown Card',
                            'error': 'Invalid data format',
                          };
                        }
                      } else {
                        parsedData = {
                          'name': 'Unknown Card',
                          'error': 'No data available',
                        };
                      }
                    }

                    // Validate essential fields and provide defaults
                    if (parsedData['name'] == null ||
                        parsedData['name'].toString().trim().isEmpty) {
                      parsedData['name'] = 'Unnamed Card';
                    }
                    if (parsedData['phone'] == null) {
                      parsedData['phone'] = '';
                    }
                    if (parsedData['email'] == null) {
                      parsedData['email'] = '';
                    }
                    if (parsedData['website'] == null) {
                      parsedData['website'] = '';
                    }
                    if (parsedData['designation'] == null) {
                      parsedData['designation'] = '';
                    }

                    return {
                      'keyid': keyid,
                      'parsed_data': parsedData,
                      'logoimage': card['logoimage'] as Uint8List?,
                      'cardimg': card['cardimg'] as Uint8List?,
                    };
                  } catch (e) {
                    print("Error processing card: $e");
                    return null;
                  }
                })
                .where((card) => card != null)
                .cast<Map<String, dynamic>>()
                .toList();
      });
    } catch (e) {
      print("Error loading cards: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading cards: ${e.toString()}")),
        );
      }
      setState(() {
        cards = [];
      });
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
        decoration: const BoxDecoration(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
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
                        onPressed: () {
                          // Add functionality for more options if needed
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
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
                            const SizedBox(height: 30),
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
                                    card['parsed_data'] as Map<String, dynamic>;
                                return FutureBuilder<ImageProvider>(
                                  future: _getCardImage(card),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 20),
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
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
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
                                                        BorderRadius.circular(
                                                          15,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          5,
                                                        ),
                                                      ),
                                                    ],
                                                    image: DecorationImage(
                                                      image:
                                                          snapshot.data ??
                                                          const AssetImage(
                                                            'assets/placeholder_card.png',
                                                          ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildInfoRow(
                                                      Icons.person,
                                                      cardData['name'] ??
                                                          "Unknown",
                                                      const Color(0xFF667eea),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      Icons.phone,
                                                      cardData['phone'] ??
                                                          "No Phone",
                                                      const Color(0xFF764ba2),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      Icons.web,
                                                      cardData['website'] ??
                                                          "No Website",
                                                      const Color(0xFFF093fb),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    _buildInfoRow(
                                                      Icons.work,
                                                      cardData['designation'] ??
                                                          "No Designation",
                                                      const Color(0xFF667eea),
                                                    ),
                                                    const SizedBox(height: 15),
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
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        _buildActionButton(
                                                          "Delete",
                                                          Icons.delete_outline,
                                                          Colors.red,
                                                          () =>
                                                              _showDeleteDialog(
                                                                card['keyid'],
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        _buildActionButton(
                                                          "View",
                                                          Icons.visibility,
                                                          Colors.green,
                                                          () => _viewCard(
                                                            card['keyid'],
                                                          ),
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
                                  },
                                );
                              }).toList(),
                            const SizedBox(height: 30),
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
                                const SizedBox(width: 15),
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
      floatingActionButton: 
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: _addNewCard,
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: const Text(
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
    // Handle null or empty text
    String displayText = text;
    if (text == null || text.trim().isEmpty || text == 'null') {
      switch (icon) {
        case Icons.person:
          displayText = 'No Name Provided';
          break;
        case Icons.phone:
          displayText = 'No Phone Number';
          break;
        case Icons.web:
          displayText = 'No Website';
          break;
        case Icons.work:
          displayText = 'No Designation';
          break;
        case Icons.email:
          displayText = 'No Email';
          break;
        default:
          displayText = 'Not Provided';
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            displayText,
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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
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
          title: const Text("Delete Card"),
          content: const Text(
            "Are you sure you want to delete this visiting card?",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
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
    ).showSnackBar(const SnackBar(content: Text("Select a card to share")));
  }

  void _editCard(Map<String, dynamic> card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VisitingCard(
              cardData: card['parsed_data'] as Map<String, dynamic>,
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

  Future<void> _viewCard(int visitingCardId) async {
    try {
      final card = await _dbHelper.getVisitingCardById(visitingCardId);
      if (card != null) {
        final cardData = {
          ...card['parsed_data'] as Map<String, dynamic>,
          'logoimage': card['logoimage'] as Uint8List?,
          'cardimg': card['cardimg'] as Uint8List?,
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VisitingCardPage(
                  cardData: cardData,
                  visitingCardId: visitingCardId,
                ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Card not found")));
      }
    } catch (e) {
      print("Error viewing card: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error viewing card: ${e.toString()}")),
      );
    }
  }

  void _addNewCard() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const VisitingCard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
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
