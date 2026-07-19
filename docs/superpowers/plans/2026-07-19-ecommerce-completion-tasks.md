# TASK triển khai: Hoàn thiện “Everyday Store”

Ngày: 2026-07-19  
Nguồn thiết kế: [`../specs/2026-07-19-ecommerce-completion-design.md`](../specs/2026-07-19-ecommerce-completion-design.md)  
Trạng thái: Đã triển khai

## Mục tiêu triển khai

Biến UI mock hiện tại thành demo thương mại điện tử chạy end-to-end hoàn toàn bằng dữ liệu local: auth giữ phiên, catalog có tìm kiếm và chi tiết, cart persist, checkout tạo order, notification, wishlist và dark mode.

Mỗi task bên dưới phải kết thúc ở trạng thái:

- `flutter analyze` không phát sinh lỗi mới.
- Các test được chỉ định trong task đều pass.
- App vẫn khởi động được; không để một bước refactor dở dang làm hỏng build.
- UI chỉ gọi provider; provider gọi repository; repository mới được đọc/ghi `LocalStore`.

## Quy ước chung trước khi code

- Dùng `ConsumerWidget`/`ConsumerStatefulWidget` cho UI cần Riverpod; không tạo singleton global cho repository hoặc storage.
- Provider đọc storage nên biểu diễn loading/error rõ ràng bằng `AsyncValue`; lỗi storage/JSON trả dữ liệu mặc định thay vì làm app crash.
- Giá hiển thị qua một helper dùng `NumberFormat.currency(symbol: '\$', decimalDigits: 0)`; không rải `toStringAsFixed` trong widget mới.
- Giữ các key auth hiện có: `login-primary-button`, `login-secondary-button`, `register-primary-button`, `register-secondary-button`, `name-field`, `email-field`, `password-field`.
- Thêm key ổn định cho luồng end-to-end: `product-card-<id>`, `wishlist-<id>`, `add-to-cart-button`, `cart-badge`, `checkout-button`, `place-order-button`, `theme-mode-switch`, `logout-button`.
- Password plaintext chỉ được chấp nhận cho demo này. Đặt comment cảnh báo ngay tại `AuthRepository`; không mô tả cách làm này như giải pháp production.
- Không persist `IconData`, `Color` hay toàn bộ catalog. Cart/wishlist chỉ persist ID; order snapshot persist dữ liệu nghiệp vụ cần thiết.

---

## Task 1 — Thêm dependencies và lớp lưu trữ local an toàn

**Files**

- Modify: `pubspec.yaml`
- Create: `lib/core/local_store.dart`
- Create: `test/core/local_store_test.dart`

**Thực hiện**

1. Thêm package bằng lệnh để Flutter tự chọn phiên bản tương thích SDK:

   ```bash
   flutter pub add flutter_riverpod shared_preferences intl
   ```

2. Viết test thất bại trước cho `LocalStore` với `SharedPreferences.setMockInitialValues`:
   - đọc key chưa tồn tại trả fallback;
   - ghi rồi đọc lại Map/List JSON;
   - chuỗi JSON hỏng trả fallback, không throw;
   - `remove(key)` xóa dữ liệu.
3. Tạo `LocalStore` nhận `SharedPreferences` qua constructor, cung cấp tối thiểu `readJson`, `writeJson`, `readString`, `writeString`, `remove`.
4. Mọi decode/cast lỗi phải được bắt tại boundary này và trả fallback. Không nuốt lỗi ghi dữ liệu.

**Kiểm chứng**

```bash
flutter test test/core/local_store_test.dart
flutter analyze
```

**Done khi** LocalStore được test độc lập, không widget/repository nào gọi `SharedPreferences` trực tiếp.

---

## Task 2 — Dựng app shell và migrate feature-first không đổi hành vi

**Files**

- Create: `lib/app/app.dart`
- Create: `lib/app/theme.dart`
- Create: `lib/shared/store_scaffold.dart`
- Create/move: `lib/features/auth/presentation/auth_card.dart`
- Create/move: `lib/features/auth/presentation/auth_fields.dart`
- Create/move: `lib/features/auth/presentation/login_screen.dart`
- Create/move: `lib/features/auth/presentation/register_screen.dart`
- Create/move: `lib/features/catalog/presentation/home_tab.dart`
- Create/move: `lib/features/catalog/presentation/categories_tab.dart`
- Create/move: `lib/features/cart/presentation/cart_tab.dart`
- Create/move: `lib/features/notifications/presentation/notifications_tab.dart`
- Create/move: `lib/features/account/presentation/account_tab.dart`
- Modify: `lib/main.dart`
- Modify: `lib/screens/main_screen.dart`
- Delete sau khi mọi import đã chuyển: `lib/widgets/`, `lib/screens/main_components/`, `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`

**Thực hiện**

1. Tạo `EverydayStoreApp` trong `app.dart`; tạm thời giữ nguyên routes, theme light và `initialRoute` hiện tại.
2. Chuyển theme hiện tại sang `app/theme.dart` với hàm tạo `ThemeData`, chưa thêm dark mode ở task này.
3. Di chuyển shared store chrome và các màn/tab vào feature tương ứng. Chỉ sửa import và tên class cần thiết; chưa thay data/state.
4. `main.dart` chỉ còn bootstrap và bọc app trong `ProviderScope`.
5. Cập nhật widget test hiện có để pump `ProviderScope(child: EverydayStoreApp(...))` nếu cần, nhưng giữ nguyên hai luồng test đang có.
6. Chỉ xóa file cũ sau khi `rg` xác nhận không còn import.

**Kiểm chứng**

```bash
rg "screens/main_components|widgets/auth_chrome|screens/login_screen|screens/register_screen" lib test
flutter test test/widget_test.dart
flutter analyze
```

**Done khi** cấu trúc feature-first đã tồn tại, hai test cũ vẫn pass và UI chưa thay đổi chức năng.

---

## Task 3 — Theme light/dark có persist

**Files**

- Modify: `lib/app/theme.dart`
- Modify: `lib/app/app.dart`
- Create: `lib/features/account/presentation/theme_mode_provider.dart`
- Modify: `lib/features/account/presentation/account_tab.dart`
- Modify: `lib/features/auth/presentation/auth_fields.dart`
- Modify các widget còn hardcode màu trong `lib/features/**/presentation/`
- Create: `test/features/account/theme_mode_provider_test.dart`

**Thực hiện**

1. Viết test provider: mặc định `system`, đọc `theme_mode`, đổi mode thì persist đúng chuỗi.
2. Implement notifier cho `ThemeMode.system/light/dark`, dùng key `theme_mode`.
3. Tạo `lightTheme` và `darkTheme` từ seed `0xFF1B5E4B`; cấu hình component theme dùng `ColorScheme` theo brightness.
4. Cho `EverydayStoreApp` watch provider và gán `theme`, `darkTheme`, `themeMode`.
5. Thêm control trong Account với key `theme-mode-switch`. Nếu UI là switch nhị phân thì đổi light/dark; nếu dùng menu ba trạng thái phải hỗ trợ cả system.
6. Dọn `Colors.white`, fill/background cố định ở auth fields, navigation bar và surface cards. Màu trắng có chủ ý trên nền promo/brand có thể giữ nếu đảm bảo contrast.

**Kiểm chứng**

```bash
flutter test test/features/account/theme_mode_provider_test.dart
rg -n "Colors\.white|Color\(0xFFF5F1E8\)" lib
flutter analyze
```

**Done khi** đổi theme cập nhật app ngay, relaunch vẫn giữ lựa chọn và text/field/card đọc được ở dark mode.

---

## Task 4 — Chuẩn hóa catalog model, seed data và providers

**Files**

- Create: `lib/features/catalog/data/product.dart`
- Create: `lib/features/catalog/data/category.dart`
- Create: `lib/features/catalog/data/promo.dart`
- Create: `lib/features/catalog/data/seed_data.dart`
- Create: `lib/features/catalog/data/catalog_repository.dart`
- Create: `lib/features/catalog/presentation/catalog_providers.dart`
- Create: `test/features/catalog/catalog_repository_test.dart`
- Delete sau migrate: model/data catalog tạm còn sót từ cấu trúc cũ

**Thực hiện**

1. Viết test repository cho:
   - có 24–30 product với ID duy nhất;
   - mọi `Product.categoryId` trỏ tới category tồn tại;
   - mọi category có ít nhất một product;
   - tìm kiếm không phân biệt hoa thường và bỏ khoảng trắng đầu/cuối;
   - lọc theo category trả đúng tập sản phẩm.
2. Tạo model immutable:
   - `Product(id, name, price, rating, reviews, icon, color, categoryId, description)`;
   - `Category(id, name, icon, color)`;
   - `Promo` tương đương dữ liệu hiện tại.
3. Chuyển dữ liệu hiện tại và mở rộng seed đủ 24–30 sản phẩm, phủ đều sáu category.
4. `CatalogRepository` chỉ đọc seed data, cung cấp `allProducts`, `categories`, `promos`, `findById`, `search`, `byCategory`.
5. Tạo providers cho repository, danh sách, product theo ID, category theo ID và search query.
6. Tạo helper format tiền dùng `intl` ở presentation/shared phù hợp.

**Kiểm chứng**

```bash
flutter test test/features/catalog/catalog_repository_test.dart
flutter analyze
```

**Done khi** không còn `StoreProduct`/`StoreCategory` cũ và UI có thể lấy toàn bộ catalog qua provider/repository.

---

## Task 5 — Catalog UI: search, category listing và product detail

**Files**

- Modify: `lib/shared/store_scaffold.dart`
- Modify: `lib/features/catalog/presentation/home_tab.dart`
- Modify: `lib/features/catalog/presentation/categories_tab.dart`
- Create: `lib/features/catalog/presentation/product_card.dart`
- Create: `lib/features/catalog/presentation/category_products_screen.dart`
- Create: `lib/features/catalog/presentation/product_detail_screen.dart`
- Modify: `lib/app/app.dart`
- Create: `test/features/catalog/catalog_widget_test.dart`

**Thực hiện**

1. Viết widget tests thất bại trước:
   - nhập search trên Home chỉ còn product khớp;
   - tap category mở màn hình và chỉ hiện sản phẩm thuộc category;
   - tap `product-card-<id>` ở Home/category mở đúng detail;
   - tăng/giảm quantity ở detail, không cho nhỏ hơn 1.
2. Mở API của `ProductSearchField` để nhận controller/onChanged và key, không tự quản state business.
3. Home watch search provider và render kết quả realtime. Khi query rỗng giữ trải nghiệm promo/category/popular; khi có query hiển thị danh sách kết quả và empty state rõ ràng.
4. Category card tính số lượng từ products, không dùng trường `items` hard-code; tap mở named route với `categoryId`.
5. Tạo reusable `ProductCard`, dùng ở mọi danh sách, có key ổn định và callback wishlist tạm để task 10 nối vào.
6. Tạo product detail có icon, name, formatted price, rating/reviews, description, quantity stepper, CTA Add to cart tạm disabled hoặc callback rõ ràng cho task 7.
7. Khai báo route names tập trung qua static constants của screens; validate route arguments và có fallback “Product not found” thay vì cast crash.

**Kiểm chứng**

```bash
flutter test test/features/catalog/catalog_widget_test.dart
flutter analyze
```

**Done khi** mọi product entry point mở cùng một detail screen và search/category không còn nút no-op.

---

## Task 6 — Cart repository + Riverpod notifier + unit tests

**Files**

- Create: `lib/features/cart/data/cart_item.dart`
- Create: `lib/features/cart/data/cart_repository.dart`
- Create: `lib/features/cart/presentation/cart_providers.dart`
- Create: `test/features/cart/cart_repository_test.dart`
- Create: `test/features/cart/cart_notifier_test.dart`

**Thực hiện**

1. `CartItem` chỉ chứa `productId` và `quantity`, có `toJson/fromJson` defensive.
2. Viết repository test cho empty default, save/load round-trip và JSON hỏng.
3. Viết notifier test trước cho:
   - add product mới với quantity chỉ định;
   - add lại cùng ID thì cộng quantity;
   - increment/decrement;
   - decrement từ 1 thì xóa item;
   - remove và clear;
   - `totalQuantity` và total tiền lấy giá từ catalog;
   - mỗi mutation đã persist trước khi future hoàn tất.
4. Implement `CartRepository` dùng key `cart`.
5. Implement `CartNotifier` với state async để hydrate từ storage. Chặn quantity <= 0 từ public API.
6. Expose derived providers cho `totalQuantity`, subtotal và danh sách view model đã resolve `Product`.

**Kiểm chứng**

```bash
flutter test test/features/cart
flutter analyze
```

**Done khi** toàn bộ logic cart chạy không cần widget và có thể recreate `ProviderContainer` để đọc lại state đã lưu.

---

## Task 7 — Nối cart vào product detail, Cart tab và badge động

**Files**

- Modify: `lib/features/catalog/presentation/product_detail_screen.dart`
- Modify: `lib/features/cart/presentation/cart_tab.dart`
- Modify: `lib/screens/main_screen.dart`
- Modify: `lib/app/app.dart`
- Create: `test/features/cart/cart_widget_test.dart`

**Thực hiện**

1. Viết widget test: add quantity từ detail cập nhật badge, tăng/giảm/xóa ở Cart cập nhật tổng và persist.
2. CTA detail gọi notifier, chờ hoàn tất, hiện feedback “Added to cart”; chống double-tap trong lúc ghi.
3. Cart tab render view model thật, mọi nút gọi notifier; remove phải hoạt động.
4. Empty cart có minh họa/icon, message và nút “Continue shopping”. Truyền callback từ `MainScreen` để chọn tab index 0, không push thêm một MainScreen.
5. Cart badge dùng `totalQuantity`, ẩn hoàn toàn khi 0, có key `cart-badge` khi hiện.
6. Checkout button có key `checkout-button`, chỉ hiện/enable khi cart có item; route tới checkout sẽ được nối ở task 13.
7. Không áp dụng discount hard-code `$20`; subtotal/total trong demo phải nhất quán với tổng item.

**Kiểm chứng**

```bash
flutter test test/features/cart/cart_widget_test.dart
flutter analyze
```

**Done khi** không còn `storeCartItems` hoặc badge số `3` hard-code.

---

## Task 8 — Auth repository: đăng ký, login và session

**Files**

- Create: `lib/features/auth/data/user_model.dart`
- Create: `lib/features/auth/data/auth_repository.dart`
- Create: `lib/features/auth/presentation/auth_providers.dart`
- Create: `test/features/auth/auth_repository_test.dart`

**Thực hiện**

1. `UserModel(name, email, password)` có JSON defensive; normalize email bằng trim + lowercase ở repository boundary.
2. Viết test trước cho:
   - register user mới lưu vào `users` và set `session`;
   - email trùng không phân biệt hoa thường bị từ chối;
   - demo account `admin@claude.ai / 147258369` login được dù chưa có `users`;
   - password sai/user không tồn tại thất bại;
   - login thành công set session;
   - `currentUser` resolve demo user thành `Tony Nguyen` và user đăng ký thành đúng name;
   - logout chỉ xóa session, không xóa cart/orders/wishlist.
3. Dùng result/exception có type rõ ràng cho duplicate/invalid credentials để UI hiển thị đúng lỗi.
4. Thêm comment bảo mật plaintext theo yêu cầu demo.
5. Tạo auth/session providers, repository được inject từ LocalStore provider.

**Kiểm chứng**

```bash
flutter test test/features/auth/auth_repository_test.dart
flutter analyze
```

**Done khi** auth business logic không phụ thuộc BuildContext và demo credentials vẫn tương thích test cũ.

---

## Task 9 — Auth UI, bootstrap giữ phiên và logout

**Files**

- Modify: `lib/main.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/features/auth/presentation/login_screen.dart`
- Modify: `lib/features/auth/presentation/register_screen.dart`
- Modify: `lib/features/account/presentation/account_tab.dart`
- Modify: `lib/features/catalog/presentation/home_tab.dart`
- Modify: `test/widget_test.dart`
- Create: `test/features/auth/auth_widget_test.dart`

**Thực hiện**

1. Tách bootstrap production khỏi constructor app để test dễ inject:
   - `main()` gọi `WidgetsFlutterBinding.ensureInitialized()`;
   - lấy `SharedPreferences`, tạo `LocalStore`, đọc session;
   - `runApp(ProviderScope(overrides: [...], child: EverydayStoreApp(initialRoute: ...)))`.
2. Không gọi async storage trong `build`. `EverydayStoreApp` nhận initial route đã resolve hoặc một `initiallyAuthenticated` rõ ràng.
3. Login gọi repository, hiển thị lỗi invalid credentials, thành công `pushNamedAndRemoveUntil` sang Main.
4. Register dùng controllers cho cả ba field, validate như hiện tại, xử lý duplicate email, tự login và xóa auth stack.
5. Account/Home đọc current user thay vì hard-code; demo account vẫn hiện `Good morning, Tony` để giữ convention test.
6. Logout key `logout-button`: await xóa session rồi về Login và xóa stack.
7. Trong test luôn gọi `SharedPreferences.setMockInitialValues({})` ở `setUp`; bổ sung test relaunch có session vào thẳng Main và logout trở về Login.

**Kiểm chứng**

```bash
flutter test test/features/auth/auth_widget_test.dart test/widget_test.dart
flutter analyze
```

**Done khi** register/login/logout/restore session chạy thật và không test nào rò dữ liệu SharedPreferences sang test khác.

---

## Task 10 — Wishlist persist và tích hợp mọi product card

**Files**

- Create: `lib/features/wishlist/data/wishlist_repository.dart`
- Create: `lib/features/wishlist/presentation/wishlist_providers.dart`
- Create: `lib/features/wishlist/presentation/wishlist_screen.dart`
- Modify: `lib/features/catalog/presentation/product_card.dart`
- Modify: `lib/features/catalog/presentation/product_detail_screen.dart`
- Modify: `lib/features/account/presentation/account_tab.dart`
- Modify: `lib/app/app.dart`
- Create: `test/features/wishlist/wishlist_test.dart`

**Thực hiện**

1. Repository persist `Set<String>` dưới dạng JSON list ở key `wishlist`; bỏ ID không còn trong catalog khi hydrate.
2. Notifier hỗ trợ toggle, contains, clear và persist mỗi thay đổi.
3. Product card/detail watch trạng thái theo product ID; icon và semantics phản ánh saved/unsaved; key `wishlist-<id>`.
4. Wishlist screen resolve IDs thành products, dùng cùng `ProductCard`, có empty state và mở detail.
5. “Saved items” trong Account mở screen; số wishlist ở profile/action lấy provider thật.
6. Test toggle từ card và detail đồng bộ, relaunch đọc lại, remove ở Wishlist làm item biến mất.

**Kiểm chứng**

```bash
flutter test test/features/wishlist/wishlist_test.dart
flutter analyze
```

**Done khi** mọi nút trái tim thao tác cùng một nguồn state và không còn số wishlist `8` hard-code.

---

## Task 11 — Order model và repository có snapshot ổn định

**Files**

- Create: `lib/features/orders/data/order.dart`
- Create: `lib/features/orders/data/order_repository.dart`
- Create: `lib/features/orders/presentation/order_providers.dart`
- Create: `test/features/orders/order_repository_test.dart`

**Thực hiện**

1. Model gồm:
   - `OrderItem(productId, name, unitPrice, quantity)`;
   - `StoreOrder(id, items, total, date, status, shippingAddress, paymentMethod)`.
2. `toJson/fromJson` dùng ISO-8601 cho date và enum/string ổn định cho status/payment.
3. Viết test trước cho create/read round-trip, giữ snapshot name/price dù catalog thay đổi, nhiều order sắp mới nhất trước, JSON hỏng trả list rỗng.
4. Repository tạo ID không trùng, nhận clock/ID generator qua constructor hoặc optional dependency để test deterministic.
5. Provider hydrate key `orders`, expose order count và create/read.

**Kiểm chứng**

```bash
flutter test test/features/orders/order_repository_test.dart
flutter analyze
```

**Done khi** order có thể persist/restore độc lập, test không phụ thuộc thời gian hệ thống hoặc random ID.

---

## Task 12 — Notifications seed + generated, read state và badge

**Files**

- Create: `lib/features/notifications/data/notification_model.dart`
- Create: `lib/features/notifications/data/notification_repository.dart`
- Create: `lib/features/notifications/presentation/notification_providers.dart`
- Modify: `lib/features/notifications/presentation/notifications_tab.dart`
- Modify: `lib/screens/main_screen.dart`
- Create: `test/features/notifications/notifications_test.dart`

**Thực hiện**

1. Model notification có ID, title, subtitle, timestamp/type và `isRead`; icon/color được map từ type ở presentation, không persist Flutter UI types.
2. Repository trả seed khi storage chưa có; sau mutation persist danh sách hiện tại vào key `notifications`.
3. Notifier hỗ trợ add generated notification, mark one read, mark all read; derived unread count.
4. Notifications tab render seed + generated, lọc All/Unread, tap card mark read, “Mark all” hoạt động.
5. Badge Updates hiển thị unread count thật và ẩn khi 0.
6. Test initial seed, mark read persist, add generated và badge cập nhật.

**Kiểm chứng**

```bash
flutter test test/features/notifications/notifications_test.dart
flutter analyze
```

**Done khi** không còn `StoreNotification` static state hoặc badge unread hard-code.

---

## Task 13 — Checkout transaction, order success và lịch sử đơn

**Files**

- Create: `lib/features/orders/presentation/checkout_screen.dart`
- Create: `lib/features/orders/presentation/order_success_screen.dart`
- Create: `lib/features/orders/presentation/order_history_screen.dart`
- Create: `lib/features/orders/presentation/order_detail_screen.dart`
- Modify: `lib/features/orders/presentation/order_providers.dart`
- Modify: `lib/features/cart/presentation/cart_tab.dart`
- Modify: `lib/features/account/presentation/account_tab.dart`
- Modify: `lib/app/app.dart`
- Create: `test/features/orders/checkout_widget_test.dart`

**Thực hiện**

1. Tạo checkout form có các trường tối thiểu: recipient, phone, address; validate required/phone hợp lệ; payment COD hoặc demo card. Không thu thập/lưu số thẻ thật.
2. Tạo một checkout coordinator/notifier để UI không tự gọi lần lượt repository. Quy trình:
   - chặn cart rỗng và double-submit;
   - snapshot cart + product price/name;
   - tạo và persist order `Processing`;
   - clear cart;
   - tạo notification “Order placed successfully” có order ID;
   - trả order cho navigation.
3. Nếu tạo order thất bại, giữ cart. Nếu order đã lưu nhưng clear cart/notification lỗi, không tạo order trùng khi retry; xử lý bằng trạng thái submit/ID đã tạo và test failure path quan trọng.
4. Success screen hiển thị order ID/total, nút về Home và xem order; xóa checkout route khỏi stack để back không submit lại.
5. History lấy danh sách thật, mới nhất trước, empty state; tap mở detail có items, address, payment, status và total.
6. Account “My orders” và order count dùng provider thật.
7. Nối `checkout-button` từ Cart tới checkout.
8. Widget test full checkout khẳng định order xuất hiện, cart về 0, badge biến mất, notification xuất hiện và retry/double tap không tạo hai order.

**Kiểm chứng**

```bash
flutter test test/features/orders/checkout_widget_test.dart
flutter test test/features/orders test/features/cart test/features/notifications
flutter analyze
```

**Done khi** checkout là một luồng nhất quán từ cart tới history, không chỉ là navigation demo.

---

## Task 14 — Hoàn thiện regression tests, tài liệu và cleanup

**Files**

- Modify: `test/widget_test.dart`
- Create hoặc modify: `test/app_flow_test.dart`
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Delete: mọi file/model/data cũ không còn tham chiếu

**Thực hiện**

1. Tạo helper test pump app với `SharedPreferences.setMockInitialValues`, Provider overrides và viewport đủ ổn định.
2. Bao phủ các luồng được thiết kế:
   - register → auto login;
   - demo login → product detail → add cart → badge → checkout → order history;
   - wishlist từ card/detail;
   - notification read/unread badge;
   - theme toggle đổi `MaterialApp.themeMode` và persist;
   - session restore và logout.
3. Cập nhật hai widget test ban đầu theo bootstrap mới nhưng không bỏ coverage switch Login/Register và demo credentials.
4. Chạy tìm kiếm cleanup:
   - hard-coded cart/order/wishlist count;
   - các `onPressed: () {}`/`onTap: () {}` thuộc tính năng trong scope;
   - UI gọi SharedPreferences/LocalStore trực tiếp;
   - import/file cũ.
5. Cập nhật `CLAUDE.md`: kiến trúc feature-first, provider/repository flow, storage keys, commands test.
6. Cập nhật README với demo credentials và danh sách tính năng; ghi rõ dữ liệu/password chỉ phục vụ local demo.
7. Format toàn bộ source/test.

**Kiểm chứng cuối**

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
rg -n "SharedPreferences|LocalStore" lib/features/*/presentation lib/shared
rg -n "Badge\(|Orders'|Wishlist'|storeCartItems|StoreProduct|StoreCategory|StoreNotification" lib
```

Review thủ công trên ít nhất một simulator/device:

1. Cold start chưa session → Login.
2. Login demo → Home và đúng tên user.
3. Search/category/detail hoạt động.
4. Add cart, restart app, cart còn dữ liệu.
5. Checkout tạo đúng một order, restart app, order còn dữ liệu.
6. Wishlist và read notification survive restart.
7. Light/dark không có text, input, card hoặc navigation bar mất contrast.
8. Logout rồi restart vẫn ở Login; dữ liệu mua sắm không bị xóa ngoài ý muốn.

**Done khi** `flutter analyze` và toàn bộ `flutter test` pass, checklist thủ công đạt, không còn state mock thuộc phạm vi thiết kế.

---

## Thứ tự thực thi và checkpoint

Thực hiện đúng thứ tự Task 1 → 14 vì dependency dữ liệu/state được xây từ dưới lên. Có thể chia checkpoint:

- **Checkpoint A — Foundation:** Task 1–3.
- **Checkpoint B — Browse & cart:** Task 4–7.
- **Checkpoint C — Identity & personalization:** Task 8–10.
- **Checkpoint D — Purchase lifecycle:** Task 11–13.
- **Checkpoint E — Release quality:** Task 14.

Không triển khai song song các task sửa cùng `app.dart`, `main_screen.dart` hoặc `account_tab.dart`. Nếu cần chia người thực hiện, chỉ song song unit-level data task sau khi Task 1–4 đã merge và thống nhất provider contracts.
