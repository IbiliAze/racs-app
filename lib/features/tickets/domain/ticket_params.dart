class TicketParams {
  int? page;
  int? size;
  String eventId;

  TicketParams({
    this.page,
    this.size,
    required this.eventId,
  });
}