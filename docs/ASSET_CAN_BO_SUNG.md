# Asset tùy chọn để nâng chất lượng lên mức trình diễn cuối kỳ

Bản hiện tại đã chạy đủ và dùng asset CC0. Những mục dưới đây **không bắt buộc để chạy game**, nhưng nếu bạn có họa sĩ hoặc tìm được pack đồng bộ thì có thể thay thế để sản phẩm có bản sắc riêng hơn.

## 1. Nhân vật chính

Đặt trong `assets/characters/custom/`:

| Tên file | Kích thước đề xuất | Nội dung |
|---|---:|---|
| `kai_sheet.png` | 256×256 | 4 hướng; idle/run/sword/shuriken/gun/hurt/death |
| `lira_sheet.png` | 256×256 | 4 hướng; idle/run/slash/spin/hurt/death |
| `thorn_sheet.png` | 256×256 | 4 hướng; idle/run/cast/heal/hurt/death |
| `ryn_sheet.png` | 256×256 | 4 hướng; idle/run/throw/bow/hurt/death |
| `vex_sheet.png` | 256×256 | 4 hướng; idle/run/cast/teleport/hurt/death |

Mỗi frame nên là 32×32, nền trong suốt, không có chữ hoặc watermark. Tất cả nhân vật cần cùng góc nhìn top-down 3/4 và cùng palette.

## 2. Kẻ địch và boss

Đặt trong `assets/enemies/custom/`:

- `vera_scout_sheet.png`: lính nhanh, bắn một viên.
- `infected_beast_sheet.png`: quái lao tới và cắn.
- `mining_golem_sheet.png`: chậm, giáp cao, đập đất.
- `vera_elite_sheet.png`: né và bắn ba hướng.
- `zorath_boss_sheet.png`: tối thiểu idle, walk, cast, rage, hurt, death; frame 64×64.

## 3. VFX riêng

Đặt trong `assets/vfx/custom/`, sprite sheet ngang, nền trong suốt:

- `sword_arc.png`: 6 frame, 64×64/frame.
- `shuriken_trail.png`: 6 frame, 32×32/frame.
- `energy_muzzle.png`: 6 frame, 48×48/frame.
- `heal_bloom.png`: 8 frame, 96×96/frame.
- `shadow_step.png`: 8 frame, 96×96/frame.
- `time_echo.png`: 10 frame, 128×128/frame.
- `boss_barrage.png`: 10 frame, 128×128/frame.

## 4. Minh họa cốt truyện

Đặt trong `assets/story/`, ảnh ngang 16:9, 1280×720:

- `prologue_village_fall.png`
- `chapter_1_kai_awakes.png`
- `chapter_2_fog_temple.png`
- `chapter_3_future_core.png`
- `chapter_4_vex_betrayal.png`
- `chapter_5_prison_gate.png`
- `ending_peace.png`, `ending_return.png`, `ending_destroy.png`, `ending_secret.png`

Đây là hạng mục mang lại khác biệt lớn nhất khi báo cáo vì asset CC0 hiện không thể diễn tả chính xác Kai, Vera và các cảnh truyện riêng.

## 5. Âm thanh giọng nói (không bắt buộc)

Đặt trong `assets/voice/vi/`, định dạng OGG mono:

- `aria_prologue.ogg`, `aria_reward_1.ogg` … `aria_reward_4.ogg`
- `zorath_intro.ogg`, `vex_betrayal.ogg`, `ending_narration.ogg`

Nên thu trong phòng yên, peak khoảng -3 dB và loại noise trước khi xuất.
