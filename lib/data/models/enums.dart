enum Role {
  CLIENT,
  ADMIN,
  DISTRIBUTEUR
}

enum TransactionType {
  DEPOT,
  RETRAIT,
  TRANSFERT,
  PAIEMENT,
  UNKNOWN,
  SCHEDULED_TRANSFER
}

enum TransactionStatus {
  PENDING,
  COMPLETED,
  FAILED,
  CANCELLED, UNKNOWN,
}
enum ScheduleFrequency {
  DAILY,
  WEEKLY,
  MONTHLY
}