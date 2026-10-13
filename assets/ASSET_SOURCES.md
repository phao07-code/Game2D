# Nguồn asset

Các sprite, tileset, hiệu ứng và nhạc nền trong thư mục này được chọn lọc từ dự án **Ninja Adventure** của Pixel-boy:

- Repository: https://github.com/pixel-boy/NinjaAdventure
- Trang phát hành: https://pixel-boy.itch.io/ninja-adventure-asset-pack
- Giấy phép được tác giả công bố cho asset pack: CC0 / public domain.

Tên file đã được đổi theo vai trò trong game để mã nguồn dễ đọc. Các chỉnh sửa về tỉ lệ, màu sắc và cách ghép cảnh được thực hiện trong Godot. Biểu tượng `icon.svg` là nội dung riêng của dự án.

Nhóm asset môi trường/VFX bổ sung trong bản hoàn thiện:

- `tiles/flowers_animated.png`: bốn frame hoa chuyển động, dùng cho thảm hoa và icon skill.
- `fx/flower_petals.png`: chín frame cánh hoa, dùng cho kiếm, phi tiêu và vòng skill.
- `fx/sun_rays.png`: tia nắng xuyên tán cây tại Làng Hoa.
- `fx/cloud_layer.png`: lớp mây chuyển động tại rừng mưa/đảo nổi.
- `fx/rain_splash.png`: animation giọt mưa chạm mặt đất.

Năm file trên được lấy trực tiếp từ thư mục `content/map`, `content/particle` và `system/environment/fx` của Ninja Adventure CC0, không qua nguồn trung gian.

## Kenney CC0 packs

- Tiny Town: https://kenney.nl/assets/tiny-town
- Roguelike RPG Pack: https://kenney.nl/assets/roguelike-rpg-pack
- Roguelike Caves & Dungeons: https://kenney.nl/assets/roguelike-caves-dungeons
- Roguelike Characters: https://kenney.nl/assets/roguelike-characters
- UI Pack RPG Expansion: https://kenney.nl/assets/ui-pack-rpg-expansion
- UI Pack Pixel Adventure: https://kenney.nl/assets/ui-pack-pixel-adventure
- Impact Sounds, Interface Sounds và RPG Audio: https://kenney.nl/assets/category:Audio

Các bộ Kenney mang giấy phép CC0 1.0. Bản giấy phép đi kèm được lưu tại `assets/LICENSE_KENNEY.txt`. Dự án dùng chúng cho cây, đá, công trình, dungeon, đồ rơi, bình năng lượng, tinh thể và chi tiết UI.

## OpenGameArt

- Zelda-like tilesets and sprites: https://opengameart.org/content/zelda-like-tilesets-and-sprites
- Giấy phép trên trang nguồn: CC0.

Bộ này được lưu làm nguồn tham khảo trong `.tools/assets-source`; chưa đóng gói vào bản build hiện tại để tránh pha trộn palette không cần thiết.
# Asset tự thiết kế trong dự án

- `backgrounds/intro_panorama.svg`: panorama làng–núi–cổng Aria dùng cho splash, Home và nền cuộn gameplay; thiết kế riêng cho đồ án, không lấy từ nguồn ngoài.
- `ui/loading_frame.svg`: khung loading neon vector thiết kế riêng cho splash.
