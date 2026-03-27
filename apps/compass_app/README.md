# Compass App

基于 Flutter 的旅行预订应用，采用 Clean Architecture 架构，使用 Provider + ChangeNotifier + Command 模式进行状态管理。本应用是 `lt_flutter framework` 单体仓库中的二级应用，专注于旅行预订领域。

---

## 目录

- [技术架构](#技术架构)
- [分层架构详解](#分层架构详解)
- [领域模型](#领域模型)
- [状态管理模式](#状态管理模式)
- [路由结构](#路由结构)
- [依赖注入](#依赖注入)
- [业务流程](#业务流程)
- [数据流示例](#数据流示例)
- [常用命令](#常用命令)

---

## 技术架构

### 技术栈

| 类别 | 技术选型 |
|------|---------|
| 语言 | Dart (SDK ^3.8.1) |
| 框架 | Flutter 3.35.7 (FVM 管理) |
| 状态管理 | Provider + ChangeNotifier + Command 模式 |
| 路由 | GoRouter (^17.0.0) |
| 数据类 | Freezed (^3.1.0) + JSON Serializable |
| 错误处理 | 密封类 `Result<T>` (`Ok<T>` / `Error<T>`) |
| 图片加载 | cached_network_image (^3.4.1) |
| 分享 | share_plus (^10.1.3) |
| 本地化 | intl (^0.20.2) + 自定义 AppLocalizationDelegate |
| 代码检查 | flutter_lints (^6.0.0) |
| 测试 | mocktail (^1.0.4) + mocktail_image_network |

### 整体架构图

```
┌─────────────────────────────────────────────────┐
│                  compass_app                     │
│  (入口、DI 配置、MaterialApp)                      │
└──────────────────────┬──────────────────────────┘
                       │ 依赖
┌──────────────────────▼──────────────────────────┐
│              packages/features/booking           │
│  (Screen、ViewModel、Route、本地化)                │
└──────────┬───────────────────────┬──────────────┘
           │ 依赖                   │ 依赖
┌──────────▼──────────┐  ┌────────▼──────────────┐
│  booking_domain     │  │   booking_data         │
│  (Entity、接口、     │◄─┤  (Repository 实现、     │
│   UseCase)          │  │   DataSource、Model)    │
└──────────┬──────────┘  └────────┬──────────────┘
           │                      │
┌──────────▼──────────────────────▼──────────────┐
│              packages/core & utls                │
│  (network、lt_uicomponent、common、date_utl)     │
└─────────────────────────────────────────────────┘
```

依赖方向严格单向：**App → Feature → Domain ← Data → Core**

Domain 层是最内层，纯 Dart，不依赖 Flutter。Data 层实现 Domain 层定义的接口。

---

## 分层架构详解

### 1. Domain 层 (`packages/domain/booking_domain`)

纯 Dart 包，定义业务实体、仓库接口和用例。无 Flutter 依赖。

```
booking_domain/lib/src/
├── models/
│   ├── activity/activity.dart          # 活动实体 (Freezed)
│   ├── booking/booking.dart            # 预订实体 (Freezed)
│   ├── booking/booking_summary.dart    # 预订摘要 (Freezed)
│   ├── continent/continent.dart        # 大洲实体 (Freezed)
│   ├── destination/destination.dart    # 目的地实体 (Freezed)
│   ├── itinerary_config/itinerary_config.dart  # 行程配置 (Freezed)
│   └── user/user.dart                  # 用户实体 (Freezed)
├── repostories/
│   ├── activity/activity_repository.dart
│   ├── auth/auth_repository.dart
│   ├── booking/booking_repository.dart
│   ├── continent/continent_repository.dart
│   ├── destination/destination_repository.dart
│   ├── itinerary_config/itinerary_config_repository.dart
│   └── user/user_repository.dart
└── usecases/
    └── booking/
        ├── booking_create_use_case.dart   # 创建预订用例
        └── booking_share_use_case.dart    # 分享预订用例
```

### 2. Data 层 (`packages/data/booking_data`)

实现 Domain 层定义的仓库接口，提供本地和远程两套数据源。

```
booking_data/lib/src/
├── data_source/
│   ├── local/local_data_service.dart     # 本地数据服务 (从 assets 加载)
│   ├── remote/remote_datasource.dart     # 远程数据源 (HTTP API)
│   └── config/assets.dart                # 资源路径常量
├── model/
│   ├── booking/booking_api_model.dart    # 预订 API 模型 (Freezed)
│   └── user/user_api_model.dart          # 用户 API 模型 (Freezed)
├── repostories/
│   ├── activity/activity_repository_local.dart
│   ├── auth/auth_repository_dev.dart     # 开发环境认证 (始终已认证)
│   ├── booking/booking_repository_local.dart
│   ├── continent/continent_repository_local.dart
│   ├── destination/destination_repository_local.dart
│   ├── itinerary_config/itinerary_config_repository_memory.dart
│   └── user/user_repository_local.dart
└── shared_preferences_service.dart
```

### 3. Feature 层 (`packages/features/booking`)

包含所有 UI 屏幕、ViewModel 和路由定义。

```
booking/lib/src/
├── home/
│   ├── home_screen.dart          # 首页 — 预订列表
│   ├── home_viewmodel.dart       # 加载预订列表、删除预订
│   ├── home_button.dart          # 返回首页按钮
│   └── home_title.dart           # 首页标题/头部
├── search_form/
│   ├── search_form_screen.dart   # 搜索表单页
│   ├── search_form_viewmodel.dart # 大洲选择、日期、人数管理
│   ├── search_form_continent.dart # 大洲选择轮播
│   ├── search_form_date.dart     # 日期选择器
│   ├── search_form_guests.dart   # 人数选择器
│   ├── search_form_submit.dart   # 提交按钮
│   └── search_bar.dart           # 搜索栏组件
├── results/
│   ├── results_screen.dart       # 搜索结果页 — 目的地网格
│   ├── results_viewmodel.dart    # 按大洲筛选目的地
│   └── result_card.dart          # 目的地卡片
├── activities/
│   ├── activities_screen.dart    # 活动选择页
│   ├── activities_viewmodel.dart # 加载/选择/保存活动
│   ├── activities_header.dart    # 活动页头部
│   ├── activities_title.dart     # 分组标题
│   ├── activities_list.dart      # 活动列表
│   ├── activity_entry.dart       # 单个活动条目
│   └── activity_time_of_day.dart # 时段枚举
├── booking/
│   ├── booking_screen.dart       # 预订详情页
│   ├── booking_viewmodel.dart    # 创建/加载/分享预订
│   ├── booking_body.dart         # 预订内容区
│   └── booking_header.dart       # 预订头部 (图片、标签、日期)
├── routes/
│   ├── routes.dart               # 路由路径常量
│   └── routers.dart              # GoRouter 配置
└── localization/
    └── applocalization.dart      # 本地化字符串
```

### 4. App 层 (`apps/compass_app`)

应用入口，负责 DI 配置和 MaterialApp 初始化。

```
compass_app/lib/
├── main.dart          # MaterialApp 配置 (主题、路由、本地化)
├── main_dev.dart      # 开发环境入口 (使用本地数据源)
└── src/
    └── di/
        └── dependencies.dart  # Provider 依赖注入配置
```

---

## 领域模型

### 实体关系

```
Continent (大洲)
    │
    ├── name: String
    └── imageUrl: String

Destination (目的地)
    │
    ├── ref: String (唯一标识)
    ├── name, country, continent: String
    ├── knownFor: String (描述)
    ├── tags: List<String>
    └── imageUrl: String

Activity (活动)
    │
    ├── ref: String (唯一标识)
    ├── name, description, locationName: String
    ├── destinationRef: String → 关联 Destination
    ├── timeOfDay: TimeOfDay (any/morning/afternoon/evening/night)
    ├── duration, price: int
    ├── familyFriendly: bool
    └── imageUrl: String

ItineraryConfig (行程配置 — 临时搜索状态)
    │
    ├── continent: String?
    ├── startDate, endDate: DateTime?
    ├── guests: int?
    ├── destination: String? → 关联 Destination.ref
    └── activities: List<String> → 关联 Activity.ref

Booking (预订)
    │
    ├── id: int?
    ├── startDate, endDate: DateTime
    ├── destination: Destination
    └── activity: List<Activity>

BookingSummary (预订摘要 — 列表展示用)
    │
    ├── id: int
    ├── name: String
    └── startDate, endDate: DateTime

User (用户)
    │
    ├── name: String
    └── picture: String
```

### 仓库接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `AuthRepository` | `isAuthenticated`, `login()`, `logout()` | 认证状态管理，继承 ChangeNotifier |
| `BookingRepository` | `getBookingsList()`, `getBooking(id)`, `createBooking()`, `delete(id)` | 预订 CRUD |
| `DestinationRepository` | `getDestinations()` | 获取所有目的地 |
| `ActivityRepository` | `getByDestination(ref)` | 按目的地获取活动 |
| `ContinentRepository` | `getContinents()` | 获取所有大洲 |
| `ItineraryConfigRepository` | `getItineraryConfig()`, `setItineraryConfig()` | 行程配置读写 (内存存储) |
| `UserRepository` | `getUser()` | 获取当前用户 |

### 用例

| 用例 | 职责 |
|------|------|
| `BookingCreateUseCase` | 根据 ItineraryConfig 编排创建完整 Booking：获取 Destination → 获取 Activities → 校验日期 → 创建并保存 Booking |
| `BookingShareUseCase` | 将 Booking 格式化为文本，通过 share_plus 调用系统分享 |

---

## 状态管理模式

### Result 密封类

所有异步操作统一返回 `Result<T>`，通过模式匹配处理成功/失败：

```dart
sealed class Result<T> {
  const factory Result.ok(T value) = Ok._;
  const factory Result.error(Exception error) = Error._;
}
```

### Command 模式

`Command<T>` 继承 `ChangeNotifier`，封装异步操作并提供状态追踪：

```dart
abstract class Command<T> extends ChangeNotifier {
  bool get running;    // 是否正在执行
  bool get error;      // 是否执行失败
  bool get completed;  // 是否执行成功
  Result? get result;  // 执行结果
  void clearResult();  // 清除结果状态
}

// 无参数命令
class Command0<T> extends Command<T> {
  Future<void> execute() async { ... }
}

// 单参数命令
class Command1<T, A> extends Command<T> {
  Future<void> execute(A argument) async { ... }
}
```

### ViewModel 模式

每个屏幕对应一个 ViewModel，继承 `ChangeNotifier`，包含 Command 实例：

```dart
class HomeViewmodel extends ChangeNotifier {
  late Command0 load;                    // 加载预订列表
  late Command1<void, int> deleteBooking; // 删除预订

  // 构造时自动执行加载
  HomeViewmodel(...) {
    load = Command0(_load)..execute();
    deleteBooking = Command1(_deleteBooking);
  }
}
```

UI 层通过 `ListenableBuilder` 监听 Command 状态变化：

```dart
ListenableBuilder(
  listenable: viewModel.load,
  builder: (context, child) {
    if (viewModel.load.running) return CircularProgressIndicator();
    if (viewModel.load.error) return ErrorIndicator(...);
    return child!;
  },
  child: /* 正常内容 */,
)
```

---

## 路由结构

### 路由路径

```
/                    → HomeScreen (首页，预订列表)
/search              → SearchFormScreen (搜索表单)
/results             → ResultsScreen (搜索结果，目的地网格)
/activities          → ActivitiesScreen (活动选择)
/booking             → BookingScreen (新建预订详情)
/booking/:id         → BookingScreen (已有预订详情)
/login               → 登录页 (认证重定向)
```

### 导航流程

```
HomeScreen ──(FAB)──→ SearchFormScreen ──(提交)──→ ResultsScreen
                                                       │
                                                  (选择目的地)
                                                       │
BookingScreen ←──(确认活动)── ActivitiesScreen ←────────┘
     │
     ├── 分享预订
     └── 返回首页

HomeScreen ──(点击预订)──→ BookingScreen (加载已有预订)
HomeScreen ──(左滑)──→ 删除预订
```

### 认证守卫

路由配置中包含认证重定向逻辑：
- 未认证 → 重定向到 `/login`
- 已认证且在登录页 → 重定向到 `/`

开发环境 (`AuthRepositoryDev`) 始终返回已认证状态。

---

## 依赖注入

通过 Provider 包在应用入口配置所有依赖，支持两套环境：

### 本地环境 (`providersLocal` — 开发用)

```
AuthRepositoryDev (始终已认证)
LocalDataService (从 assets 加载 JSON 数据)
  ├── DestinationRepositoryLocal
  ├── ContinentRepositoryLocal
  ├── ActivityRepositoryLocal
  ├── BookingRepositoryLocal (内存存储，含默认预订)
  └── UserRepositoryLocal
ItineraryConfigRepositoryMemory (内存存储)
BookingCreateUseCase
BookingShareUseCase
```

### 远程环境 (`providersRemote` — 生产用)

```
HttpApiClient (baseUrl + TokenStorage)
RemoteDatasource (HTTP API 调用)
SharedPreferencesService
  ├── DestinationRepositoryRemote
  ├── ContinentRepositoryRemote
  ├── ActivityRepositoryRemote
  ├── BookingRepositoryRemote
  └── UserRepositoryRemote
ItineraryConfigRepositoryMemory (内存存储)
BookingCreateUseCase
BookingShareUseCase
```

入口文件 `main_dev.dart` 使用本地配置：

```dart
void main() {
  runApp(MultiProvider(providers: providersLocal, child: const MainApp()));
}
```

ViewModel 在路由 builder 中通过 `context.read()` 获取依赖并构造。

---

## 业务流程

### 流程一：搜索并预订新行程

```
1. 用户在首页点击 FAB「预订新行程」
2. 进入搜索表单页 (SearchFormScreen)
   ├── SearchFormViewModel 加载大洲列表
   ├── 用户选择大洲 (横向轮播)
   ├── 用户选择日期范围
   └── 用户设置人数
3. 提交表单 → ItineraryConfig 保存到内存
4. 进入搜索结果页 (ResultsScreen)
   ├── ResultsViewModel 读取 ItineraryConfig
   ├── 加载所有目的地并按大洲筛选
   └── 以网格形式展示目的地卡片
5. 用户选择目的地 → ItineraryConfig 更新 destination
6. 进入活动选择页 (ActivitiesScreen)
   ├── ActivitiesViewModel 读取 ItineraryConfig 中的 destination
   ├── 按目的地加载活动列表
   ├── 按时段分组 (白天: any/morning/afternoon, 夜间: evening/night)
   └── 用户勾选活动
7. 确认活动 → ItineraryConfig 更新 activities
8. 进入预订详情页 (BookingScreen)
   ├── BookingViewModel 触发 createBooking Command
   ├── BookingCreateUseCase 编排：
   │   ├── 从 ItineraryConfig 读取配置
   │   ├── 获取 Destination 实体
   │   ├── 获取选中的 Activity 实体列表
   │   ├── 校验日期
   │   └── 创建 Booking 并保存到 BookingRepository
   └── 展示预订详情 (目的地图片、标签、日期、活动列表)
9. 用户可点击分享按钮 → BookingShareUseCase 格式化文本并调用系统分享
```

### 流程二：查看已有预订

```
1. 首页加载预订摘要列表 (BookingSummary)
2. 用户点击某个预订
3. 导航到 /booking/:id
4. BookingViewModel 通过 loadingBooking Command 加载完整 Booking
5. 展示预订详情，支持分享
```

### 流程三：删除预订

```
1. 用户在首页左滑预订条目
2. Dismissible 触发确认
3. HomeViewmodel.deleteBooking Command 执行
   ├── BookingRepository.delete(id)
   └── 重新加载预订列表
4. UI 更新，显示删除成功 SnackBar
```

---

## 数据流示例

以「搜索 → 查看结果」为例，展示完整的数据流向：

```
┌─────────────────────┐
│  SearchFormScreen    │  用户选择大洲、日期、人数，点击提交
└──────────┬──────────┘
           │ execute()
┌──────────▼──────────┐
│ SearchFormViewModel  │  _updateItineraryConfig()
│ .updateItineraryConfig│
└──────────┬──────────┘
           │ setItineraryConfig(config)
┌──────────▼──────────────────────┐
│ ItineraryConfigRepositoryMemory │  _itineraryConfig = config
└──────────┬──────────────────────┘
           │ 路由导航到 /results
┌──────────▼──────────┐
│   ResultsScreen     │  初始化
└──────────┬──────────┘
           │ 构造 ResultsViewModel → 自动执行 search Command
┌──────────▼──────────┐
│  ResultsViewModel   │  _search()
│                     │  ├── getItineraryConfig() → 读取大洲筛选条件
│                     │  ├── getDestinations() → 获取所有目的地
│                     │  └── 按 continent 过滤 → _destinations
└──────────┬──────────┘
           │ notifyListeners()
┌──────────▼──────────┐
│  ResultsScreen      │  ListenableBuilder 重建 → 展示目的地网格
└─────────────────────┘
```

---

## 常用命令

```bash
# 安装依赖
make setup

# 运行代码生成 (Freezed, JSON Serializable)
make codegen

# 运行 compass_app (开发环境)
cd apps/compass_app && fvm flutter run -t lib/main_dev.dart

# 运行测试
cd apps/compass_app && fvm flutter test

# 清理构建产物
make clean

# 完整重置 (clean + setup + codegen)
make reset
```
