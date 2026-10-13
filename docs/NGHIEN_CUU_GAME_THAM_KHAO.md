# Nghiên cứu game tham khảo và quyết định thiết kế

Tài liệu này ghi rõ nguồn cảm hứng cơ chế, phần được áp dụng và lý do. Dự án không sao chép nhân vật, cốt truyện hay mã nguồn của các game tham khảo.

## Hades — Supergiant Games

Nguồn: https://www.supergiantgames.com/games/hades/

Điểm học hỏi: dash ngắn có khung tránh sát thương; đòn nguy hiểm cần báo trước bằng màu/vòng hiệu ứng; số quái không cần quá nhiều nếu mỗi archetype buộc người chơi phản ứng khác nhau.

Áp dụng: nút **NÉ** có cooldown và 0,42 giây bất tử; Titan tạo vòng cảnh báo; Fenrir báo hiệu rồi lao; Zorath bắn barrage hình quạt.

## The Legend of Zelda: Link's Awakening — Nintendo

Nguồn: https://www.nintendo.com/us/store/products/the-legend-of-zelda-links-awakening-switch/

Điểm học hỏi: mỗi khu vực có “luật di chuyển” và landmark riêng; phần thưởng dungeon mở một cách tương tác mới thay vì chỉ tăng chỉ số.

Áp dụng: sông làm chậm nhưng cầu đi bình thường; dốc núi làm chậm; gió đảo nổi cản khi đi ngược; Katana, Phi Tiêu và Súng Aria lần lượt mở sau từng chương.

## CrossCode — Radical Fish Games

Nguồn: https://www.cross-code.com/en/home

Điểm học hỏi: kết hợp cận chiến, projectile và né trong cùng bộ điều khiển; vùng chơi có nhịp khám phá–đánh–nhận phần thưởng.

Áp dụng: chuyển vũ khí tức thời, phi tiêu có hướng/trail, súng có damage khác, từng màn có intro–nhiệm vụ–mini-boss–reward–cổng ra.

## Hyper Light Drifter — Heart Machine

Nguồn: https://heartmachine.com/hyper-light

Điểm học hỏi: silhouette rõ, palette theo biome, ánh sáng/màu neon truyền tải công nghệ và nhịp đánh–lướt nhanh.

Áp dụng: màu riêng cho năm biome; ánh sáng vàng/xanh/tím; VFX cung kiếm, năng lượng và Dư Âm Thời Gian; weapon hiển thị theo hướng nhìn.

## Bastion — Supergiant Games

Nguồn: https://www.supergiantgames.com/games/bastion/

Điểm học hỏi: cốt truyện được chia thành địa điểm có mục tiêu và phần thưởng rõ, nhạc nền hỗ trợ bản sắc từng vùng.

Áp dụng: bảng đầu màn ghi cốt truyện/nhiệm vụ/phần thưởng; ba nhóm nhạc village–adventure–danger; ending dựa trên lựa chọn đạo đức.

## Metal Gear / cơ chế stealth–aggro phổ biến

Điểm học hỏi: kẻ địch nên có trạng thái tuần tra và chỉ truy đuổi sau khi phát hiện người chơi, giúp người chơi quan sát và chủ động tiếp cận.

Áp dụng: quân canh tuần tra hình số 8 quanh ba nhà tù; bán kính phát hiện giới hạn; ngoài bán kính chúng không tấn công hoặc bắn skill.

## Kết luận thiết kế

Vòng lặp hiện tại là:

```text
Đọc nhiệm vụ → quan sát lính tuần tra → chọn hướng tiếp cận
→ đánh/né/đổi vũ khí → hạ mini-boss → nhận trang bị hoặc bí kíp
→ địa hình và enemy rule mới ở màn tiếp theo → Zorath → giải cứu làng
```

Sự tăng độ khó dựa trên hành vi và luật màn chơi, không chỉ dựa trên số lượng hoặc HP.
