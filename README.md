# Giải Cứu Ngôi Làng Hoa — Project Complete

Game 2D top-down trên **Godot 4** (GDScript).  
Tổng hợp toàn bộ yêu cầu module + rubric từ repo gốc:
https://github.com/nhtng0212/Game2D_Android_KMA

## Cốt truyện
Kai (2147) xuyên không về ngày Làng Hoa thất thủ. Qua 3 cấp: Đèo Samurai → Rừng Ninja → Nhà Tù Tinh Vân, hạ Zorath và chọn Ending để WIN.

## Phong cách
Pixel/tile Kenney, biome riêng từng cấp, parallax, ngày-đêm, UI cyan/vàng/tím.

## 3 cấp
1. Đèo Samurai — 4 canh, 3 nhà tù, Cổng Đông  
2. Rừng Ninja — 5 ninja, cứu tù, Phi Tiêu  
3. Nhà Tù Tinh Vân — Boss Zorath → Ending → WIN  

## NPC AI
- patrol: tuần tra số 8, đuổi khi gần  
- chase: đuổi + né đòn (~55%)  
- ranged: giữ khoảng cách + bắn  

## Hệ thống
Save sau mỗi cấp / Game Over · Home chọn màn đã chơi · GO/Win UI ≥3 nút · SFX win/lose riêng · 5 hero · nhiều vũ khí · XP/level  

## Chạy
Godot 4.3+ → Import `Game2D_Complete` → F5  

WASD di chuyển · Space đánh · E chiêu · Z né · F mở tù · Esc pause  

Chi tiết rubric: `docs/RUBRIC_CHECKLIST.md`
