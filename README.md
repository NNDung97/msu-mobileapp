📱 MSU App

Ứng dụng di động được phát triển bằng Flutter, phục vụ cho hệ thống MSU.
Dự án hướng đến việc cung cấp trải nghiệm nhanh, ổn định, và dễ mở rộng.

🚀 Tính năng chính

🔐 Đăng nhập / Xác thực người dùng bằng wallet ID

📊 Xem thông tin cá nhân / dữ liệu theo tài khoản

🔄 Đồng bộ dữ liệu realtime hoặc định kỳ

🎨 UI hiện đại, responsive

⚙️ Kết nối API backend (Node.js/NestJS hoặc service khác)

📂 Cấu trúc dự án
lib/
 ├── model/              # Khai báo model dữ liệu
 ├── providers/          # Provider / State management
 ├── service/            # Gọi API, xử lý dữ liệu
 ├── screens/            # Các màn hình giao diện
 ├── widgets/            # Các widget tái sử dụng
 └── main.dart           # Điểm khởi chạy ứng dụng

🛠️ Cài đặt & chạy ứng dụng
1. Clone project
git clone https://github.com/<username>/msu_app.git
cd msu_app

2. Cài đặt dependencies
flutter pub get

3. Chạy ứng dụng
flutter run

📦 Yêu cầu hệ thống

Flutter SDK (phiên bản mới nhất khuyến nghị)

Dart SDK đi kèm Flutter

Android Studio hoặc Xcode (nếu build cho iOS)

Thiết bị thật hoặc emulator

🔧 Build APK / IPA
Android:
flutter build apk --release

iOS:
flutter build ios --release

🧪 Kiểm thử

Các bài test có thể được đặt tại thư mục test/:

flutter test

🤝 Đóng góp

Mọi đóng góp đều được chào đón.
Bạn có thể mở issue, gửi pull request, hoặc trao đổi thêm trong repository.

📄 License

Developed by DungNN97 — All Rights Reserved.
