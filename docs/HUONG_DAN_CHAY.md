# Hướng dẫn chạy và cài đặt

## Cách 1: Cài APK thủ công

1. Chép `build/GiaiCuuNgoiLangHoa.apk` sang điện thoại Android.
2. Mở tệp bằng ứng dụng quản lý tệp.
3. Nếu được hỏi, cho phép **Cài đặt ứng dụng không rõ nguồn gốc** đối với ứng dụng quản lý tệp.
4. Chọn **Cài đặt**, sau đó mở **Giải Cứu Ngôi Làng Hoa**.

APK yêu cầu Android 7.0 trở lên và thiết bị ARM 64-bit.

Ứng dụng được khóa ở chế độ **landscape ngang**, chạy **immersive fullscreen** và tự mở rộng giao diện cho các tỉ lệ 16:9 đến 20:9. Joystick bám mép trái dưới, cụm skill bám mép phải dưới; menu/modal luôn căn giữa. Khu vực điều khiển không vẽ edge-to-edge dưới tai thỏ để tránh mất nút.

## Cách 2: Cài bằng cáp USB từ Ubuntu

1. Trên điện thoại, bật **Tùy chọn nhà phát triển → Gỡ lỗi USB**.
2. Cắm cáp, chọn cho phép gỡ lỗi và chấp nhận khóa RSA.
3. Trong terminal tại thư mục dự án chạy:

```bash
./install_android.sh
```

## Chạy trên Ubuntu để trình diễn

Chạy nhanh bằng Godot cục bộ:

```bash
./run_game.sh
```

Hoặc chạy bản Linux độc lập (không cần mở Godot):

```bash
./play_linux.sh
```

Bạn cũng có thể mở thư mục `build/linux`, nhấp chuột phải vào `GiaiCuuNgoiLangHoa.x86_64`, bật quyền **Allow executing file as program**, rồi nhấp đúp để chạy.

Tạo lại bản Linux độc lập:

```bash
./build_linux.sh
```

## Build lại APK

```bash
./build_android.sh
```

## Điều khiển

- Android: cụm bốn nút bên trái để đi; **ĐÁNH**, **SKILL**, **ĐỔI**, **VŨ KHÍ**, **F** ở bên phải.
- Desktop: WASD/mũi tên, Space, E, Q, R và F.
- Khi tiêu diệt đủ kẻ địch, đi tới vòng cổng ở mép phải bản đồ.
- Nhấn F khi có ít nhất 8 vật liệu để chế tạo nâng cấp.
