import 'package:flutter/material.dart';

// --- DARK THEME CONSTANTS ---
const Color primaryColor = Color(0xFFF9A825);
const Color darkBg = Color(0xFF0F0821);       
const Color darkCardBg = Color(0xFF1B0F33);   
const Color secondaryText = Color(0xFFE0E0E0); 
const Color mutedText = Color(0xFF9E9E9E);    

class ComingSoonScreen extends StatefulWidget {
  final String featureName; // Tên tính năng sẽ ra mắt

  const ComingSoonScreen({super.key, required this.featureName});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Chu kỳ lặp 2 giây
    )..repeat(reverse: true); // Lặp lại và đảo ngược

    // Animation thay đổi kích thước nhẹ nhàng
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    // Animation thay đổi độ mờ của chữ (Flash nhẹ)
    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text(
          widget.featureName,
          style: const TextStyle(color: secondaryText, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkCardBg,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- ICON/GRAPHIC ---
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: darkCardBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.5), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.construction, // Biểu tượng xây dựng
                    size: 80,
                    color: primaryColor,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- TITLE & MESSAGE ---
              FadeTransition(
                opacity: _opacityAnimation,
                child: Text(
                  '${widget.featureName} Đang Được Xây Dựng!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Tính năng này sẽ sớm có mặt trong các bản cập nhật tiếp theo. Hãy theo dõi!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryText,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),
              
              // --- LOADING INDICATOR (Tạo cảm giác đang làm việc) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
                  const SizedBox(width: 12),
                  const Text(
                    'Chuẩn bị dữ liệu...',
                    style: TextStyle(color: mutedText, fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}