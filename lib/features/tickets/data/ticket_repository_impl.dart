import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reader/core/network/http_client.dart';
import 'package:reader/features/tickets/data/ticket_dto.dart';
import 'package:reader/features/tickets/domain/ticket.dart';
import 'package:reader/features/tickets/domain/ticket_params.dart';
import 'package:reader/features/tickets/domain/ticket_repository.dart';

@Injectable(as: TicketRepository)
class TicketRepositoryImpl implements TicketRepository {
  final HttpClient _httpClient;

  TicketRepositoryImpl(this._httpClient);

  @override
  Future<Ticket?> getTicketById(String id) async {
    final response = await _httpClient.get('/api/ticket/$id');
    final json = await _parseBody(response);
    final ticket = json['ticket'];
    if (ticket == null) return null;
    return TicketDto.fromJson(ticket as Map<String, dynamic>).toDomain();
  }

  @override
  Future<Ticket?> getTicketByLabel(String name) async {
    final response = await _httpClient.get('/api/ticket/label/$name');
    final json = await _parseBody(response);
    final ticket = json['ticket'];
    if (ticket == null) return null;
    return TicketDto.fromJson(ticket as Map<String, dynamic>).toDomain();
  }

  @override
  Future<Ticket?> getTicketByValue(String value) async {
    final response = await _httpClient.get('/api/ticket/value/$value');
    final json = await _parseBody(response);
    final ticket = json['ticket'];
    if (ticket == null) return null;
    return TicketDto.fromJson(ticket as Map<String, dynamic>).toDomain();
  }

  @override
  Future<List<Ticket>> getTickets(TicketParams params) async {
    final response = await _httpClient.get(
      '/api/ticket',
    );
    final json = await _parseBody(response);
    final tickets = json['tickets'] as List<dynamic>;
    return tickets
        .map((e) => TicketDto.fromJson(e as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<Ticket?> markUsed(String id) async {
    final response = await _httpClient.put('/api/ticket/$id/use');
    final json = await _parseBody(response);
    final ticket = json['ticket'];
    if (ticket == null) return null;
    return TicketDto.fromJson(ticket as Map<String, dynamic>).toDomain();
  }

  Future<Map<String, dynamic>> _parseBody(HttpClientResponse response) async {
    final raw = await response.transform(utf8.decoder).join();
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}