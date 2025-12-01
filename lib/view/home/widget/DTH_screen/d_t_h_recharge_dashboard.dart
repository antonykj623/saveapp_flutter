import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:new_project_2025/view/home/widget/DTH_screen/d_t_h_plans_screen.dart';
import 'Utils.dart';

class DTHRechargeDashboard extends StatefulWidget {
  const DTHRechargeDashboard({Key? key}) : super(key: key);

  @override
  _DTHRechargeDashboardState createState() => _DTHRechargeDashboardState();
}

class _DTHRechargeDashboardState extends State<DTHRechargeDashboard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _rippleController;

  int? _selectedIndex;
  int? _hoveredIndex;

  final List<Plan> plans = [
    Plan(
      name: "Airtel Digital TV",
      serverName: "Airtel dth",
      opcode: "AD",
      spKey: "51",
      image: "assets/img.png",
    ),
    Plan(
      name: "Dish TV",
      serverName: "Dish TV",
      opcode: "DT",
      spKey: "53",
      image: "assets/img_1.png",
    ),
    Plan(
      name: "Sun Direct",
      serverName: "Sun Direct",
      opcode: "SD",
      spKey: "54",
      image: "assets/img_2.png",
    ),
    Plan(
      name: "Tata Sky",
      serverName: "Tata Sky",
      opcode: "TS",
      spKey: "55",
      image: "assets/img_3.png",
    ),
    Plan(
      name: "Videocon D2H",
      serverName: "Videocon",
      opcode: "VD",
      spKey: "56",
      image: "assets/img_4.png",
    ),
  ];

  final List<Color> brandColors = [
    Color(0xFFE63946), // Red
    Color(0xFF457B9D), // Blue
    Color(0xFFF77F00), // Orange
    Color(0xFF06A77D), // Teal
    Color(0xFF9B59B6), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFECEC), // Soft pink
                  Color(0xFFE8F4FF), // Sky blue
                  Color(0xFFFFE8F5), // Rose
                  Color(0xFFE8FFE8), // Mint
                  Color(0xFFFFF4E8), // Peach
                ],
                stops: [
                  0.0,
                  0.25 + (_floatController.value * 0.05),
                  0.5,
                  0.75 - (_floatController.value * 0.05),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated floating orbs
                ...List.generate(5, (index) {
                  return Positioned(
                    top:
                        50 +
                        (index * 150.0) +
                        (30 *
                            math.sin(
                              (_floatController.value + index * 0.2) * math.pi,
                            )),
                    left:
                        20 +
                        (index * 70.0) +
                        (20 *
                            math.cos(
                              (_floatController.value + index * 0.3) * math.pi,
                            )),
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: 100 + (index * 20.0),
                        height: 100 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              [
                                Color(0xFFFF6B9D),
                                Color(0xFFFFC371),
                                Color(0xFF667EEA),
                                Color(0xFFA8E6CF),
                                Color(0xFFFFD93D),
                              ][index],
                              [
                                Color(0xFFFF6B9D),
                                Color(0xFFFFC371),
                                Color(0xFF667EEA),
                                Color(0xFFA8E6CF),
                                Color(0xFFFFD93D),
                              ][index].withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Beautiful mesh gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.5,
                        colors: [
                          Color(0xFFFF6B9D).withOpacity(0.08),
                          Color(0xFF667EEA).withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.bottomLeft,
                        radius: 1.5,
                        colors: [
                          Color(0xFFFFC371).withOpacity(0.08),
                          Color(0xFFA8E6CF).withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Subtle light spots
                Positioned(
                  top: 100,
                  right: 50,
                  child: Opacity(
                    opacity: 0.4,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 150,
                  left: 30,
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          );
        },

        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(child: const SizedBox(height: 32)),
              SliverToBoxAdapter(child: _buildTitle()),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _buildProviderCard(plans[index], index);
                  }, childCount: plans.length),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, -0.5),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        ),
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DTH Recharge",
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Fast & Secure",
                      style: TextStyle(
                        color: Color(0xFF95A5A6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      3 * math.sin(_floatController.value * math.pi),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF667EEA).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.satellite_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFF667EEA)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Select Your Provider",
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Choose from top DTH providers",
              style: TextStyle(
                color: Color(0xFF95A5A6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard(Plan plan, int index) {
    final isSelected = _selectedIndex == index;
    final isHovered = _hoveredIndex == index;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, entryValue, child) {
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatOffset =
                4 * math.sin((_floatController.value + index * 0.2) * math.pi);

            return Transform.translate(
              offset: Offset(0, (1 - entryValue) * 50 + floatOffset),
              child: Opacity(
                opacity: entryValue,
                child: Transform.scale(
                  scale: isSelected ? 0.95 : 1.0,
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() => _selectedIndex = index);
                      _rippleController.forward(from: 0);
                    },
                    onTapUp: (_) {
                      Future.delayed(Duration(milliseconds: 150), () {
                        setState(() => _selectedIndex = null);
                        _navigateToPlans(plan, index);
                      });
                    },
                    onTapCancel: () => setState(() => _selectedIndex = null),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredIndex = index),
                      onExit: (_) => setState(() => _hoveredIndex = null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isHovered
                                      ? brandColors[index % brandColors.length]
                                          .withOpacity(0.15)
                                      : Colors.black.withOpacity(0.06),
                              blurRadius: isHovered ? 20 : 15,
                              offset: Offset(0, isHovered ? 8 : 4),
                              spreadRadius: isHovered ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Subtle gradient overlay
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      brandColors[index % brandColors.length]
                                          .withOpacity(0.03),
                                      Colors.transparent,
                                      brandColors[index % brandColors.length]
                                          .withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Card content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Logo with animated border
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    transform:
                                        Matrix4.identity()
                                          ..scale(isHovered ? 1.05 : 1.0),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            brandColors[index %
                                                brandColors.length],
                                            brandColors[index %
                                                    brandColors.length]
                                                .withOpacity(0.6),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: brandColors[index %
                                                    brandColors.length]
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipOval(
                                          child: Image.asset(
                                            plan.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: brandColors[index %
                                                        brandColors.length]
                                                    .withOpacity(0.1),
                                                child: Icon(
                                                  Icons.tv,
                                                  size: 40,
                                                  color:
                                                      brandColors[index %
                                                          brandColors.length],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Provider name
                                  Text(
                                    plan.name,
                                    style: TextStyle(
                                      color: Color(0xFF2C3E50),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 16),

                                  // Action button
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          brandColors[index %
                                              brandColors.length],
                                          brandColors[index %
                                                  brandColors.length]
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: brandColors[index %
                                                  brandColors.length]
                                              .withOpacity(
                                                isHovered ? 0.4 : 0.2,
                                              ),
                                          blurRadius: isHovered ? 12 : 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Ripple effect on tap
                            if (isSelected)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _rippleController,
                                  builder: (context, child) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: brandColors[index %
                                                  brandColors.length]
                                              .withOpacity(
                                                0.5 *
                                                    (1 -
                                                        _rippleController
                                                            .value),
                                              ),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToPlans(Plan plan, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => DTHPlansScreen(plan),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
