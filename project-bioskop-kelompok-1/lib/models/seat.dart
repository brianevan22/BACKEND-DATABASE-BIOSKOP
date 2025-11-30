class Seat {
  final int ticketId;
  final String seatNumber;
  bool isAvailable;

  Seat({required this.ticketId, required this.seatNumber, this.isAvailable = true});
}
