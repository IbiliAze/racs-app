import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:racs_reader/core/network/http_client.dart';
import 'package:racs_reader/features/cards/data/card_dto.dart';
import 'package:racs_reader/features/cards/domain/card.dart';
import 'package:racs_reader/features/cards/domain/card_params.dart';
import 'package:racs_reader/features/cards/domain/card_repository.dart';

@Injectable(as: CardRepository)
class CardRepositoryImpl implements CardRepository {
  final HttpClient _httpClient;

  CardRepositoryImpl(this._httpClient);

  @override
  Future<Card?> getCardById(String id) async {
    final response = await _httpClient.get('/api/card/$id');
    final json = await _parseBody(response);
    final card = json['card'];
    if (card == null) return null;
    return CardDto.fromJson(card as Map<String, dynamic>).toDomain();
  }

  @override
  Future<Card?> getCardByLabel(String name) async {
    final response = await _httpClient.get('/api/card/label/$name');
    final json = await _parseBody(response);
    final card = json['card'];
    if (card == null) return null;
    return CardDto.fromJson(card as Map<String, dynamic>).toDomain();
  }

  @override
  Future<Card?> getCardByValue(String value) async {
    final response = await _httpClient.get('/api/card/value/$value');
    final json = await _parseBody(response);
    final card = json['card'];
    if (card == null) return null;
    return CardDto.fromJson(card as Map<String, dynamic>).toDomain();
  }

  @override
  Future<List<Card>> getCards(CardParams params) async {
    final response = await _httpClient.get(
      '/api/card',
      queryParameters: {
        'size': '10000',
        if (params.campaignId.isNotEmpty) 'campaignId': params.campaignId,
      },
    );
    final json = await _parseBody(response);
    final cards = json['cards'] as List<dynamic>;
    return cards
        .map((e) => CardDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<Card?> markUsed(String id) async {
    final response = await _httpClient.put('/api/card/$id/use');
    final json = await _parseBody(response);
    final card = json['card'];
    if (card == null) return null;
    return CardDto.fromJson(card as Map<String, dynamic>).toDomain();
  }

  Future<Map<String, dynamic>> _parseBody(HttpClientResponse response) async {
    final raw = await response.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
