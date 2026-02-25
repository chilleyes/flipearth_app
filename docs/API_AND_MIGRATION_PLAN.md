# FlipEarth App 后端对接方案

## 一、项目现状分析

### 1.1 App 前端（Flutter）现状

| 页面 | 功能 | 数据状态 |
|------|------|----------|
| WelcomePage | 引导页/闪屏 | 静态 |
| **PlannerPage** | AI行程规划 + 火车票搜索 | **Mock数据，无API** |
| **ExplorePage** | 发现目的地、AI优选路线 | **Mock数据** |
| **StationPickerPage** | 站点搜索/选择 | **硬编码6个热门站，搜索结果Mock** |
| **BookingPage** | 搜索结果列表 + 下单 | **完全Mock** |
| **MyTripsPage** | 我的行程（AI规划的） | **Mock** |
| **MyTicketsPage** | 我的车票 | **Mock** |
| **OrderListPage** | 订单中心 | **Mock** |
| **ProfilePage** | 个人中心 | **Mock，无登录态** |
| ChatPage | 客服对话 | Mock |
| AddTravelerPage | 添加乘车人 | 仅UI |
| ItineraryDetailPage | 行程单详情（日程流+地图） | Mock |

**结论：App 目前是纯 UI 壳，所有数据均为硬编码 Mock，没有任何网络请求层。**

### 1.2 后端（cashcow-pro / Yii2）现状

| 模块 | 当前状态 | 鉴权方式 |
|------|----------|----------|
| 登录/注册 | Session + Cookie | Web Session |
| Eurostar 搜索 | JSON API（actionApiSearch） | 无需登录 |
| 站点搜索/热门站 | JSON API | 无需登录 |
| 预订/支付 | Web表单 + AJAX | Session登录 |
| 订单管理 | Web渲染页面 | Session登录 |
| 行程规划(AI) | Web表单 + AJAX | Session登录 |
| 支付回调 | Alipay/WeChat/Stripe Webhook | 无需Session |

**核心问题：后端是 Web 应用架构，使用 Session/Cookie 鉴权，不适合 App 直接调用。**

---

## 二、后端需要做的修改

### 2.1 【核心】新增 API 模块（推荐方案）

在 cashcow-pro 项目中新建一个独立的 API 应用，与 frontend 平级：

```
cashcow-pro/
├── api/                    # 【新增】App 专用 API 应用
│   ├── config/
│   │   └── main.php        # API 应用配置
│   ├── controllers/
│   │   ├── AuthController.php        # 登录/注册/Token刷新
│   │   ├── EurostarController.php    # 火车票搜索/预订
│   │   ├── ItineraryController.php   # AI行程规划
│   │   ├── OrderController.php       # 订单管理
│   │   ├── UserController.php        # 用户信息/乘车人管理
│   │   └── StationController.php     # 站点搜索
│   ├── models/
│   │   └── ...
│   └── modules/
├── common/                 # 共用模型和组件（不变）
├── frontend/               # 原有 Web 前端（不变）
└── console/                # 命令行（不变）
```

### 2.2 【核心】认证机制改造

**当前：** Session + Cookie（Web Only）
**目标：** JWT Token 或 Bearer Token（适合 App）

需要修改的文件和新增逻辑：

| 修改项 | 说明 |
|--------|------|
| `common/models/User.php` | 实现 `findIdentityByAccessToken()` 方法（当前抛异常） |
| 新增 `api/config/main.php` | 配置 `authenticator` 使用 `HttpBearerAuth` |
| 新增 `AuthController` | 提供 login/signup/refresh-token/logout 等接口 |
| User表新增字段 | `access_token` VARCHAR(255), `token_expired_at` TIMESTAMP |

**User.php 当前代码问题：**
```php
// 当前直接抛异常，需要改为真正实现
public static function findIdentityByAccessToken($token, $type = null)
{
    throw new NotSupportedException('"findIdentityByAccessToken" is not implemented.');
}
```

### 2.3 【必要】统一 JSON 响应格式

当前后端 JSON 返回格式不统一，App 需要统一的响应格式：

```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

错误响应：
```json
{
  "code": 401,
  "message": "Token expired",
  "data": null
}
```

### 2.4 【必要】CORS 配置

API 需支持跨域（App 如果用 WebView 或 Web 调试）：

```php
// api/config/main.php
'as corsFilter' => [
    'class' => \yii\filters\Cors::class,
],
```

---

## 三、完整 API 接口文档

### 3.1 认证模块

#### POST /api/v1/auth/login
登录获取 Token

**Request:**
```json
{
  "email": "user@example.com",
  "password": "your_password"
}
```

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "xxxxxx",
    "expires_in": 604800,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "username": "user_abc123",
      "is_white": 0
    }
  }
}
```

**后端来源：** `SiteController::actionLogin()` → 改造为返回 Token

---

#### POST /api/v1/auth/register
注册新用户

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "xxxxxx",
    "expires_in": 604800,
    "user": {
      "id": 2,
      "email": "newuser@example.com",
      "username": "newuser_x8k2m1"
    }
  }
}
```

**后端来源：** `SignupForm::signup()` → 注册后自动返回 Token

---

#### POST /api/v1/auth/refresh
刷新 Token

**Headers:** `Authorization: Bearer {old_token}`

**Response:**
```json
{
  "code": 0,
  "data": {
    "access_token": "new_token_xxx",
    "expires_in": 604800
  }
}
```

---

#### POST /api/v1/auth/logout
退出登录（使 Token 失效）

**Headers:** `Authorization: Bearer {token}`

---

#### GET /api/v1/auth/profile
获取当前用户信息

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "user_abc123",
    "is_white": 0,
    "created_at": 1700000000
  }
}
```

---

### 3.2 车站模块

#### GET /api/v1/stations/autocomplete
站点自动补全（搜索）

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| q | string | 是 | 搜索关键词（>=2字符） |
| limit | int | 否 | 返回数量（默认10，最大20） |

**Response:**
```json
{
  "code": 0,
  "data": [
    {
      "uic": "7015400",
      "name": "London St Pancras International",
      "city": "London",
      "country": "GB",
      "country_flag": "🇬🇧"
    }
  ]
}
```

**后端来源：** `EurostarController::actionStationAutocomplete()` → `EurostarStation::searchStations()`

**App 对接页面：** `StationPickerPage` — 替换硬编码的 `_popularStations` 和 `_buildSearchResults()`

---

#### GET /api/v1/stations/popular
获取热门站点

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| limit | int | 否 | 返回数量（默认22，最大30） |

**Response:**
```json
{
  "code": 0,
  "data": [
    {
      "uic": "7015400",
      "name": "London St Pancras International",
      "city": "London",
      "country": "GB",
      "is_eurostar_direct": true
    }
  ]
}
```

**后端来源：** `EurostarController::actionPopularStations()` → `EurostarStation::getPopularStations()`

---

#### GET /api/v1/stations/destinations
获取指定站可达目的地

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| origin | string | 是 | 出发站 UIC 编码 |

**Response:**
```json
{
  "code": 0,
  "data": [
    {
      "uic": "8727100",
      "name": "Paris Gare du Nord",
      "city": "Paris",
      "country": "FR",
      "is_direct": true,
      "route_type": "eurostar"
    }
  ]
}
```

**后端来源：** `EurostarController::actionDestinations()` → `EurostarRoute::getDestinationsFrom()`

---

#### GET /api/v1/stations/check-route
检查路线可用性

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| origin | string | 是 | 出发站 UIC |
| destination | string | 是 | 到达站 UIC |

**Response:**
```json
{
  "code": 0,
  "data": {
    "valid": true,
    "route": {
      "origin": "7015400",
      "destination": "8727100",
      "is_direct": true,
      "route_type": "eurostar",
      "duration": "2h 16m"
    }
  }
}
```

**后端来源：** `EurostarController::actionCheckRoute()`

---

#### GET /api/v1/stations/direct
获取所有 Eurostar 直达站

**Response:**
```json
{
  "code": 0,
  "data": [
    { "uic": "7015400", "name": "London St Pancras International", ... },
    { "uic": "8727100", "name": "Paris Gare du Nord", ... }
  ]
}
```

**后端来源：** `EurostarController::actionDirectStations()`

---

### 3.3 火车票搜索模块

#### GET /api/v1/eurostar/search
搜索车次

**Query Parameters:**
| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| date | string | 否 | 今天 | 日期 YYYY-MM-DD |
| origin | string | 否 | 7015400 | 出发站 UIC |
| destination | string | 否 | 8727100 | 到达站 UIC |
| adults | int | 否 | 1 | 成人数量 |
| youth | int | 否 | 0 | 青年数量 |
| children | int | 否 | 0 | 儿童数量 |
| seniors | int | 否 | 0 | 老年数量 |
| couponCode | string | 否 | - | 优惠券代码 |

**Response:**
```json
{
  "code": 0,
  "data": [
    {
      "trainId": "9014",
      "trainNumber": "EST 9014",
      "departureTime": "09:31",
      "arrivalTime": "12:47",
      "duration": "2h 16m",
      "origin": { "name": "London St Pancras", "uic": "7015400" },
      "destination": { "name": "Paris Gare du Nord", "uic": "8727100" },
      "isDirect": true,
      "legCount": 1,
      "segments": [],
      "prices": {
        "standard": { "price": 55.00, "currency": "EUR", "availability": "high" },
        "premier": { "price": 120.00, "currency": "EUR", "availability": "medium" },
        "business": { "price": 250.00, "currency": "EUR", "availability": "low" }
      },
      "offerId": "xxx",
      "searchId": "yyy"
    }
  ]
}
```

**后端来源：** `EurostarController::actionApiSearch()` → `EurostarApiService::searchTrains()`
**注意：** 后端已过滤 `costPrices`，安全。

**App 对接页面：** `BookingPage._buildTrainList()` — 替换硬编码的车次列表

---

### 3.4 预订模块（需登录）

#### POST /api/v1/eurostar/booking
创建预订

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "offerId": "xxx",
  "searchId": "yyy",
  "trainId": "9014",
  "travelClass": "standard",
  "date": "2026-03-15",
  "adults": 1,
  "youth": 0,
  "children": 0,
  "seniors": 0,
  "origin": "London St Pancras",
  "destination": "Paris Gare du Nord",
  "originUic": "7015400",
  "destinationUic": "8727100",
  "trainNumber": "EST 9014",
  "departureTime": "09:31",
  "arrivalTime": "12:47",
  "isDirect": true,
  "legCount": 1,
  "segments": []
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "bookingReference": "RE-xxx",
    "bookingId": "abc123",
    "itemId": "item-1",
    "price": 55.00,
    "currency": "EUR",
    "status": "created"
  }
}
```

**后端来源：** `EurostarController::actionBooking()` — 需重构为纯 API（当前渲染视图）

---

#### POST /api/v1/eurostar/preorder
提交旅客信息（预下单）

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "bookingId": "abc123",
  "itemId": "item-1",
  "offerId": "xxx",
  "searchId": "yyy",
  "payment_method": "stripe",
  "couponCode": "",
  "travelers": [
    {
      "firstName": "HANG",
      "lastName": "ZHAO",
      "title": "MR",
      "type": "ADULT",
      "dateOfBirth": "1990-01-01",
      "leadTraveler": true,
      "emailAddress": "hang@example.com",
      "phoneNumber": "+8613812345678"
    }
  ]
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "status": "success",
    "bookingReference": "RE-xxx",
    "redirectUrl": null,
    "price": 55.00,
    "currency": "EUR"
  }
}
```

**后端来源：** `EurostarController::actionRailEuropePreorder()`

---

#### POST /api/v1/eurostar/validate-coupon
验证优惠券

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 优惠券代码 |

**Response:**
```json
{
  "code": 0,
  "data": {
    "valid": true,
    "coupon": {
      "code": "WELCOME10",
      "value": 10.0
    }
  }
}
```

**后端来源：** `EurostarController::actionValidateCoupon()`

---

### 3.5 支付模块（需登录）

#### POST /api/v1/payment/create-stripe-intent
创建 Stripe 支付意图（App 首选方案）

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "ref": "RE-xxx"
}
```

**Response:**
```json
{
  "code": 0,
  "data": {
    "clientSecret": "pi_xxx_secret_yyy",
    "amount": 55.00,
    "currency": "EUR"
  }
}
```

**后端来源：** `EurostarController::actionCreateStripeIntent()`

**App 对接方式：** 使用 `flutter_stripe` 包，拿到 clientSecret 后调起原生支付弹窗。

---

#### POST /api/v1/payment/generate-qr
生成支付二维码（微信/支付宝）

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "ref": "RE-xxx",
  "payment_method": "wechat"  // "wechat" 或 "alipay"
}
```

**Response (微信):**
```json
{
  "code": 0,
  "data": {
    "action": "qrcode",
    "code_url": "weixin://wxpay/bizpayurl?..."
  }
}
```

**Response (支付宝):**
```json
{
  "code": 0,
  "data": {
    "action": "redirect_html",
    "redirect_html": "<form ...>"
  }
}
```

**后端来源：** `EurostarController::actionGenerateQr()`

**App 注意：** 
- 微信支付在 App 中应使用 SDK 唤起微信 App 支付，而非扫码
- 支付宝同理，应使用支付宝 SDK App 支付
- **需要后端新增** App 专用支付渠道（`wechat.app()` / `alipay.app()`）

---

#### GET /api/v1/payment/check-status
检查支付状态（轮询）

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ref | string | 是 | 订单号 |

**Response:**
```json
{
  "code": 0,
  "data": {
    "payment_status": "paid"
  }
}
```

状态值: `created` | `PREBOOKED` | `paid` | `4`(已出票) | `completed` | `refund_auditing` | `refunded` | `cancelled`

**后端来源：** `EurostarController::actionCheckStatus()`

---

### 3.6 订单模块（需登录）

#### GET /api/v1/orders
获取我的订单列表

**Headers:** `Authorization: Bearer {token}`

**Query Parameters:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | string | 否 | `train` / `itinerary` / 空(全部) |
| status | string | 否 | 筛选状态 |
| page | int | 否 | 页码 |

**Response:**
```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "type": "train",
        "booking_reference": "RE-xxx",
        "status": "paid",
        "status_label": "已支付",
        "price": 55.00,
        "currency": "EUR",
        "origin": "London St Pancras",
        "destination": "Paris Gare du Nord",
        "departure_time": "2026-03-15 09:31:00",
        "arrival_time": "2026-03-15 12:47:00",
        "train_number": "EST 9014",
        "travel_class": "Standard",
        "is_direct": true,
        "created_at": "2026-03-10 14:30:00"
      },
      {
        "type": "itinerary",
        "id": 123,
        "order_id": "20260310143000abcdef12",
        "status": "completed",
        "city": "Paris",
        "days": 7,
        "start_date": "2026-04-01",
        "end_date": "2026-04-07",
        "order_status": 1,
        "created_at": "2026-03-10 14:30:00"
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "totalCount": 5
    }
  }
}
```

**后端来源：** `EurostarController::actionMyOrders()` + `ItineraryController::actionIndex()`（合并）

**App 对接页面：** `OrderListPage` — 替换 Mock 列表

---

#### GET /api/v1/orders/train/{ref}
获取火车票订单详情

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "data": {
    "booking_reference": "RE-xxx",
    "status": "4",
    "status_label": "已出票",
    "price": 55.00,
    "currency": "EUR",
    "payment_method": "stripe",
    "journey": {
      "origin": "London St Pancras",
      "destination": "Paris Gare du Nord",
      "departureTime": "2026-03-15T09:31:00",
      "arrivalTime": "2026-03-15T12:47:00",
      "trainNumber": "EST 9014",
      "travelClass": "Standard",
      "isDirect": true,
      "legCount": 1,
      "pnr": "ABC123",
      "coach": "4",
      "seat": "32A",
      "segments": []
    },
    "travelers": [
      {
        "firstName": "HANG",
        "lastName": "ZHAO",
        "type": "ADULT",
        "title": "MR"
      }
    ],
    "canRefund": true,
    "refundData": {
      "fee": 25.00,
      "amount": 30.00
    },
    "created_at": "2026-03-10 14:30:00",
    "paid_at": "2026-03-10 14:35:00"
  }
}
```

**后端来源：** `EurostarController::actionDetails()` + `getBookingDisplayData()`

---

#### POST /api/v1/orders/train/{ref}/refund
申请退票

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "message": "退款申请已提交，退款将在3-5个工作日内处理"
}
```

**后端来源：** `EurostarController::actionRequestRefund()`

---

### 3.7 AI 行程规划模块（需登录）

#### POST /api/v1/itinerary/create
创建 AI 行程

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "city": "Paris",
  "start_date": "2026-04-01",
  "days": 7,
  "country": "France",
  "companion_type": 0
}
```

> `companion_type`: 0=独自, 1=情侣, 2=朋友, 3=带小孩/老人（App PlannerPage 中的选项）

**Response:**
```json
{
  "code": 0,
  "data": {
    "id": 123,
    "order_id": "20260310143000abcdef12",
    "status": "generating",
    "city": "Paris",
    "days": 7,
    "start_date": "2026-04-01",
    "end_date": "2026-04-07"
  }
}
```

**后端来源：** `ItineraryController::actionCreate()` — 改造为 API

**注意：** 如果 days > 1，则异步生成（status=10），需要轮询查询状态。

---

#### GET /api/v1/itinerary/{id}
获取行程详情

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "data": {
    "id": 123,
    "city": "Paris",
    "days": 7,
    "start_date": "2026-04-01",
    "end_date": "2026-04-07",
    "status": "completed",
    "order_status": 0,
    "itinerary": [
      {
        "day": 1,
        "date": "2026-04-01",
        "city": "Paris",
        "activities": [
          {
            "time": "10:00",
            "activity": "卢浮宫参观",
            "details": "世界最大的艺术博物馆...",
            "transportation": "Metro Line 1"
          }
        ]
      }
    ]
  }
}
```

**后端来源：** `ItineraryController::actionView()` + `getParsedItinerary()`

**App 对接页面：** `ItineraryDetailPage` — 替换 Mock 时间线数据

---

#### GET /api/v1/itinerary/list
获取我的行程列表

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "data": {
    "items": [
      {
        "id": 123,
        "city": "Paris",
        "days": 7,
        "start_date": "2026-04-01",
        "end_date": "2026-04-07",
        "status": "completed",
        "order_status": 1,
        "created_at": "2026-03-10 14:30:00"
      }
    ]
  }
}
```

**后端来源：** `ItineraryController::actionIndex()`

---

#### GET /api/v1/itinerary/{id}/download
下载行程PDF

**Headers:** `Authorization: Bearer {token}`

**Response:** `application/pdf` 二进制流

**后端来源：** `ItineraryController::actionDownload()`

---

### 3.8 用户信息模块（需登录）

#### GET /api/v1/user/travelers
获取常用乘车人列表

**Headers:** `Authorization: Bearer {token}`

**Response:**
```json
{
  "code": 0,
  "data": [
    {
      "id": 1,
      "firstName": "HANG",
      "lastName": "ZHAO",
      "title": "MR",
      "type": "ADULT",
      "dateOfBirth": "1990-01-01",
      "email": "hang@example.com",
      "phone": "+8613812345678",
      "passportNumber": "E1234****"
    }
  ]
}
```

**后端来源：** **需要新建**（当前没有独立的乘车人管理，旅客信息存在 `eurostar_bookings.traveler_info` JSON 字段中）

**App 对接页面：** `AddTravelerPage`, `BookingPage` 乘车人选择

---

#### POST /api/v1/user/travelers
添加/编辑常用乘车人

**Request:**
```json
{
  "firstName": "HANG",
  "lastName": "ZHAO",
  "title": "MR",
  "type": "ADULT",
  "dateOfBirth": "1990-01-01",
  "email": "hang@example.com",
  "phone": "+8613812345678"
}
```

---

## 四、后端具体修改清单

### 4.1 数据库变更

```sql
-- 1. User 表新增 access_token 字段
ALTER TABLE `user` ADD COLUMN `access_token` VARCHAR(255) DEFAULT NULL AFTER `auth_key`;
ALTER TABLE `user` ADD COLUMN `token_expired_at` INT(11) DEFAULT NULL AFTER `access_token`;
ALTER TABLE `user` ADD UNIQUE INDEX `idx_access_token` (`access_token`);

-- 2. 新建常用乘车人表
CREATE TABLE `user_travelers` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `title` VARCHAR(10) DEFAULT 'MR',
  `type` VARCHAR(20) DEFAULT 'ADULT',
  `date_of_birth` DATE DEFAULT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  `phone` VARCHAR(30) DEFAULT NULL,
  `passport_number` VARCHAR(50) DEFAULT NULL,
  `is_default` TINYINT(1) DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 4.2 后端文件修改清单

| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `common/models/User.php` | **修改** | 实现 `findIdentityByAccessToken()`，新增 Token 生成/验证方法 |
| `api/config/main.php` | **新增** | API 应用配置（HttpBearerAuth、JSON响应、CORS） |
| `api/controllers/AuthController.php` | **新增** | 登录/注册/Token刷新（复用 LoginForm、SignupForm） |
| `api/controllers/StationController.php` | **新增** | 站点搜索（复用 EurostarStation 模型） |
| `api/controllers/EurostarController.php` | **新增** | 搜索/预订（复用 EurostarApiService） |
| `api/controllers/OrderController.php` | **新增** | 订单管理（复用 eurostar_bookings 查询逻辑） |
| `api/controllers/ItineraryController.php` | **新增** | 行程规划（复用 Itinerary 模型 + getAi()） |
| `api/controllers/UserController.php` | **新增** | 乘车人管理 |
| `api/controllers/PaymentController.php` | **新增** | 支付相关（Stripe Intent、App支付） |
| `common/models/UserTraveler.php` | **新增** | 常用乘车人模型 |
| `console/migrations/m260225_xxx_add_user_token.php` | **新增** | User 表 access_token 迁移 |
| `console/migrations/m260225_xxx_create_user_travelers.php` | **新增** | 常用乘车人表迁移 |

### 4.3 App 端需要新建的文件

| 文件 | 说明 |
|------|------|
| `lib/core/services/api_client.dart` | HTTP 客户端（Dio），统一处理 Token、错误、拦截器 |
| `lib/core/services/auth_service.dart` | 登录/注册/Token管理 |
| `lib/core/services/station_service.dart` | 站点搜索 API |
| `lib/core/services/eurostar_service.dart` | 搜索/预订 API |
| `lib/core/services/order_service.dart` | 订单 API |
| `lib/core/services/itinerary_service.dart` | 行程 API |
| `lib/core/services/payment_service.dart` | 支付 API |
| `lib/core/models/user.dart` | 用户数据模型 |
| `lib/core/models/station.dart` | 站点数据模型 |
| `lib/core/models/train.dart` | 车次搜索结果模型 |
| `lib/core/models/booking.dart` | 订单数据模型 |
| `lib/core/models/itinerary.dart` | 行程数据模型 |
| `lib/core/models/traveler.dart` | 乘车人数据模型 |
| `lib/core/storage/secure_storage.dart` | Token 安全存储 |
| `lib/features/auth/login_page.dart` | 登录页 |
| `lib/features/auth/register_page.dart` | 注册页 |

---

## 五、支付方案对比（App 专属）

| 支付方式 | Web 当前实现 | App 推荐方案 | 是否需新增后端接口 |
|----------|-------------|-------------|-------------------|
| Stripe | ✅ Payment Element（网页） | ✅ flutter_stripe SDK | ❌ 复用 create-stripe-intent |
| 微信支付 | ✅ 扫码 (NATIVE) | App 支付 (APP) | ✅ 需新增 wechat.app() |
| 支付宝 | ✅ Web/Wap 跳转 | App 支付 (APP) | ✅ 需新增 alipay.app() |
| Apple Pay | ❌ | ✅ 通过 Stripe | ❌ 复用 create-stripe-intent |

---

## 六、开发优先级建议

### Phase 1（MVP 核心）
1. ✅ 后端 Token 认证 → App 登录/注册
2. ✅ 站点搜索 API → StationPickerPage 对接
3. ✅ 车次搜索 API → BookingPage 对接
4. ✅ Stripe 支付 → 下单付款

### Phase 2（完善体验）
5. 订单管理 API → OrderListPage
6. 订单详情 API → OrderDetailPage
7. 行程规划 API → PlannerPage AI模式
8. 乘车人管理 API

### Phase 3（增强功能）
9. 微信/支付宝 App 支付
10. 行程PDF下载
11. 推送通知
12. 实时客服对接
