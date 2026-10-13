# Báo cáo tổng hợp — Giải Cứu Ngôi Làng Hoa (Complete)

**Nguồn gốc:** Clone & mở rộng từ https://github.com/nhtng0212/Game2D_Android_KMA  
**Engine:** Godot 4 · **Ngôn ngữ:** GDScript · **Nền tảng:** Desktop / Android  

---

## 1. Cơ sở dự án

Project **Game2D_Complete** được xây trên toàn bộ cấu trúc, asset và gameplay gốc của repo GitHub trên (nhân vật, tile, nhạc, sfx, joystick cảm ứng, nhà tù, portal, 5 hero…).

Các module yêu cầu trong khóa học được **ghép vào cùng một bản** để báo cáo / demo.

---

## 2. Cốt truyện & nghệ thuật

| Hạng mục | Nội dung |
|----------|----------|
| Cốt truyện | Kai (2147) xuyên không cứu Làng Hoa khỏi Vera; 3 chương + nhiều Ending |
| Phong cách | Pixel/tile (Kenney), palette theo biome, parallax, ngày–đêm |
| Thế giới | 3 bản đồ: Đèo Samurai → Rừng Ninja → Nhà Tù Tinh Vân |

---

## 3. Cơ chế & gameplay

- Di chuyển: WASD / virtual joystick  
- Tấn công ≥3: Kiếm, Katana, Phi tiêu, Súng Aria  
- Phòng thủ: Né (dodge), chiêu / hồi  
- Nhiệm vụ: Hạ lính canh → mở 3 nhà tù (F) → Cổng Đông  
- XP / lên cấp, nhiều hero, loot  
- **WIN:** Hạ Zorath + chọn Ending  
- **GAME OVER:** Hết máu + SFX riêng  

---

## 4. Hệ thống cấp độ & lưu game

| Cấp | Mục tiêu |
|-----|----------|
| 1 | 4 canh + 3 tù + Cổng Đông |
| 2 | 5 ninja + cứu tù + Cổng Đông |
| 3 | Boss Zorath → Ending → WIN |

**Lưu tự động** (`user://hoa_save.json`) khi: hoàn thành cấp, sang map, Game Over, bắt đầu màn.  
**Home → Màn đã chơi:** xem / chọn lại cấp đã mở khóa.

---

## 5. NPC thông minh (AI)

| Loại | Hành vi |
|------|---------|
| patrol | Tuần tra hình số 8; đuổi khi player vào tầm |
| chase | Đuổi áp sát; **né đòn** ~55% khi bị đánh |
| ranged | Giữ khoảng cách; bắn từ xa |

---

## 6. Màn hình UI báo cáo

1. Splash + loading  
2. Home (save tóm tắt, Tiếp tục, **Màn đã chơi**)  
3. Intro từng cấp  
4. HUD (HP, energy, cấp, vũ khí, nhiệm vụ)  
5. Game Over: Replay · Thống số · Home · Help + `game_over.ogg`  
6. Win: Replay · Home · Tiến độ + `win_fanfare.ogg`  
7. Help / Nhật ký thống số  

---

## 7. Cách demo khi báo cáo

1. Mở Godot 4 → Import `Game2D_Complete` → F5  
2. Bắt đầu cấp 1 → giới thiệu combat + AI  
3. (Tuỳ thời gian) sang cấp / chết để show Game Over + Thống số  
4. Home → **Màn đã chơi**  
5. Nhắc checklist rubric trong `docs/RUBRIC_CHECKLIST.md`  

---

## 8. File giao nộp

- Folder: `Game2D_Complete/`  
- Nén: `Game2D_Complete.zip`  
