enum Role {
  CLIENT,
  ADMIN,
  DISTRIBUTEUR
}

enum TransactionType {
  DEPOT,
  RETRAIT,
  TRANSFERT,
  PAIEMENT, UNKNOWN
}

enum TransactionStatus {
  PENDING,
  COMPLETED,
  FAILED,
  ANNULEE, UNKNOWN,
}
