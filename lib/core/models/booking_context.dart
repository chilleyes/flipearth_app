/// Used to pass trip context through the booking flow.
class BookingContext {
  final int tripId;
  final int segmentId;
  final String entrySource;

  BookingContext({
    required this.tripId,
    required this.segmentId,
    required this.entrySource,
  });

  /// Convert to JSON format to append to the Eurostar Booking/Preorder API payload
  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'segment_id': segmentId,
        'source_entry': entrySource,
      };

  factory BookingContext.fromJson(Map<String, dynamic> json) => BookingContext(
        tripId: json['trip_id'],
        segmentId: json['segment_id'],
        entrySource: json['source_entry'] ?? 'trip',
      );
}
