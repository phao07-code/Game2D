# BÁO CÁO DỰ ÁN: GIẢI CỨU NGÔI LÀNG HOA

## 1. Tóm tắt

**Giải Cứu Ngôi Làng Hoa** là game 2D Action-Adventure RPG góc nhìn top-down, xây dựng bằng Godot 4 và GDScript. Người chơi điều khiển Kai cùng đội kháng chiến vượt qua năm khu vực để giải cứu dân làng khỏi đế chế Vera. Sản phẩm chạy trên Android 7.0 trở lên và Linux/Desktop.

Điểm khác biệt của đề tài là kết hợp bối cảnh làng quê với khoa học viễn tưởng, cơ chế đổi nhanh nhân vật và hệ thống lựa chọn dẫn tới nhiều kết thúc.

## 2. Mục tiêu và phạm vi

- Tạo vòng lặp game hoàn chỉnh: mở đầu → chiến đấu → nâng cấp → mở khóa khu vực → boss → ending.
- Tối ưu cho điện thoại cấu hình phổ thông, không cần kết nối mạng.
- Không sử dụng thư viện hay asset có rủi ro bản quyền; đồ họa được vẽ bằng API Canvas của Godot.
- Hỗ trợ cả cảm ứng và bàn phím để thuận tiện phát triển, kiểm thử.

## 3. Công nghệ

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| Game engine | Godot 4.5.1 Standard | Scene tree, vật lý, UI, đóng gói Android |
| Ngôn ngữ | GDScript | Gameplay và quản lý trạng thái |
| Android | SDK 35, Build Tools 35 | Biên dịch, ký và kiểm tra APK |
| Java | OpenJDK 17 | Môi trường build Android |
| Renderer | OpenGL Compatibility | Tương thích thiết bị Android phổ thông |

Toàn bộ toolchain được đặt trong `.tools`, không thay đổi cài đặt hệ thống Ubuntu.

## 4. Kiến trúc phần mềm

```text
Main (điều phối game)
├── Quản lý 5 khu vực và nhiệm vụ
├── Player (HoaActor)
│   └── Camera2D
├── Enemies/Boss (HoaActor)
├── Projectiles (HoaProjectile)
└── CanvasLayer
    ├── HUD trạng thái
    ├── Điều khiển cảm ứng
    ├── Hộp thoại cốt truyện
    └── Menu lựa chọn ending
```

`HoaActor` tái sử dụng cho người chơi và nhiều archetype kẻ địch; khác biệt được thiết lập qua dữ liệu nhân vật. Cách tổ chức này giảm trùng lặp và giúp thêm nhân vật mới dễ dàng. `HoaProjectile` chịu trách nhiệm va chạm và sát thương tầm xa. `Main` quản lý state machine của hành trình và dữ liệu lưu.

## 5. Các chức năng đã hoàn thành

### Đối chiếu trực tiếp rubric Module 4.1

| Yêu cầu chấm điểm | Hiện thực trong sản phẩm | Bằng chứng |
|---|---|---|
| Splash/Home có logo, ảnh intro, loading bar, button | Splash toàn màn hình có logo ứng dụng, panorama cốt truyện và thanh nạp 0–100%; Home có Bắt đầu, Tiếp tục, Thoát | `show_splash_screen()`, `show_main_menu()` |
| Background ảnh chuyển động | Hai panorama 1280×720 nối tiếp và cuộn theo thời gian; tốc độ đổi theo màn, phủ dưới lớp địa hình alpha | `_draw()`, biến `panorama_offset` |
| Có từ ba đối tượng chuyển động | A là Kai, B là Samurai đối đầu, C là kiếm/phi tiêu/skill; ngoài ra còn guard, boss, tù nhân, particle và portal | Smoke test + gameplay |
| A ở giữa biên trái, B ở vị trí đối diện | A = `(35, 410)`, B = `(1465, 410)` trong world 1500×820 | Assertion tự động trong `tests/smoke_game.gd` |
| A và B cùng kích thước | Cùng bán kính va chạm 18 và visual scale 3× ở màn rubric | Assertion radius + sprite scale |
| A/B đi ngang, dọc, bốn hướng với tốc độ phù hợp | A nhận vector joystick/WASD; B tuần tra hình số 8 và chuyển sang đuổi theo A trong bốn hướng | `HoaActor._physics_process()` |
| C bắt nguồn từ A và phát khi chạm/click | Click trái, nút ĐÁNH cảm ứng và phím Space dùng cùng action; phi tiêu sinh tại `player + direction × 28` | Assertion tìm `HoaProjectile` cách A ≤ 35 px |
| B chạm biên trái thì tái xuất ở biên phải ngẫu nhiên | Enemy B có cờ `wrap_on_left`; trở về x=1465 và Y ngẫu nhiên 145–775 | `wrap_enemy_if_needed()` + assertion |

Như vậy các đối tượng A/B/C không phải phần minh họa tách rời mà được tích hợp vào vòng chơi chính, vừa đáp ứng đúng bài thực hành vừa phục vụ cốt truyện và combat.

### Gameplay

- Di chuyển top-down và chiến đấu thời gian thực.
- Năm nhân vật: Kai, Lira, Thorn, Ryn và Vex.
- Tiến triển trang bị gắn với truyện: Kiếm Cổ, Phi Tiêu Ryn, Súng Năng Lượng Aria.
- Bốn bí kíp theo từng chương: Kiếm Lốc, Bước Chân Bóng Tối, Hơi Thở Hồi Sinh và Dư Âm Thời Gian.
- Mỗi nhân vật có chỉ số, vai trò, đòn thường và kỹ năng riêng.
- Đổi nhân vật tức thời; người chơi tự chiến đấu, không có đồng đội AI tự động.
- Năm khu vực, độ khó tăng dần và boss Zorath.
- Lên cấp, hồi đầy máu khi lên cấp, tăng chỉ số.
- Thu thập vật liệu và chế tạo lõi tăng sát thương.
- Giải cứu dân làng và thu hồi mảnh công nghệ.
- Ngày/đêm: quái nhanh và gây nhiều sát thương hơn vào ban đêm.
- Ba ending thường và một secret ending dựa trên thành tích, lựa chọn.
- Tự động lưu khi bắt đầu mỗi khu vực và tiếp tục từ menu.

### Chất lượng kỹ thuật

- Camera có giới hạn bản đồ và làm mượt chuyển động.
- Giao diện tự co giãn theo viewport 1280×720.
- Nút cảm ứng dùng `InputMap`, cùng luồng xử lý với bàn phím.
- APK chỉ chứa ABI `arm64-v8a`, giảm dung lượng.
- Render bằng Compatibility mode để tăng tương thích.
- Sprite sheet pixel-art có animation, tileset địa hình và nhạc nền đổi theo chương.
- Hệ thống CanvasModulate và sáu PointLight2D theo từng biome; đèn tăng cường khi trời tối.
- Mỗi khu vực có art direction riêng: làng/rừng dùng cây và nhà hoang; hang dùng đá/cổng; pháo đài dùng panel công nghệ neon.
- VFX particle khi hạ quái, vật phẩm rơi có tween nổi/mờ và icon atlas riêng.
- UI dùng panel bo góc, viền neon, trạng thái hover/pressed và phân cấp màu rõ ràng.
- Joystick analog cảm ứng hỗ trợ kéo tự do, giới hạn bán kính và tự trở về tâm.
- Nút hành động có icon, trạng thái thiếu năng lượng và animation scale khi nhấn.
- Vũ khí hiển thị trên tay, xoay theo hướng nhìn; kiếm, phi tiêu và súng dùng hình ảnh riêng.
- AI tăng theo chất lượng: quái tầm xa từ màn 2, elite bắn chùm, boss bắn năm hướng.
- Guard AI có hai state: tuần tra hình số 8 quanh nhà tù và truy đuổi khi người chơi vào bán kính phát hiện.
- Điều kiện qua màn gồm hai phase bắt buộc: hạ toàn bộ guard, sau đó trực tiếp mở đủ 3/3 nhà tù; cổng không tồn tại trước khi hoàn thành cả hai.
- Asset riêng cho cage, captive villager và portal; lồng mở biến mất và hai người dân bước ra với VFX/âm thanh.
- Bóng tiếp xúc ellipse cho actor, nhà tù và portal; props dùng bóng lệch để tạo cảm giác 2.5D nhưng vẫn giữ gameplay 2D.
- Địa hình ảnh hưởng movement: nước làm chậm 52%, cầu đi bình thường, dốc núi làm chậm 38%, đá nóng làm chậm 28%, gió đảo nổi cản hướng ngược.
- Modal manager bảo đảm intro, defeat, ending và message không bao giờ hiển thị chồng nhau.
- Âm lượng nhạc tăng lên -1 dB và SFX +4 dB để rõ trên loa điện thoại/livestream.
- Android landscape cố định (`screenOrientation=0`), immersive fullscreen, resizeable activity và UI anchor responsive cho màn hình 16:9–20:9.
- Mỗi màn có bảng intro riêng gồm cốt truyện, nhiệm vụ và phần thưởng.
- Năm map có geography riêng: đường làng cháy; rừng mưa có sông và cầu; núi/mỏ có dung nham; pháo đài có đảo mây; nhà tù có mạch tinh vân.
- Art pass cuối phân tách asset theo biome: Làng Hoa có hơn 40 cụm hoa động và tia nắng; Rừng Ninja có tán cây dày, sông, cầu, mây, mưa và splash; Suối Linh Thú dùng tile đá–tuyết cùng vách núi; Núi Máy và Nhà Tù dùng atlas công nghệ/tinh vân riêng.
- Ngôn ngữ VFX thống nhất với tên game: kiếm bung cánh hoa, phi tiêu kéo trail hoa, kỹ năng tạo mandala hai tầng với tâm sáng; icon CHIÊU dùng hoa thay cho biểu tượng chung.
- Năm silhouette quái riêng, projectile bắn chùm, phi tiêu có sprite xoay/trail, kiếm có animation vung và death VFX dạng máu.
- Nhạc phát ngay từ menu; SFX riêng cho UI, kiếm, phi tiêu, trúng đòn, nhặt đồ, mở bí kíp và đổi vũ khí.
- APK debug được ký bằng Signature Scheme v2 và v3.

## 6. Luồng chơi

```text
Menu chính
  → Đèo Samurai: Kiếm cũ → Katana Hoa Thép
  → Rừng Ninja: vượt sông/cầu → Phi Tiêu Gió
  → Suối Linh Thú: né đòn lao Fenrir → Hơi Thở Hồi Sinh
  → Núi Máy Vera: phá Titan → Súng Năng Lượng Aria
  → Nhà Tù Tinh Vân
  → Boss Zorath
  → Lựa chọn đạo đức
  → 1 trong 4 ending
```

Nhịp chơi được thiết kế theo progression kiểu Zelda/CrossCode (phần thưởng mở cách đánh mới), dodge/telegraph kiểu Hades và combat tốc độ cao của Hyper Light Drifter. Thời lượng mục tiêu cho người chơi lần đầu là khoảng 12–18 phút, phụ thuộc khả năng né chiêu và đọc hội thoại.

Nghiên cứu và liên kết nguồn được trình bày riêng trong `docs/NGHIEN_CUU_GAME_THAM_KHAO.md`.

Người chơi tiêu diệt đủ lực lượng canh giữ để mở cổng phía Đông. Cứ mỗi ba kẻ địch bị hạ, một nhóm dân làng được cứu. Thu đủ tám vật liệu cho phép chế tạo lõi tăng cường. Secret ending yêu cầu cứu đủ dân, thu đủ bốn mảnh công nghệ và chọn đàm phán bằng Aria.

## 7. Kiểm thử

| Mã | Trường hợp | Kết quả mong đợi |
|---|---|---|
| TC01 | Khởi động ứng dụng | Hiện menu, không crash |
| TC02 | Giữ bốn nút di chuyển | Nhân vật đi đúng hướng, không vượt biên |
| TC03 | Tấn công trúng quái | HP quái giảm, quái biến mất khi HP bằng 0 |
| TC04 | Dùng skill khi thiếu năng lượng | Không thi triển, hiện thông báo |
| TC05 | Nhấn ĐỔI | Nhân vật điều khiển được cập nhật, không sinh AI hỗ trợ |
| TC06 | Đủ 8 vật liệu rồi nhấn F | Trừ 8 vật liệu, sát thương tăng 3 |
| TC07 | Qua đủ mục tiêu khu vực | Cổng phía Đông xuất hiện |
| TC08 | Nhân vật hết HP | Khu vực được khởi động lại |
| TC09 | Thoát rồi chọn TIẾP TỤC | Nạp đúng khu vực và tiến trình |
| TC10 | Hạ boss và chọn phương án | Hiện ending tương ứng |
| TC11 | Đủ điều kiện bí mật | Hiện Secret Ending |
| TC12 | Build Android | APK ký hợp lệ, package và SDK đúng |
| TC13 | Hạ hết guard nhưng chưa mở tù | Cổng vẫn ẩn, HUD chuyển sang 0/3 nhà tù |
| TC14 | Mở đủ ba nhà tù | Nhận reward và cổng mới xuất hiện |
| TC15 | Kiểm tra bố cục mobile | Sáu nút tròn không giao nhau ở viewport 1280×720 |
| TC16 | Quan sát splash từ lúc mở app | Logo, ảnh intro và loading bar chạy 0–100%, sau đó Home xuất hiện |
| TC17 | Kiểm tra vị trí ban đầu A/B | A giữa biên trái, B giữa biên phải, kích thước bằng nhau |
| TC18 | Đưa B chạm biên trái | B tái xuất biên phải tại Y ngẫu nhiên hợp lệ |
| TC19 | Click trái / chạm nút ĐÁNH với phi tiêu | C xuất hiện từ tay A, bay đúng hướng và có trail xoay |

Kiểm tra tự động hiện tại: Godot import/parse toàn bộ script không lỗi; Android exporter hoàn tất; `apksigner verify` xác nhận chữ ký v2/v3; `aapt2 dump badging` xác nhận package, SDK và ABI.

## 8. Cách trình diễn trước hội đồng

1. Giới thiệu vấn đề, cốt truyện và điểm khác biệt trong khoảng 45 giây.
2. Cho xem menu và điều khiển cảm ứng.
3. Trình diễn Kai đánh xa, Lira đánh gần, Thorn hồi máu rồi đổi nhân vật.
4. Trình diễn tuần tra quanh nhà tù, phạm vi phát hiện và nút né skill.
5. Nhặt đủ vật liệu, chế tạo nâng cấp và giải thích vòng lặp tiến triển.
6. Cho xem cổng chuyển khu, chu kỳ ngày/đêm và save/load.
7. Dùng bản save gần boss nếu thời gian hạn chế, trình diễn lựa chọn ending.
8. Kết thúc bằng kiến trúc tái sử dụng `HoaActor` và kết quả kiểm tra APK.

## 9. Hạn chế và hướng phát triển

- Đồ họa procedural phù hợp prototype; có thể thay bằng sprite pixel-art và animation nhiều frame.
- Bổ sung âm nhạc, hiệu ứng âm thanh, rung phản hồi và tùy chỉnh âm lượng.
- Tách từng khu vực thành scene riêng khi quy mô nội dung tăng.
- Thêm hệ thống hội thoại dạng cây, inventory nhiều ô và boss nhiều phase.
- Tạo release keystore/AAB trước khi phát hành Google Play.

## 10. Kết luận

Sản phẩm đáp ứng một vòng chơi hoàn chỉnh trên Android, thể hiện được kiến thức về lập trình hướng thành phần, điều khiển cảm ứng, AI đơn giản, quản lý trạng thái, lưu dữ liệu và quy trình build/ký APK. Kiến trúc hiện tại đủ gọn cho đồ án nhưng vẫn có điểm mở rộng rõ ràng.
