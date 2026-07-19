# Thiết kế: Hoàn thiện app thương mại điện tử "Everyday Store"

Ngày: 2026-07-19
Trạng thái: Đã triển khai

TASK triển khai: [`../plans/2026-07-19-ecommerce-completion-tasks.md`](../plans/2026-07-19-ecommerce-completion-tasks.md)

## Mục tiêu

Nâng app tutorial dùng mock data hiện tại thành một app portfolio/demo chạy end-to-end: giỏ hàng hoạt động thật, checkout giả lập với lịch sử đơn hàng, đăng ký/đăng nhập local có giữ phiên, wishlist, dark mode. Không dùng backend — toàn bộ dữ liệu local, demo luôn chạy được không cần mạng.

**Không nằm trong phạm vi:** backend thật, thanh toán thật, push notification, deep linking, ảnh sản phẩm thật (giữ phong cách icon + màu hiện tại).

## Quyết định công nghệ

| Hạng mục | Lựa chọn | Lý do |
|---|---|---|
| State management | `flutter_riverpod` | Chuẩn cộng đồng, compile-safe, dễ test |
| Lưu trữ | `shared_preferences` (JSON qua wrapper `LocalStore`) | Đủ cho dữ liệu key-value cỡ nhỏ, không cần DB |
| Format tiền | `intl` | Format giá chuẩn |
| JSON | `toJson`/`fromJson` viết tay | Không cần codegen cho app cỡ này |
| Navigation | Navigator 1.0 named routes (giữ hiện trạng) | Không cần deep link, tránh phức tạp go_router |
| Kiến trúc | Feature-first: `lib/features/<feature>/data + presentation` | Chuẩn phổ biến, đẹp cho portfolio |

## Cấu trúc thư mục

```
lib/
  main.dart                  # entry: ProviderScope, đọc session để chọn màn khởi đầu
  app/
    app.dart                 # MaterialApp, routes, themeMode từ provider
    theme.dart               # light + dark ThemeData (seed 0xFF1B5E4B)
  core/
    local_store.dart         # wrapper shared_preferences: đọc/ghi JSON theo key
  shared/
    store_scaffold.dart      # StorePage, StoreHeader, ProductSearchField
  features/
    auth/
      data/                  # user_model.dart, auth_repository.dart
      presentation/          # login_screen, register_screen, auth_card, auth_fields, auth_providers
    catalog/
      data/                  # product.dart, category.dart, promo.dart, seed_data.dart, catalog_repository.dart
      presentation/          # home_tab, categories_tab, category_products_screen, product_detail_screen, catalog_providers
    cart/
      data/                  # cart_item.dart, cart_repository.dart
      presentation/          # cart_tab, cart_providers
    orders/
      data/                  # order.dart, order_repository.dart
      presentation/          # checkout_screen, order_success_screen, order_history_screen, order_providers
    wishlist/
      data/                  # wishlist_repository.dart
      presentation/          # wishlist_screen, wishlist_providers
    notifications/
      data/                  # notification_model.dart, notification_repository.dart
      presentation/          # notifications_tab, notification_providers
    account/
      presentation/          # account_tab (kèm toggle dark mode, logout, link tới orders/wishlist)
  screens/
    main_screen.dart         # NavigationBar + IndexedStack 5 tab
```

Nguyên tắc phân lớp: **UI (widgets) → Providers (Riverpod state) → Repositories (đọc/ghi LocalStore hoặc seed data)**. UI không truy cập storage trực tiếp.

## Dữ liệu

### Catalog (bất biến, không persist)
- `Product`: id, name, price, rating, reviews, icon, color, **categoryId** (mới — liên kết product với category), description.
- `Category`: id, name, icon, color (bỏ trường `items` hard-code — đếm từ products).
- `Promo`: giữ như hiện tại.
- Seed data mở rộng lên ~24–30 sản phẩm phủ đều các category, đặt trong `seed_data.dart`.

### Persist qua LocalStore (mỗi mục một key, giá trị JSON)
| Key | Nội dung |
|---|---|
| `users` | Danh sách tài khoản đã đăng ký (name, email, password) |
| `session` | Email user đang đăng nhập (null = chưa đăng nhập) |
| `cart` | List {productId, quantity} |
| `orders` | List đơn hàng (id, items, total, date, status) |
| `wishlist` | List productId |
| `theme_mode` | `light` / `dark` / `system` |
| `notifications` | Notifications phát sinh (vd. đặt hàng thành công) + trạng thái đã đọc |

Lỗi đọc storage / JSON hỏng → trả về giá trị rỗng mặc định, app không crash.

> Lưu ý demo: password lưu plaintext, ghi comment rõ trong code rằng đây là app demo, không dùng cho production.

## Luồng tính năng

### Auth (local)
- **Register:** validate như hiện tại + kiểm tra email trùng → lưu vào `users` → tự đăng nhập, vào MainScreen.
- **Login:** kiểm tra với `users` đã đăng ký **và** tài khoản demo có sẵn `admin@claude.ai / 147258369` (giữ cho tests và người xem demo). Thành công → ghi `session` → `pushNamedAndRemoveUntil` sang MainScreen.
- **Giữ phiên:** `main.dart` đọc `session` trước khi `runApp` → có phiên thì initialRoute là MainScreen, không thì Login.
- **Logout:** trong Account, xóa `session`, quay về Login (xóa stack).

### Catalog
- Search ở Home lọc products theo tên (realtime).
- Categories tab: tap category → `CategoryProductsScreen` liệt kê sản phẩm thuộc category.
- Tap product ở mọi nơi → `ProductDetailScreen`: icon lớn, tên, giá, rating/reviews, mô tả, chọn số lượng, nút **Add to cart**, nút toggle **wishlist**.

### Cart
- `CartNotifier` (Riverpod): add / tăng / giảm / xóa item, tính tổng; mọi thay đổi persist ngay.
- Badge Cart trên NavigationBar hiển thị tổng số lượng thật, ẩn khi giỏ trống (thay badge "3" hard-code).
- Giỏ trống → empty state + nút "Tiếp tục mua sắm" (chuyển về Home tab).

### Checkout + Orders
- Từ Cart (giỏ không trống) → `CheckoutScreen`: form địa chỉ giao hàng + chọn phương thức thanh toán giả (COD / thẻ demo) → xác nhận.
- Tạo `Order` (id, snapshot items + giá, total, date, status `Processing`) → lưu `orders` → xóa cart → `OrderSuccessScreen` → sinh notification "Đặt hàng thành công".
- `OrderHistoryScreen` mở từ Account: danh sách đơn, tap xem chi tiết.

### Wishlist
- Toggle trái tim ở product card và detail; persist list productId; `WishlistScreen` mở từ Account.

### Notifications
- Hiển thị seed tĩnh + notifications phát sinh; tap đánh dấu đã đọc; badge tab Updates theo số chưa đọc thật.

### Dark mode
- Toggle trong Account → `themeModeProvider` → persist. `theme.dart` định nghĩa cả light và dark từ cùng seed color.
- Dọn các chỗ hardcode màu (`Colors.white` trong auth_fields, navigationBarTheme, `fillColor`…) sang `ColorScheme` để dark mode hiển thị đúng.

## Testing

- Giữ convention `ValueKey` test key hiện có (`<prefix>-primary-button`, `email-field`…); cập nhật 2 widget test hiện tại theo luồng mới.
- Unit tests: `AuthRepository` (đăng ký trùng email, login đúng/sai), `CartNotifier` (add/tăng/giảm/xóa, tính tổng), `OrderRepository` (tạo đơn, đọc lại).
- Widget tests luồng chính: đăng ký → tự đăng nhập; login demo → add to cart từ detail → badge cập nhật → checkout → đơn xuất hiện trong lịch sử; toggle dark mode đổi theme.
- Test dùng `SharedPreferences.setMockInitialValues` để cô lập storage.

## Thứ tự triển khai dự kiến (phác thảo cho plan)

1. Nền tảng: thêm dependencies, `LocalStore`, tái cấu trúc feature-first (di chuyển file, app vẫn chạy như cũ).
2. Theme light/dark + dọn màu hardcode + `themeModeProvider` + toggle.
3. Catalog: models mới + seed data mở rộng + search/filter + category screen + product detail.
4. Cart: notifier + persist + badge động + empty state.
5. Auth local: repository + register/login/session/logout.
6. Checkout + orders + notification phát sinh.
7. Wishlist.
8. Hoàn thiện tests + cập nhật CLAUDE.md theo cấu trúc mới.
