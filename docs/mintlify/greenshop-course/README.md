# GreenShop — Giáo trình Flutter Vibe Code (Mintlify)

Bộ tài liệu khóa học **Flutter Vibe Code cho người KHÔNG biết lập trình**, case study: app bán rau củ quả xanh tươi **GreenShop**.

## Cấu trúc

- `index.mdx` — Trang tổng quan/giới thiệu khóa học
- `buoi-01/` … `buoi-10/` — 10 buổi học, mỗi buổi 3 file:
  - `lythuyet.mdx` — Giáo trình lý thuyết
  - `thuchanh.mdx` — Bài tập thực hành (lab tại lớp)
  - `baitap.mdx` — Bài tập về nhà
- `docs.json` — Cấu hình navigation cho Mintlify

## Cách dùng

1. Chép toàn bộ nội dung folder này vào dự án Mintlify của bạn (hoặc dùng trực tiếp).
2. Nếu ghép vào dự án có sẵn: copy các trang và **gộp phần `navigation` trong `docs.json`** vào file cấu hình dự án chính của bạn.
3. Xem thử cục bộ:
   ```bash
   npm i -g mint
   mint dev
   ```

## Ghi chú

- Màu thương hiệu chủ đạo: xanh lá `#2F9E44` (đã cấu hình trong `docs.json`).
- Các file dùng component Mintlify: `<Note>`, `<Tip>`, `<Warning>`.
- Nội dung trung lập, không gắn địa danh/thương hiệu cụ thể, phù hợp học viên cả nước.
