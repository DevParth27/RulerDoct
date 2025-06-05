import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isDesktop = MediaQuery.of(context).size.width > 768;
    // final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // title: Text(
        //   'About Us',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontWeight: FontWeight.w600,
        //     fontSize: 20,
        //   ),
        // ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            // child: IconButton(
            //   icon: Icon(Icons.more_vert, color: Colors.white),
            //   onPressed: () {},
            // ),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF1A1A2E)],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildMainContent(context),
              _buildStatsSection(context),
              _buildTeamSection(context),
              _buildValuesSection(context),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: isDesktop ? screenHeight * 0.6 : screenHeight * 0.5,
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(painter: GeometricPatternPainter()),
          ),
          // Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          padding: EdgeInsets.all(isDesktop ? 24 : 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.business,
                            size: isDesktop ? 60 : 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 32 : 24),
                      Text(
                        'About Our Project',
                        style: TextStyle(
                          fontSize: isDesktop ? 48 : 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isDesktop ? 600 : double.infinity,
                        ),
                        child: Text(
                          'Innovating the future through cutting-edge technology and exceptional user experiences',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (isDesktop)
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      title: 'Our Mission',
                      content:
                          'To develop an affordable and time-efficient medical solution tailored for rural communities.',
                      icon: Icons.rocket_launch,
                      gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      context: context,
                    ),
                  ),
                  SizedBox(width: 24),
                  Expanded(
                    child: _buildGlassCard(
                      title: 'Our Vision',
                      content:
                          'To bridge the healthcare gap in rural communities by providing affordable, accessible, and timely medical services through a user-friendly digital platform, empowering every individual with the right to quality care regardless of location.',
                      icon: Icons.visibility,
                      gradient: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                      context: context,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildGlassCard(
                    title: 'Our Mission',
                    content:
                        'To develop an affordable and time-efficient medical solution tailored for rural communities.',
                    icon: Icons.rocket_launch,
                    gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    context: context,
                  ),
                  SizedBox(height: 16),
                  _buildGlassCard(
                    title: 'Our Vision',
                    content:
                        'To be the leading technology partner that transforms ideas into reality, creating a more connected and efficient digital world.',
                    icon: Icons.visibility,
                    gradient: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                    context: context,
                  ),
                ],
              ),
            SizedBox(height: 24),
            _buildGlassCard(
              title: 'Our Story',
              content:
                  'To bridge the healthcare gap in rural communities by providing affordable, accessible, and timely medical services through a user-friendly digital platform, empowering every individual with the right to quality care regardless of location.',
              icon: Icons.auto_stories,
              gradient: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              isWide: true,
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required String content,
    required IconData icon,
    required List<Color> gradient,
    required BuildContext context,
    bool isWide = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 16 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: isDesktop ? 32 : 28),
          ),
          SizedBox(height: isDesktop ? 24 : 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 16 : 12),
          Text(
            content,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 60 : 40,
        horizontal: isDesktop ? 40 : 20,
      ),
      child: Column(
        children: [
          Text(
            'Our Impact',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          if (isMobile)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('10+', 'Happy Doctors', context),
                    _buildStatItem('200+', 'Happy Patients', context),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('1', 'Team Member', context),
                    _buildStatItem('3+', 'Years Experience', context),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('10+', 'Happy Doctors', context),
                _buildStatItem('200+', 'Happy Patients', context),
                _buildStatItem('1', 'Team Member', context),
                _buildStatItem('3+', 'Years Experience', context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : (isDesktop ? 24 : 20)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: isMobile ? 20 : (isDesktop ? 32 : 24),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          SizedBox(
            width: isMobile ? 80 : 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 12 : 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Column(
        children: [
          Text(
            'Leadership Team',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          if (isMobile)
            Column(
              children: [
                _buildTeamMember(
                  'Parth Upadhye',
                  'CEO & Founder',
                  Icons.person,
                  context,
                ),
                SizedBox(height: 24),
                _buildTeamMember('None', 'CTO', Icons.code, context),
                SizedBox(height: 24),
                _buildTeamMember(
                  'Parth Upadhye',
                  'Head of Design',
                  Icons.design_services,
                  context,
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamMember(
                  'Parth Upadhye',
                  'CEO & Founder',
                  Icons.person,
                  context,
                ),
                _buildTeamMember('None', 'CTO', Icons.code, context),
                _buildTeamMember(
                  'Parth Upadhye',
                  'Head of Design',
                  Icons.design_services,
                  context,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
    String name,
    String role,
    IconData icon,
    BuildContext context,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : (isDesktop ? 200 : 180),
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: isDesktop ? 80 : 70,
            height: isDesktop ? 80 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(isDesktop ? 40 : 35),
            ),
            child: Icon(icon, color: Colors.white, size: isDesktop ? 40 : 35),
          ),
          SizedBox(height: 16),
          Text(
            name,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      child: Column(
        children: [
          Text(
            'Our Values',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isDesktop ? 48 : 32),
          if (isMobile)
            Column(
              children: [
                _buildValueCard(
                  'Innovation',
                  'Constantly pushing boundaries',
                  Icons.lightbulb,
                  context,
                ),
                SizedBox(height: 16),
                _buildValueCard(
                  'Quality',
                  'Excellence in every detail',
                  Icons.star,
                  context,
                ),
                SizedBox(height: 16),
                _buildValueCard(
                  'Integrity',
                  'Honest and transparent',
                  Icons.handshake,
                  context,
                ),
                SizedBox(height: 16),
                _buildValueCard(
                  'Collaboration',
                  'Stronger together',
                  Icons.group,
                  context,
                ),
              ],
            )
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                _buildValueCard(
                  'Innovation',
                  'Constantly pushing boundaries',
                  Icons.lightbulb,
                  context,
                ),
                _buildValueCard(
                  'Quality',
                  'Excellence in every detail',
                  Icons.star,
                  context,
                ),
                _buildValueCard(
                  'Integrity',
                  'Honest and transparent',
                  Icons.handshake,
                  context,
                ),
                _buildValueCard(
                  'Collaboration',
                  'Stronger together',
                  Icons.group,
                  context,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildValueCard(
    String title,
    String description,
    IconData icon,
    BuildContext context,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: isMobile ? double.infinity : (isDesktop ? 250 : 200),
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF667EEA), size: isDesktop ? 48 : 40),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      padding: EdgeInsets.all(isDesktop ? 40 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.05), Colors.transparent],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to work with us?',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          SizedBox(
            width: isDesktop ? null : double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showGetInTouchDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: isDesktop ? 16 : 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 24,
                  vertical: isDesktop ? 16 : 14,
                ),
                child: Text(
                  'Get In Touch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

void _showGetInTouchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.all(20),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.mail_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Get in Touch',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow("👤 Name", "Parth Upadhye"),
            SizedBox(height: 10),
            _buildInfoRow("📧 Email", "parth.upadhye.4@gmail.com"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.check),
              label: Text(
                "Okay, Got it!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600)),
      Expanded(child: Text(value, style: TextStyle(color: Colors.grey[800]))),
    ],
  );
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.05)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 20; j++) {
        final rect = Rect.fromLTWH(i * 50.0, j * 50.0, 40, 40);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(8)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
