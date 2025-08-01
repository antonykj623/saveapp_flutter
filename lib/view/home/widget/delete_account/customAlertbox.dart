import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  const CustomAlertDialog({
    Key? key,
    required this.onYesPressed,
    required this.onNoPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.elasticOut,
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 2,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF6B6B),
                      Color(0xFF4ECDC4),
                      Color(0xFF45B7D1),
                      Color(0xFF96CEB4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(height: 20),
              ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: [Color(0xFF2D5A5A), Color(0xFF4ECDC4)],
                    ).createShader(bounds),
                child: Text(
                  'Demo Account/app License Deletion',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'If Deleted, All Your Credentials Will Be Removed From The Database and You Cannot Login to The App and Website Anymore',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Do You Want to Continue?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _buildAlertButton(
                      text: 'No',
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      onPressed: onNoPressed,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildAlertButton(
                      text: 'Yes',
                      colors: [Color(0xFF4ECDC4), Color(0xFF2D5A5A)],
                      onPressed: onYesPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertButton({
    required String text,
    required List<Color> colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      child: Material(
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.4),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

