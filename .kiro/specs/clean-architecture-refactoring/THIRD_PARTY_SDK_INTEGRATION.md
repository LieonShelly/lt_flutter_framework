# 第三方 SDK 集成指南 - Clean Architecture

## 问题

在 Clean Architecture 中，第三方 SDK（如支付 SDK）应该放在哪一层？

## 答案概述

第三方 SDK 应该被封装在 **Data Layer** 中，作为一种特殊的 DataSource。

## 核心原则

1. **依赖倒置**：Domain Layer 不应该依赖具体的 SDK
2. **可替换性**：可以轻松切换不同的支付提供商
3. **可测试性**：可以 mock SDK 进行测试
4. **隔离性**：SDK 的变化不影响业务逻辑

---

## 架构设计

### 层次结构

```
┌─────────────────────────────────────────────────────────┐
│ Presentation Layer (Features)                           │
│ - PaymentPage, PaymentController                        │
└─────────────────────────────────────────────────────────┘
                    ↓ 使用
┌─────────────────────────────────────────────────────────┐
│ Domain Layer (payment_domain)                           │
│ - PaymentEntity (业务实体)                              │
│ - PaymentRepository (抽象接口)                          │
│ - CreatePayment UseCase (业务逻辑)                      │
└─────────────────────────────────────────────────────────┘
                    ↑ 实现
┌─────────────────────────────────────────────────────────┐
│ Data Layer (payment_data)                               │
│ - PaymentRepositoryImpl                                 │
│ - PaymentRemoteDataSource (后端 API)                    │
│ - PaymentSDKDataSource (SDK 抽象)                       │
│   ├── AlipaySDKDataSource (支付宝实现)                  │
│   ├── WechatSDKDataSource (微信实现)                    │
│   └── StripeSDKDataSource (Stripe 实现)                 │
└─────────────────────────────────────────────────────────┘
                    ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Core Layer (payment_sdk) - 可选                         │
│ - SDK Wrapper (封装第三方 SDK)                          │
│ - 统一接口                                               │
└─────────────────────────────────────────────────────────┘
                    ↓ 依赖
┌─────────────────────────────────────────────────────────┐
│ Third-Party SDKs                                        │
│ - alipay_sdk                                            │
│ - wechat_sdk                                            │
│ - stripe_flutter                                        │
└─────────────────────────────────────────────────────────┘
```

---

## 完整实现示例

### 1. Domain Layer - 定义业务接口

```dart
// packages/domain/payment_domain/lib/src/entities/payment_entity.dart
class PaymentEntity {
  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final DateTime createdAt;
  
  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.method,
    required this.createdAt,
  });
}

enum PaymentStatus {
  pending,
  processing,
  success,
  failed,
  cancelled,
}

enum PaymentMethod {
  alipay,
  wechat,
  stripe,
  applePay,
}

// packages/domain/payment_domain/lib/src/entities/payment_result_entity.dart
class PaymentResultEntity {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  
  const PaymentResultEntity({
    required this.success,
    this.transactionId,
    this.errorMessage,
  });
}
```


```dart
// packages/domain/payment_domain/lib/src/repositories/payment_repository.dart
abstract interface class PaymentRepository {
  /// 创建支付订单（调用后端 API）
  Future<PaymentEntity> createPayment({
    required double amount,
    required PaymentMethod method,
  });
  
  /// 执行支付（调用 SDK）
  Future<PaymentResultEntity> executePayment({
    required String orderId,
    required PaymentMethod method,
  });
  
  /// 验证支付结果（调用后端 API）
  Future<PaymentEntity> verifyPayment(String orderId);
  
  /// 获取支付历史
  Future<List<PaymentEntity>> getPaymentHistory();
}

// packages/domain/payment_domain/lib/src/usecases/create_payment.dart
abstract interface class CreatePayment {
  Future<PaymentEntity> call({
    required double amount,
    required PaymentMethod method,
  });
}

class CreatePaymentImpl implements CreatePayment {
  final PaymentRepository _repository;
  
  const CreatePaymentImpl(this._repository);
  
  @override
  Future<PaymentEntity> call({
    required double amount,
    required PaymentMethod method,
  }) async {
    // 业务验证
    if (amount <= 0) {
      throw ArgumentError('支付金额必须大于 0');
    }
    
    if (amount > 10000) {
      throw ArgumentError('单笔支付金额不能超过 10000');
    }
    
    return await _repository.createPayment(
      amount: amount,
      method: method,
    );
  }
}

// packages/domain/payment_domain/lib/src/usecases/execute_payment.dart
abstract interface class ExecutePayment {
  Future<PaymentResultEntity> call({
    required String orderId,
    required PaymentMethod method,
  });
}

class ExecutePaymentImpl implements ExecutePayment {
  final PaymentRepository _repository;
  
  const ExecutePaymentImpl(this._repository);
  
  @override
  Future<PaymentResultEntity> call({
    required String orderId,
    required PaymentMethod method,
  }) async {
    // 执行支付
    final result = await _repository.executePayment(
      orderId: orderId,
      method: method,
    );
    
    // 如果支付成功，验证支付结果
    if (result.success) {
      await _repository.verifyPayment(orderId);
    }
    
    return result;
  }
}
```


### 2. Data Layer - 实现 SDK 封装

```dart
// packages/data/payment_data/lib/src/datasources/sdk/payment_sdk_datasource.dart
/// SDK DataSource 抽象接口
abstract interface class PaymentSDKDataSource {
  /// 初始化 SDK
  Future<void> initialize();
  
  /// 执行支付
  Future<PaymentResultEntity> pay({
    required String orderId,
    required double amount,
    required String currency,
  });
  
  /// 检查是否已安装支付应用
  Future<bool> isAppInstalled();
}

// packages/data/payment_data/lib/src/datasources/sdk/alipay_sdk_datasource.dart
import 'package:tobias/tobias.dart' as alipay;  // 支付宝 SDK

class AlipaySDKDataSource implements PaymentSDKDataSource {
  @override
  Future<void> initialize() async {
    // 支付宝 SDK 初始化（如果需要）
  }
  
  @override
  Future<PaymentResultEntity> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    try {
      // 调用支付宝 SDK
      final result = await alipay.pay(orderInfo: orderId);
      
      // 解析支付宝返回结果
      if (result['resultStatus'] == '9000') {
        return PaymentResultEntity(
          success: true,
          transactionId: result['result'],
        );
      } else {
        return PaymentResultEntity(
          success: false,
          errorMessage: result['memo'],
        );
      }
    } catch (e) {
      return PaymentResultEntity(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<bool> isAppInstalled() async {
    return await alipay.isAliPayInstalled();
  }
}

// packages/data/payment_data/lib/src/datasources/sdk/wechat_sdk_datasource.dart
import 'package:fluwx/fluwx.dart' as wechat;  // 微信 SDK

class WechatSDKDataSource implements PaymentSDKDataSource {
  @override
  Future<void> initialize() async {
    await wechat.registerWxApi(
      appId: 'your_wechat_app_id',
      universalLink: 'your_universal_link',
    );
  }
  
  @override
  Future<PaymentResultEntity> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    try {
      // 调用微信 SDK
      final result = await wechat.payWithWeChat(
        appId: 'your_app_id',
        partnerId: 'partner_id',
        prepayId: orderId,
        packageValue: 'Sign=WXPay',
        nonceStr: 'nonce_str',
        timeStamp: DateTime.now().millisecondsSinceEpoch,
        sign: 'sign',
      );
      
      if (result.isSuccessful) {
        return const PaymentResultEntity(success: true);
      } else {
        return PaymentResultEntity(
          success: false,
          errorMessage: result.errStr,
        );
      }
    } catch (e) {
      return PaymentResultEntity(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
  
  @override
  Future<bool> isAppInstalled() async {
    return await wechat.isWeChatInstalled;
  }
}
```


```dart
// packages/data/payment_data/lib/src/datasources/remote/payment_remote_datasource.dart
import 'package:network/network.dart';

/// 后端 API DataSource
abstract interface class PaymentRemoteDataSource {
  Future<PaymentModel> createPayment({
    required double amount,
    required String method,
  });
  
  Future<PaymentModel> verifyPayment(String orderId);
  
  Future<List<PaymentModel>> getPaymentHistory();
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClientType _apiClient;
  
  const PaymentRemoteDataSourceImpl(this._apiClient);
  
  @override
  Future<PaymentModel> createPayment({
    required double amount,
    required String method,
  }) async {
    final response = await _apiClient.post(
      '/api/payments',
      data: {
        'amount': amount,
        'method': method,
      },
    );
    
    return PaymentModel.fromJson(response['data']);
  }
  
  @override
  Future<PaymentModel> verifyPayment(String orderId) async {
    final response = await _apiClient.post(
      '/api/payments/$orderId/verify',
    );
    
    return PaymentModel.fromJson(response['data']);
  }
  
  @override
  Future<List<PaymentModel>> getPaymentHistory() async {
    final response = await _apiClient.get('/api/payments');
    final data = response['data'] as List;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }
}
```


```dart
// packages/data/payment_data/lib/src/repositories/payment_repository_impl.dart
import 'package:payment_domain/payment_domain.dart';
import '../datasources/remote/payment_remote_datasource.dart';
import '../datasources/sdk/payment_sdk_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _remoteDataSource;
  final Map<PaymentMethod, PaymentSDKDataSource> _sdkDataSources;
  
  const PaymentRepositoryImpl({
    required PaymentRemoteDataSource remoteDataSource,
    required Map<PaymentMethod, PaymentSDKDataSource> sdkDataSources,
  })  : _remoteDataSource = remoteDataSource,
        _sdkDataSources = sdkDataSources;
  
  @override
  Future<PaymentEntity> createPayment({
    required double amount,
    required PaymentMethod method,
  }) async {
    // 调用后端 API 创建订单
    final model = await _remoteDataSource.createPayment(
      amount: amount,
      method: _methodToString(method),
    );
    
    return model.toEntity();
  }
  
  @override
  Future<PaymentResultEntity> executePayment({
    required String orderId,
    required PaymentMethod method,
  }) async {
    // 获取对应的 SDK DataSource
    final sdkDataSource = _sdkDataSources[method];
    
    if (sdkDataSource == null) {
      throw UnsupportedError('不支持的支付方式: $method');
    }
    
    // 检查是否安装了支付应用
    final isInstalled = await sdkDataSource.isAppInstalled();
    if (!isInstalled) {
      return PaymentResultEntity(
        success: false,
        errorMessage: '未安装${_getMethodName(method)}应用',
      );
    }
    
    // 调用 SDK 执行支付
    return await sdkDataSource.pay(
      orderId: orderId,
      amount: 0, // 从订单信息中获取
      currency: 'CNY',
    );
  }
  
  @override
  Future<PaymentEntity> verifyPayment(String orderId) async {
    final model = await _remoteDataSource.verifyPayment(orderId);
    return model.toEntity();
  }
  
  @override
  Future<List<PaymentEntity>> getPaymentHistory() async {
    final models = await _remoteDataSource.getPaymentHistory();
    return models.map((m) => m.toEntity()).toList();
  }
  
  String _methodToString(PaymentMethod method) {
    return method.toString().split('.').last;
  }
  
  String _getMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.alipay:
        return '支付宝';
      case PaymentMethod.wechat:
        return '微信';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }
}
```


### 3. 依赖注入配置

```dart
// apps/lt_app/lib/src/di/payment_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_domain/payment_domain.dart';
import 'package:payment_data/payment_data.dart';

// SDK DataSources
final alipaySDKDataSourceProvider = Provider<PaymentSDKDataSource>((ref) {
  return AlipaySDKDataSource();
});

final wechatSDKDataSourceProvider = Provider<PaymentSDKDataSource>((ref) {
  return WechatSDKDataSource();
});

// Remote DataSource
final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentRemoteDataSourceImpl(apiClient);
});

// Repository
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);
  final alipaySDK = ref.watch(alipaySDKDataSourceProvider);
  final wechatSDK = ref.watch(wechatSDKDataSourceProvider);
  
  return PaymentRepositoryImpl(
    remoteDataSource: remoteDataSource,
    sdkDataSources: {
      PaymentMethod.alipay: alipaySDK,
      PaymentMethod.wechat: wechatSDK,
    },
  );
});

// UseCases
final createPaymentProvider = Provider<CreatePayment>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return CreatePaymentImpl(repository);
});

final executePaymentProvider = Provider<ExecutePayment>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return ExecutePaymentImpl(repository);
});
```


### 4. Presentation Layer 使用

```dart
// packages/features/payment/lib/src/payment_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:payment_domain/payment_domain.dart';

part 'payment_controller.g.dart';

@riverpod
class PaymentController extends _$PaymentController {
  @override
  AsyncValue<PaymentEntity?> build() {
    return const AsyncValue.data(null);
  }
  
  Future<void> createAndPay({
    required double amount,
    required PaymentMethod method,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      // 1. 创建支付订单
      final createPayment = ref.read(createPaymentProvider);
      final payment = await createPayment(
        amount: amount,
        method: method,
      );
      
      // 2. 执行支付
      final executePayment = ref.read(executePaymentProvider);
      final result = await executePayment(
        orderId: payment.id,
        method: method,
      );
      
      if (result.success) {
        state = AsyncValue.data(payment);
      } else {
        state = AsyncValue.error(
          result.errorMessage ?? '支付失败',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// packages/features/payment/lib/src/payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_domain/payment_domain.dart';
import 'payment_controller.dart';

class PaymentPage extends ConsumerWidget {
  final double amount;
  
  const PaymentPage({super.key, required this.amount});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('选择支付方式')),
      body: Column(
        children: [
          Text('支付金额: ¥${amount.toStringAsFixed(2)}'),
          const SizedBox(height: 20),
          
          // 支付宝
          _PaymentMethodButton(
            icon: Icons.payment,
            label: '支付宝支付',
            onTap: () => _pay(ref, PaymentMethod.alipay),
          ),
          
          // 微信
          _PaymentMethodButton(
            icon: Icons.wechat,
            label: '微信支付',
            onTap: () => _pay(ref, PaymentMethod.wechat),
          ),
          
          // 显示支付状态
          state.when(
            data: (payment) {
              if (payment != null) {
                return const Text('支付成功！', style: TextStyle(color: Colors.green));
              }
              return const SizedBox.shrink();
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) => Text('支付失败: $error', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _pay(WidgetRef ref, PaymentMethod method) {
    ref.read(paymentControllerProvider.notifier).createAndPay(
      amount: amount,
      method: method,
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
```


---

## 关键设计要点

### 1. SDK 放在 Data Layer 的原因

✅ **符合依赖倒置原则**
- Domain Layer 定义抽象接口（PaymentRepository）
- Data Layer 实现具体细节（SDK 调用）
- Domain Layer 不依赖任何 SDK

✅ **易于替换和扩展**
```dart
// 添加新的支付方式只需要：
// 1. 实现 PaymentSDKDataSource 接口
class StripeSDKDataSource implements PaymentSDKDataSource {
  // 实现 Stripe SDK 调用
}

// 2. 在依赖注入中注册
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    sdkDataSources: {
      PaymentMethod.alipay: alipaySDK,
      PaymentMethod.wechat: wechatSDK,
      PaymentMethod.stripe: stripeSDK,  // 新增
    },
  );
});
```

✅ **易于测试**
```dart
// 可以创建 Mock SDK DataSource 进行测试
class MockPaymentSDKDataSource implements PaymentSDKDataSource {
  @override
  Future<PaymentResultEntity> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    return const PaymentResultEntity(
      success: true,
      transactionId: 'mock_transaction_id',
    );
  }
  
  @override
  Future<bool> isAppInstalled() async => true;
  
  @override
  Future<void> initialize() async {}
}
```

### 2. 为什么不放在其他层？

❌ **不应该放在 Domain Layer**
- Domain Layer 应该是纯 Dart 代码，不依赖任何框架或 SDK
- 违反了依赖倒置原则
- 难以测试

❌ **不应该放在 Presentation Layer**
- Presentation Layer 应该只关注 UI 逻辑
- 会导致业务逻辑和 UI 耦合
- 难以复用

❌ **不应该直接放在 Core Layer**
- Core Layer 是基础设施层，提供通用能力
- 支付 SDK 是业务相关的，应该属于 Data Layer
- 但可以在 Core Layer 创建 SDK Wrapper（可选）

### 3. 可选的 Core Layer SDK Wrapper

如果多个 SDK 有相似的接口，可以在 Core Layer 创建统一的 Wrapper：

```dart
// packages/core/payment_sdk/lib/src/payment_sdk_interface.dart
abstract interface class PaymentSDKInterface {
  Future<void> initialize(Map<String, dynamic> config);
  Future<PaymentSDKResult> pay(PaymentSDKRequest request);
  Future<bool> isAppInstalled();
}

class PaymentSDKRequest {
  final String orderId;
  final double amount;
  final String currency;
  
  const PaymentSDKRequest({
    required this.orderId,
    required this.amount,
    required this.currency,
  });
}

class PaymentSDKResult {
  final bool success;
  final String? transactionId;
  final String? errorCode;
  final String? errorMessage;
  
  const PaymentSDKResult({
    required this.success,
    this.transactionId,
    this.errorCode,
    this.errorMessage,
  });
}

// packages/core/payment_sdk/lib/src/alipay/alipay_sdk_wrapper.dart
import 'package:tobias/tobias.dart' as alipay;

class AlipaySDKWrapper implements PaymentSDKInterface {
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    // 支付宝初始化
  }
  
  @override
  Future<PaymentSDKResult> pay(PaymentSDKRequest request) async {
    final result = await alipay.pay(orderInfo: request.orderId);
    
    return PaymentSDKResult(
      success: result['resultStatus'] == '9000',
      transactionId: result['result'],
      errorCode: result['resultStatus'],
      errorMessage: result['memo'],
    );
  }
  
  @override
  Future<bool> isAppInstalled() async {
    return await alipay.isAliPayInstalled();
  }
}
```

然后在 Data Layer 使用这个 Wrapper：

```dart
// packages/data/payment_data/lib/src/datasources/sdk/alipay_sdk_datasource.dart
class AlipaySDKDataSource implements PaymentSDKDataSource {
  final PaymentSDKInterface _sdkWrapper;
  
  const AlipaySDKDataSource(this._sdkWrapper);
  
  @override
  Future<PaymentResultEntity> pay({
    required String orderId,
    required double amount,
    required String currency,
  }) async {
    final request = PaymentSDKRequest(
      orderId: orderId,
      amount: amount,
      currency: currency,
    );
    
    final result = await _sdkWrapper.pay(request);
    
    return PaymentResultEntity(
      success: result.success,
      transactionId: result.transactionId,
      errorMessage: result.errorMessage,
    );
  }
}
```


---

## 包依赖配置

### Domain Package

```yaml
# packages/domain/payment_domain/pubspec.yaml
name: payment_domain
description: Payment domain layer
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  # 只依赖纯 Dart 包
  equatable: ^2.0.5
```

### Data Package

```yaml
# packages/data/payment_data/pubspec.yaml
name: payment_data
description: Payment data layer
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  # Domain Layer
  payment_domain:
    path: ../../domain/payment_domain
  
  # Infrastructure
  network:
    path: ../../core/network
  
  # 第三方 SDK
  tobias: ^3.0.0              # 支付宝 SDK
  fluwx: ^4.0.0               # 微信 SDK
  flutter_stripe: ^10.0.0     # Stripe SDK (如果需要)
  
  # Serialization
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  mockito: ^5.4.4             # 用于测试
```

### Core SDK Wrapper Package (可选)

```yaml
# packages/core/payment_sdk/pubspec.yaml
name: payment_sdk
description: Payment SDK wrappers
version: 1.0.0
publish_to: none

environment:
  sdk: ^3.8.0

dependencies:
  # 第三方 SDK
  tobias: ^3.0.0
  fluwx: ^4.0.0
  flutter_stripe: ^10.0.0
```

---

## 测试策略

### 1. Domain Layer 测试

```dart
// packages/domain/payment_domain/test/usecases/create_payment_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:payment_domain/payment_domain.dart';

class MockPaymentRepository extends Mock implements PaymentRepository {}

void main() {
  late CreatePayment useCase;
  late MockPaymentRepository mockRepository;
  
  setUp(() {
    mockRepository = MockPaymentRepository();
    useCase = CreatePaymentImpl(mockRepository);
  });
  
  test('应该创建支付订单', () async {
    // Arrange
    const amount = 100.0;
    const method = PaymentMethod.alipay;
    final expectedPayment = PaymentEntity(
      id: '123',
      amount: amount,
      currency: 'CNY',
      status: PaymentStatus.pending,
      method: method,
      createdAt: DateTime.now(),
    );
    
    when(mockRepository.createPayment(
      amount: amount,
      method: method,
    )).thenAnswer((_) async => expectedPayment);
    
    // Act
    final result = await useCase(amount: amount, method: method);
    
    // Assert
    expect(result, expectedPayment);
    verify(mockRepository.createPayment(amount: amount, method: method));
  });
  
  test('金额小于等于 0 时应该抛出异常', () async {
    // Act & Assert
    expect(
      () => useCase(amount: 0, method: PaymentMethod.alipay),
      throwsA(isA<ArgumentError>()),
    );
    
    expect(
      () => useCase(amount: -10, method: PaymentMethod.alipay),
      throwsA(isA<ArgumentError>()),
    );
  });
  
  test('金额超过 10000 时应该抛出异常', () async {
    // Act & Assert
    expect(
      () => useCase(amount: 10001, method: PaymentMethod.alipay),
      throwsA(isA<ArgumentError>()),
    );
  });
}
```

### 2. Data Layer 测试

```dart
// packages/data/payment_data/test/repositories/payment_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:payment_domain/payment_domain.dart';
import 'package:payment_data/payment_data.dart';

class MockPaymentRemoteDataSource extends Mock 
    implements PaymentRemoteDataSource {}

class MockPaymentSDKDataSource extends Mock 
    implements PaymentSDKDataSource {}

void main() {
  late PaymentRepositoryImpl repository;
  late MockPaymentRemoteDataSource mockRemoteDataSource;
  late MockPaymentSDKDataSource mockAlipaySDK;
  
  setUp(() {
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    mockAlipaySDK = MockPaymentSDKDataSource();
    
    repository = PaymentRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      sdkDataSources: {
        PaymentMethod.alipay: mockAlipaySDK,
      },
    );
  });
  
  test('executePayment 应该调用对应的 SDK', () async {
    // Arrange
    const orderId = '123';
    const method = PaymentMethod.alipay;
    
    when(mockAlipaySDK.isAppInstalled()).thenAnswer((_) async => true);
    when(mockAlipaySDK.pay(
      orderId: orderId,
      amount: anyNamed('amount'),
      currency: anyNamed('currency'),
    )).thenAnswer((_) async => const PaymentResultEntity(success: true));
    
    // Act
    final result = await repository.executePayment(
      orderId: orderId,
      method: method,
    );
    
    // Assert
    expect(result.success, true);
    verify(mockAlipaySDK.isAppInstalled());
    verify(mockAlipaySDK.pay(
      orderId: orderId,
      amount: anyNamed('amount'),
      currency: anyNamed('currency'),
    ));
  });
  
  test('未安装支付应用时应该返回失败', () async {
    // Arrange
    when(mockAlipaySDK.isAppInstalled()).thenAnswer((_) async => false);
    
    // Act
    final result = await repository.executePayment(
      orderId: '123',
      method: PaymentMethod.alipay,
    );
    
    // Assert
    expect(result.success, false);
    expect(result.errorMessage, contains('未安装'));
  });
}
```

---

## 总结

### SDK 应该放在哪一层？

**答案：Data Layer**

### 架构层次

```
Presentation Layer (Features)
    ↓ 使用 UseCases
Domain Layer (payment_domain)
    ↑ 实现 Repository 接口
Data Layer (payment_data)
    ├── Remote DataSource (后端 API)
    └── SDK DataSource (第三方 SDK) ← SDK 在这里
    ↓ 可选：使用 SDK Wrapper
Core Layer (payment_sdk) - 可选
    └── SDK Wrapper (统一接口)
    ↓ 依赖
Third-Party SDKs (tobias, fluwx, etc.)
```

### 核心优势

1. ✅ **依赖倒置**：Domain 不依赖具体 SDK
2. ✅ **易于替换**：切换支付提供商只需修改 Data Layer
3. ✅ **易于测试**：可以 mock SDK DataSource
4. ✅ **职责清晰**：每一层都有明确的职责
5. ✅ **可扩展**：添加新支付方式不影响现有代码

### 实施步骤

1. 创建 `payment_domain` 包（定义业务接口）
2. 创建 `payment_data` 包（实现 SDK 封装）
3. 在 `apps/lt_app` 中配置依赖注入
4. 创建 `payment` feature（UI 层）
5. 编写测试

这样的架构设计既符合 Clean Architecture 原则，又保持了代码的灵活性和可维护性！
