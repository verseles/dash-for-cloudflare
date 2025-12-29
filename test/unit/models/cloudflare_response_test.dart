import 'package:flutter_test/flutter_test.dart';
import 'package:cf/core/api/models/cloudflare_response.dart';
import 'package:cf/features/dns/domain/models/zone.dart';

void main() {
  group('CloudflareResponse', () {
    test('fromJson parses successful response with single result', () {
      final json = {
        'result': {'id': 'zone123', 'name': 'example.com', 'status': 'active'},
        'success': true,
        'errors': <dynamic>[],
        'messages': <dynamic>[],
      };

      final response = CloudflareResponse.fromJson(
        json,
        (obj) => Zone.fromJson(obj as Map<String, dynamic>),
      );

      expect(response.success, true);
      expect(response.result, isNotNull);
      expect(response.result!.id, 'zone123');
      expect(response.errors, isEmpty);
      expect(response.messages, isEmpty);
    });

    test('fromJson parses response with errors', () {
      final json = {
        'result': null,
        'success': false,
        'errors': [
          {'code': 10000, 'message': 'Authentication error'},
        ],
        'messages': <dynamic>[],
      };

      final response = CloudflareResponse.fromJson(
        json,
        (obj) => obj as Map<String, dynamic>?,
      );

      expect(response.success, false);
      expect(response.result, isNull);
      expect(response.errors.length, 1);
      expect(response.errors[0].code, 10000);
      expect(response.errors[0].message, 'Authentication error');
    });

    test('fromJson parses response with resultInfo', () {
      // Note: The model uses 'resultInfo' (camelCase) as the JSON key
      // based on the generated code
      final json = {
        'result': <dynamic>[],
        'success': true,
        'errors': <dynamic>[],
        'messages': <dynamic>[],
        'resultInfo': {
          'page': 1,
          'per_page': 20,
          'count': 5,
          'total_count': 5,
          'total_pages': 1,
        },
      };

      final response = CloudflareResponse.fromJson(
        json,
        (obj) => obj as List<dynamic>,
      );

      expect(response.resultInfo, isNotNull);
      expect(response.resultInfo!.page, 1);
      expect(response.resultInfo!.perPage, 20);
      expect(response.resultInfo!.count, 5);
      expect(response.resultInfo!.totalCount, 5);
      expect(response.resultInfo!.totalPages, 1);
    });

    test('fromJson parses response with messages', () {
      final json = {
        'result': null,
        'success': true,
        'errors': <dynamic>[],
        'messages': [
          {'code': 1001, 'message': 'Record updated successfully'},
        ],
      };

      final response = CloudflareResponse.fromJson(json, (obj) => obj);

      expect(response.messages.length, 1);
      expect(response.messages[0].code, 1001);
      expect(response.messages[0].message, 'Record updated successfully');
    });
  });

  group('CloudflareError', () {
    test('fromJson parses correctly', () {
      final json = {'code': 9109, 'message': 'Invalid access token'};

      final error = CloudflareError.fromJson(json);

      expect(error.code, 9109);
      expect(error.message, 'Invalid access token');
    });

    test('toJson serializes correctly', () {
      const error = CloudflareError(code: 1001, message: 'Test error');

      final json = error.toJson();

      expect(json['code'], 1001);
      expect(json['message'], 'Test error');
    });
  });

  group('CloudflareMessage', () {
    test('fromJson parses correctly', () {
      final json = {'code': 2001, 'message': 'Operation completed'};

      final message = CloudflareMessage.fromJson(json);

      expect(message.code, 2001);
      expect(message.message, 'Operation completed');
    });

    test('toJson serializes correctly', () {
      const message = CloudflareMessage(code: 3001, message: 'Info message');

      final json = message.toJson();

      expect(json['code'], 3001);
      expect(json['message'], 'Info message');
    });
  });

  group('CloudflareResultInfo', () {
    test('fromJson parses correctly', () {
      final json = {
        'page': 2,
        'per_page': 50,
        'count': 50,
        'total_count': 150,
        'total_pages': 3,
      };

      final info = CloudflareResultInfo.fromJson(json);

      expect(info.page, 2);
      expect(info.perPage, 50);
      expect(info.count, 50);
      expect(info.totalCount, 150);
      expect(info.totalPages, 3);
    });

    test('toJson serializes correctly', () {
      const info = CloudflareResultInfo(
        page: 1,
        perPage: 100,
        count: 25,
        totalCount: 25,
        totalPages: 1,
      );

      final json = info.toJson();

      expect(json['page'], 1);
      expect(json['per_page'], 100);
      expect(json['count'], 25);
      expect(json['total_count'], 25);
      expect(json['total_pages'], 1);
    });
  });

  group('DeleteResponse', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'deleted_record_123'};

      final response = DeleteResponse.fromJson(json);

      expect(response.id, 'deleted_record_123');
    });

    test('toJson serializes correctly', () {
      const response = DeleteResponse(id: 'rec_to_delete');

      final json = response.toJson();

      expect(json['id'], 'rec_to_delete');
    });
  });
}
