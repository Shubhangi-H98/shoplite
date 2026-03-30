import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:shoplite/features/catalog/data/repositories/product_repository_impl.dart';
import 'package:shoplite/core/network/api_client.dart';
import 'package:shoplite/features/catalog/data/models/product_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockApiClient mockApiClient;
  late ProductRepositoryImpl repository;

  setUpAll(() async {
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        return null;
      }
      return null;
    });

    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
  });

  setUp(() async {
    mockApiClient = MockApiClient();
    if (!Hive.isBoxOpen('products_box')) {
      await Hive.openBox<ProductModel>('products_box');
    }
    repository = ProductRepositoryImpl(mockApiClient);
  });

  test('getProducts returns a list of products on successful API call', () async {
    final mockResponseData = {
      'products': [
        {
          'id': 1,
          'title': 'Test Product',
          'price': 100,
          'description': 'A test description',
          'category': 'test',
          'thumbnail': 'https://link.com',
          'stock': 10,
          'rating': 4.5,
          'discountPercentage': 1.0,
          'brand': 'test'
        }
      ]
    };

    when(() => mockApiClient.get(
      any(),
      queryParameters: any(named: 'queryParameters'),
    )).thenAnswer((_) async => Response(
      data: mockResponseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: '/products'),
    ));

    final result = await repository.getProducts(limit: 1, skip: 0);

    expect(result, isNotEmpty);
    expect(result.first.title, 'Test Product');
  });

  tearDownAll(() async {
    await Hive.close();
  });
}