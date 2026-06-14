class CardParams {
  int? page;
  int? size;
  String ownerId;

  CardParams({
    this.page,
    this.size,
    required this.ownerId,
  });
}