# FlipEarth API 接口文档

> 版本: v1.0  
> 更新日期: 2026-02-25  
> 后端项目: cashcow-pro (Yii2)

---

## 一、概述

### 1.1 Base URL

| 环境 | Base URL |
|------|----------|
| 本地开发 | `http://api.flipearth.test:8080` |
| 生产环境 | `https://api.flipearth.com` |

所有接口路径均以 `/v1/` 为前缀。

### 1.2 通用响应格式

所有接口统一返回 JSON，HTTP 状态码始终为 `200`，业务状态通过 `code` 字段区分：

**成功响应：**
```json
{
  "code": 0,
  "message": "success",
  "data": { ... }
}
```

**错误响应：**
```json
{
  "code": 401,
  "message": "Incorrect email or password",
  "data": null
}
```

### 1.3 认证方式

除标注为 **公开** 的接口外，所有接口均需在 HTTP Header 中携带 Bearer Token：

```
Authorization: Bearer {access_token}
```

Token 获取方式：通过 `/v1/auth/login` 或 `/v1/auth/register` 接口返回。

### 1.4 错误码说明

| code | 含义 |
|------|------|
| 0 | 成功 |
| 400 | 请求参数错误 |
| 401 | 未认证 / Token 无效或过期 |
| 404 | 资源不存在 |
| 409 | 业务冲突（如已支付、不可退款等） |
| 422 | 数据校验失败（`data` 字段包含具体错误） |
| 429 | 请求频率限制 |
| 500 | 服务端错误 |

---

## 二、认证模块 Auth

### 2.1 登录

`POST /v1/auth/login` — **公开**

**Request Body:**
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
    "access_token": "xxxxxxxxxxxxxxxx",
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

| 字段 | 类型 | 说明 |
|------|------|------|
| access_token | string | 用于后续请求的 Bearer Token |
| expires_in | int | Token 有效期（秒），默认 604800（7天） |
| user.is_white | int | 是否白名单用户（0=否, 1=是） |

---

### 2.2 注册

`POST /v1/auth/register` — **公开**

**Request Body:**
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
    "access_token": "xxxxxxxxxxxxxxxx",
    "expires_in": 604800,
    "user": {
      "id": 2,
      "email": "newuser@example.com",
      "username": "newuser_x8k2m1"
    }
  }
}
```

> 注册成功后自动生成 Token，无需再调登录接口。

**可能的错误：**
- `422` — 邮箱格式错误、已被注册、密码不符合要求

---

### 2.3 刷新 Token

`POST /v1/auth/refresh` — **需认证**

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "access_token": "new_token_xxxxxxxx",
    "expires_in": 604800
  }
}
```

> 用旧 Token 换取新 Token，旧 Token 立即失效。

---

### 2.4 退出登录

`POST /v1/auth/logout` — **需认证**

**Response:**
```json
{
  "code": 0,
  "message": "Logged out",
  "data": null
}
```

> Token 被清除，后续请求需重新登录。

---

### 2.5 获取当前用户信息

`GET /v1/auth/profile` — **需认证**

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "username": "user_abc123",
    "is_white": 0,
    "created_at": 1700000000
  }
}
```

| 字段 | 类型 | 说明 |
|------|------|------|
| created_at | int | Unix 时间戳 |

---

## 三、车站模块 Stations

> 所有车站接口均为 **公开**，无需认证。

### 3.1 站点搜索（自动补全）

`GET /v1/stations/autocomplete` — **公开**

**Query Parameters:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| q | string | 是 | — | 搜索关键词（最少 2 个字符） |
| limit | int | 否 | 10 | 返回数量（最大 20） |

**Response:**
```json 
{
  "code": 0,
  "message": "success",
  "data": [
    {
      "uic_code": "7015400",
      "name": "London St Pancras International",
      "display_name": "London St Pancras International (London, GB)",
      "city": "London",
      "country_code": "GB",
      "beurope_code": "GBSPX",
      "raileurope_code": "GBSPX"
    }
  ]
}
```

> 当 `q` 少于 2 个字符时，返回空数组。

---

### 3.2 热门站点

`GET /v1/stations/popular` — **公开**

**Query Parameters:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| limit | int | 否 | 22 | 返回数量（最大 30） |

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

---

### 3.3 获取可达目的地

`GET /v1/stations/destinations` — **公开**

**Query Parameters:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| origin | string | 是 | 出发站 UIC 编码 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

> 返回数据结构取决于 `EurostarRoute::getDestinationsFrom()` 实现。

---

### 3.4 检查路线可用性

`GET /v1/stations/check-route` — **公开**

**Query Parameters:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| origin | string | 是 | 出发站 UIC |
| destination | string | 是 | 到达站 UIC |

**Response（路线有效）：**
```json
{
  "code": 0,
  "message": "success",
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

**Response（路线无效）：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "valid": false,
    "message": "Route not available"
  }
}
```

---

### 3.5 获取 Eurostar 直达站列表

`GET /v1/stations/direct` — **公开**

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

---

## 四、火车搜索与预订模块 Eurostar

### 4.1 搜索车次

`GET /v1/eurostar/search` — **公开**

> 该接口响应较慢（外部 API 调用），建议客户端设置 **60-120 秒** 超时。

**Query Parameters:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| date | string | 否 | 今天 | 日期 YYYY-MM-DD |
| origin | string | 否 | 7015400 | 出发站 UIC |
| destination | string | 否 | 8727100 | 到达站 UIC |
| adults | int | 否 | 1 | 成人数量 |
| youth | int | 否 | 0 | 青年数量（12-25岁） |
| children | int | 否 | 0 | 儿童数量（4-11岁） |
| seniors | int | 否 | 0 | 老年数量（60+） |
| couponCode | string | 否 | — | 优惠券代码 |

**日期范围：** 昨天 ~ 未来 7 个月。超出范围返回空数组。

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

| 字段 | 说明 |
|------|------|
| offerId | 下单时必传，标识具体报价 |
| searchId | 下单时必传，标识搜索会话 |
| segments | 非直达时包含中转站信息 |
| availability | `high` / `medium` / `low` / `none` |

---

### 4.2 创建预订

`POST /v1/eurostar/booking` — **需认证**

**Request Body:**
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
  "segments": [],
  "couponCode": ""
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| offerId | string | **是** | 搜索结果中的 offerId |
| searchId | string | **是** | 搜索结果中的 searchId |
| trainId | string | 否 | 列车 ID |
| travelClass | string | 否 | `standard` / `premier` / `business`，默认 standard |
| date | string | 否 | 出发日期 YYYY-MM-DD |
| adults / youth / children / seniors | int | 否 | 各类型乘客数量 |
| origin / destination | string | 否 | 出发/到达站名称（用于显示） |
| originUic / destinationUic | string | 否 | 出发/到达站 UIC |
| trainNumber | string | 否 | 列车号 |
| departureTime / arrivalTime | string | 否 | 出发/到达时间 HH:MM |
| isDirect | bool | 否 | 是否直达 |
| legCount | int | 否 | 行程段数 |
| segments | array | 否 | 中转站信息 |
| couponCode | string | 否 | 优惠券代码 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

> `bookingId` 和 `itemId` 在后续提交旅客信息时需要传回。

---

### 4.3 提交旅客信息（预下单）

`POST /v1/eurostar/preorder` — **需认证**

**Request Body:**
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

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| bookingId | string | 条件 | booking 返回的 bookingId（与 offerId 二选一） |
| itemId | string | 条件 | booking 返回的 itemId |
| offerId | string | 条件 | 搜索的 offerId（无 bookingId 时使用） |
| searchId | string | 条件 | 搜索的 searchId |
| payment_method | string | 否 | `stripe` / `alipay` / `wechat` |
| couponCode | string | 否 | 优惠券代码 |
| travelers | array | **是** | 旅客信息数组 |

**Traveler 对象：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| firstName | string | 是 | 名（大写） |
| lastName | string | 是 | 姓（大写） |
| title | string | 是 | `MR` / `MRS` / `MS` / `MISS` |
| type | string | 是 | `ADULT` / `YOUTH` / `CHILD` / `SENIOR` |
| dateOfBirth | string | 是 | 出生日期 YYYY-MM-DD |
| leadTraveler | bool | 否 | 是否主乘客（默认 true） |
| emailAddress | string | 否 | 邮箱（主乘客必填） |
| phoneNumber | string | 否 | 手机号 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "success",
    "bookingReference": "RE-xxx",
    "redirectUrl": null,
    "price": 55.00,
    "currency": "EUR"
  }
}
```

---

### 4.4 验证优惠券

`POST /v1/eurostar/validate-coupon` — **公开**

**Request Body:**
```json
{
  "code": "WELCOME10"
}
```

**Response（有效）：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "valid": true,
    "coupon": {
      "code": "WELCOME10",
      "value": 10.0
    }
  }
}
```

**Response（无效）：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "valid": false,
    "message": "Coupon has expired"
  }
}
```

---

## 五、支付模块 Payment

> 所有支付接口均 **需认证**。

### 5.1 创建 Stripe 支付意图

`POST /v1/payment/create-stripe-intent` — **需认证**

**Request Body:**
```json
{
  "ref": "RE-xxx"
}
```

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "clientSecret": "pi_xxx_secret_yyy",
    "amount": 55.00,
    "currency": "EUR"
  }
}
```

> App 使用 `flutter_stripe` 包，拿到 `clientSecret` 后调起原生支付弹窗。  
> 同时支持 Apple Pay / Google Pay（通过 Stripe）。

**可能的错误：**
- `404` — 订单不存在或无权访问
- `409` — 订单已支付

---

### 5.2 生成支付二维码

`POST /v1/payment/generate-qr` — **需认证**

**Request Body:**
```json
{
  "ref": "RE-xxx",
  "payment_method": "wechat"
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ref | string | 是 | 订单号 (bookingReference) |
| payment_method | string | 是 | `wechat` 或 `alipay` |

**Response（微信）：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "action": "qrcode",
    "code_url": "weixin://wxpay/bizpayurl?..."
  }
}
```

**Response（支付宝）：**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "action": "redirect_html",
    "redirect_html": "<form ...>"
  }
}
```

> **App 端注意：**  
> - 微信在 App 中应使用微信 SDK 唤起 App 支付，而非扫码  
> - 支付宝同理，应使用支付宝 SDK App 支付  
> - 后端后续需新增 App 专用支付渠道 (`wechat.app()` / `alipay.app()`)

---

### 5.3 检查支付状态

`GET /v1/payment/check-status` — **需认证**

**Query Parameters:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ref | string | 是 | 订单号 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "payment_status": "paid"
  }
}
```

**状态值：**

| 状态值 | 含义 |
|--------|------|
| created | 已创建 |
| PREBOOKED | 已预订 |
| paid | 已支付 |
| 4 | 已出票 |
| completed | 已完成 |
| refund_auditing | 退款审核中 |
| refunded | 已退款 |
| cancelled | 已取消 |

> 支付后建议每 2-3 秒轮询一次，最多轮询 60 秒。

---

## 六、订单模块 Orders

> 所有订单接口均 **需认证**。

### 6.1 获取订单列表

`GET /v1/orders` — **需认证**

**Query Parameters:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| type | string | 否 | 空(全部) | `train` / `itinerary` / 空 |
| status | string | 否 | — | 按状态筛选 |
| page | int | 否 | 1 | 页码 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
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
        "status": 0,
        "city": "Paris",
        "days": 7,
        "start_date": "2026-04-01",
        "end_date": "2026-04-07",
        "order_status": 0,
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

> 列表中 `status` 为 `created` 的火车订单不会展示（后端已过滤）。

---

### 6.2 获取火车票订单详情

`GET /v1/orders/train/{ref}` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| ref | 订单号 (bookingReference)，如 `RE-xxx` |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "booking_reference": "RE-xxx",
    "status": "4",
    "status_label": "已出票",
    "price": 55.00,
    "currency": "EUR",
    "cny_amount": 429.00,
    "payment_method": "stripe",
    "journey": {
      "origin": "London St Pancras",
      "destination": "Paris Gare du Nord",
      "departureTime": "2026-03-15 09:31:00",
      "arrivalTime": "2026-03-15 12:47:00",
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
        "title": "MR",
        "dateOfBirth": "1990-01-01",
        "leadTraveler": true,
        "emailAddress": "hang@example.com",
        "phoneNumber": "+8613812345678"
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

| 字段 | 说明 |
|------|------|
| cny_amount | 人民币金额（汇率换算） |
| journey.pnr | 车票 PNR 号（出票后才有） |
| journey.coach / seat | 车厢/座位号（出票后可能有） |
| journey.segments | 非直达时的中转段详情数组 |
| canRefund | 是否可申请退票（出发前 >7 天） |
| refundData.fee | 退票手续费 |
| refundData.amount | 实际退款金额 |
| travelers | 乘客信息数组（原始提交数据） |

**Segment 对象（非直达时）：**
```json
{
  "origin": "London",
  "destination": "Brussels",
  "departure": "2026-03-15T09:31:00",
  "arrival": "2026-03-15T12:00:00",
  "trainNumber": "EST 9014",
  "serviceType": "Eurostar"
}
```

---

### 6.3 申请退票

`POST /v1/orders/train/{ref}/refund` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| ref | 订单号 |

**Response:**
```json
{
  "code": 0,
  "message": "Refund request submitted, processing in 3-5 business days",
  "data": null
}
```

**退票规则：**
- 仅已支付订单可申请退票
- 出发前 ≤7 天不可退票
- 退票手续费 €25

**可能的错误：**
- `409` — 订单不可退款 / 距出发不足 7 天

---

## 七、AI 行程规划模块 Itinerary

> 所有行程接口均 **需认证**。

### 7.1 创建 AI 行程

`POST /v1/itinerary/create` — **需认证**

**Request Body:**
```json
{
  "city": "Paris",
  "start_date": "2026-04-01",
  "days": 7,
  "country": "France",
  "companion_type": 0
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| city | string | **是** | 目的地城市 |
| start_date | string | **是** | 开始日期 YYYY-MM-DD |
| days | int | **是** | 天数（最大 65） |
| country | string | 否 | 国家名 |
| companion_type | int | 否 | 0=独自, 1=情侣, 2=朋友, 3=带小孩/老人 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
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

| status | 说明 |
|--------|------|
| completed | 已完成（≤1 天的行程同步生成） |
| generating | 正在生成（>1 天的行程异步处理，需轮询 view 接口） |

**频率限制：**
- 同一用户每分钟最多 3 次
- 同一用户每天最多 20 次
- 同一 IP 每天最多 10 次

---

### 7.2 获取行程详情

`GET /v1/itinerary/{id}` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| id | 行程 ID |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "city": "Paris",
    "country": "France",
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

**行程状态 status 值：**

| 值 | 含义 |
|----|------|
| completed | 生成完成 |
| generating | 等待生成 |
| processing | 正在生成中 |
| error | 生成失败 |
| unknown | 未知状态 |

> **异步行程轮询策略：** 创建后 status 为 `generating`，建议每 3-5 秒轮询此接口，直到状态变为 `completed` 或 `error`。

---

### 7.3 获取行程列表

`GET /v1/itinerary/list` — **需认证**

**Query Parameters:**

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| page | int | 否 | 1 | 页码 |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 123,
        "city": "Paris",
        "country": "France",
        "days": 7,
        "start_date": "2026-04-01",
        "end_date": "2026-04-07",
        "status": "completed",
        "order_status": 0,
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

---

### 7.4 下载行程 PDF

`GET /v1/itinerary/{id}/download` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| id | 行程 ID |

**Response:** `application/pdf` 二进制流

**Response Headers:**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="FlipEarth_Itinerary_Paris.pdf"
```

> 仅已完成的行程可下载，否则返回 `409` 错误。

---

## 八、用户乘车人模块 User/Travelers

> 所有接口均 **需认证**。

### 8.1 获取常用乘车人列表

`GET /v1/user/travelers` — **需认证**

**Response:**
```json
{
  "code": 0,
  "message": "success",
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
      "passportNumber": "E1****34",
      "isDefault": true
    }
  ]
}
```

> 护照号码会被脱敏处理（保留前2位和后2位）。  
> 列表按 `isDefault` 降序、`id` 升序排列。

---

### 8.2 添加乘车人

`POST /v1/user/travelers` — **需认证**

**Request Body:**
```json
{
  "firstName": "HANG",
  "lastName": "ZHAO",
  "title": "MR",
  "type": "ADULT",
  "dateOfBirth": "1990-01-01",
  "email": "hang@example.com",
  "phone": "+8613812345678",
  "passportNumber": "E12345678",
  "isDefault": true
}
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| firstName | string | **是** | 名（自动转大写） |
| lastName | string | **是** | 姓（自动转大写） |
| title | string | 否 | `MR` / `MRS` / `MS` / `MISS`，默认 MR |
| type | string | 否 | `ADULT` / `YOUTH` / `CHILD` / `SENIOR`，默认 ADULT |
| dateOfBirth | string | 否 | 出生日期 YYYY-MM-DD |
| email | string | 否 | 邮箱（需符合邮箱格式） |
| phone | string | 否 | 手机号 |
| passportNumber | string | 否 | 护照号码 |
| isDefault | bool | 否 | 是否设为默认（设置后其他乘车人取消默认） |

**Response:**
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 1,
    "firstName": "HANG",
    "lastName": "ZHAO",
    "title": "MR",
    "type": "ADULT",
    "dateOfBirth": "1990-01-01",
    "email": "hang@example.com",
    "phone": "+8613812345678",
    "passportNumber": "E1****78",
    "isDefault": true
  }
}
```

---

### 8.3 编辑乘车人

`PUT /v1/user/travelers/{id}` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| id | 乘车人 ID |

**Request Body：** 同添加接口，所有字段均为可选（只传需修改的字段）。

**Response：** 同添加接口返回格式。

---

### 8.4 删除乘车人

`DELETE /v1/user/travelers/{id}` — **需认证**

| URL 参数 | 说明 |
|----------|------|
| id | 乘车人 ID |

**Response:**
```json
{
  "code": 0,
  "message": "Traveler deleted",
  "data": null
}
```

---

## 九、接口汇总表

| # | Method | Path | Auth | 说明 |
|---|--------|------|------|------|
| 1 | POST | /v1/auth/login | 公开 | 登录 |
| 2 | POST | /v1/auth/register | 公开 | 注册 |
| 3 | POST | /v1/auth/refresh | 认证 | 刷新 Token |
| 4 | POST | /v1/auth/logout | 认证 | 退出登录 |
| 5 | GET | /v1/auth/profile | 认证 | 获取用户信息 |
| 6 | GET | /v1/stations/autocomplete | 公开 | 站点搜索 |
| 7 | GET | /v1/stations/popular | 公开 | 热门站点 |
| 8 | GET | /v1/stations/destinations | 公开 | 可达目的地 |
| 9 | GET | /v1/stations/check-route | 公开 | 路线检查 |
| 10 | GET | /v1/stations/direct | 公开 | 直达站列表 |
| 11 | GET | /v1/eurostar/search | 公开 | 搜索车次 |
| 12 | POST | /v1/eurostar/booking | 认证 | 创建预订 |
| 13 | POST | /v1/eurostar/preorder | 认证 | 提交旅客/预下单 |
| 14 | POST | /v1/eurostar/validate-coupon | 公开 | 验证优惠券 |
| 15 | POST | /v1/payment/create-stripe-intent | 认证 | Stripe 支付 |
| 16 | POST | /v1/payment/generate-qr | 认证 | 微信/支付宝二维码 |
| 17 | GET | /v1/payment/check-status | 认证 | 支付状态轮询 |
| 18 | GET | /v1/orders | 认证 | 订单列表 |
| 19 | GET | /v1/orders/train/{ref} | 认证 | 火车票详情 |
| 20 | POST | /v1/orders/train/{ref}/refund | 认证 | 申请退票 |
| 21 | POST | /v1/itinerary/create | 认证 | 创建 AI 行程 |
| 22 | GET | /v1/itinerary/{id} | 认证 | 行程详情 |
| 23 | GET | /v1/itinerary/list | 认证 | 行程列表 |
| 24 | GET | /v1/itinerary/{id}/download | 认证 | 下载行程 PDF |
| 25 | GET | /v1/user/travelers | 认证 | 乘车人列表 |
| 26 | POST | /v1/user/travelers | 认证 | 添加乘车人 |
| 27 | PUT | /v1/user/travelers/{id} | 认证 | 编辑乘车人 |
| 28 | DELETE | /v1/user/travelers/{id} | 认证 | 删除乘车人 |

---

## 十、Flutter 对接指南

### 10.1 推荐网络库

使用 **Dio** 作为 HTTP 客户端，配合拦截器统一处理认证和错误。

### 10.2 Token 存储

使用 `flutter_secure_storage` 安全存储 Token：

```dart
// 登录后保存
await secureStorage.write(key: 'access_token', value: token);

// 请求时读取
final token = await secureStorage.read(key: 'access_token');
dio.options.headers['Authorization'] = 'Bearer $token';
```

### 10.3 Token 刷新策略

1. 监听所有请求的响应
2. 当 `code == 401` 时，尝试调用 `/v1/auth/refresh`
3. 刷新成功则用新 Token 重试原请求
4. 刷新也失败则跳转登录页

### 10.4 建议的 Service 文件结构

```
lib/core/
├── services/
│   ├── api_client.dart        # Dio 实例 + 拦截器
│   ├── auth_service.dart      # 登录/注册/Token
│   ├── station_service.dart   # 车站搜索
│   ├── eurostar_service.dart  # 搜索/预订
│   ├── payment_service.dart   # 支付
│   ├── order_service.dart     # 订单
│   ├── itinerary_service.dart # AI 行程
│   └── user_service.dart      # 乘车人管理
├── models/
│   ├── user.dart
│   ├── station.dart
│   ├── train.dart
│   ├── booking.dart
│   ├── order.dart
│   ├── itinerary.dart
│   └── traveler.dart
└── storage/
    └── secure_storage.dart    # Token 安全存储
```

### 10.5 典型业务流程

#### 购票流程
```
搜索车次 → 选择车次/舱位 → 创建预订(booking) → 填写旅客信息(preorder)
→ 创建支付(create-stripe-intent) → 调起支付 → 轮询支付状态(check-status)
```

#### AI 行程规划流程
```
填写目的地/日期/天数 → 创建行程(create) → 轮询行程详情(view)
→ 展示行程 → 可选下载 PDF(download)
```
