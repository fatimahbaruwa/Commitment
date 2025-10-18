;; title: Commitment Contract
;; version: 1.0.0
;; summary: A simple commitment contract where users stake tokens they lose if they fail to complete their goal
;; description: Users can create commitments by staking STX tokens. If they fail to complete their goal, they lose their stake.

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-COMMITMENT-NOT-FOUND (err u101))
(define-constant ERR-COMMITMENT-ALREADY-COMPLETED (err u102))
(define-constant ERR-COMMITMENT-ALREADY-FAILED (err u103))
(define-constant ERR-COMMITMENT-EXPIRED (err u104))
(define-constant ERR-INSUFFICIENT-BALANCE (err u105))
(define-constant ERR-INVALID-DEADLINE (err u106))
(define-constant ERR-INVALID-DESCRIPTION (err u107))

;; data vars
(define-data-var next-commitment-id uint u1)

;; data maps
(define-map commitments
  uint
  {
    creator: principal,
    description: (string-ascii 256),
    stake-amount: uint,
    deadline: uint,
    status: (string-ascii 10)
  }
)

(define-map commitment-stakes
  uint
  uint
)

;; public functions

(define-public (create-commitment (description (string-ascii 256)) (deadline uint))
  (let
    (
      (commitment-id (var-get next-commitment-id))
      (stake-amount (stx-get-balance tx-sender))
      (validated-description (validate-description description))
    )
    (asserts! (> deadline block-height) ERR-INVALID-DEADLINE)
    (asserts! (> stake-amount u0) ERR-INSUFFICIENT-BALANCE)
    (asserts! validated-description ERR-INVALID-DESCRIPTION)

    (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))

    (map-set commitments commitment-id
      {
        creator: tx-sender,
        description: (sanitize-description description),
        stake-amount: stake-amount,
        deadline: deadline,
        status: "active"
      }
    )

    (map-set commitment-stakes commitment-id stake-amount)
    (var-set next-commitment-id (+ commitment-id u1))

    (ok commitment-id)
  )
)

(define-public (complete-commitment (commitment-id uint))
  (let
    (
      (commitment (unwrap! (map-get? commitments commitment-id) ERR-COMMITMENT-NOT-FOUND))
      (stake-amount (unwrap! (map-get? commitment-stakes commitment-id) ERR-COMMITMENT-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get creator commitment)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status commitment) "active") ERR-COMMITMENT-ALREADY-COMPLETED)
    (asserts! (<= block-height (get deadline commitment)) ERR-COMMITMENT-EXPIRED)

    (try! (as-contract (stx-transfer? stake-amount tx-sender (get creator commitment))))

    (map-set commitments commitment-id
      (merge commitment { status: "completed" })
    )

    (map-delete commitment-stakes commitment-id)
    (ok true)
  )
)

(define-public (mark-commitment-failed (commitment-id uint))
  (let
    (
      (commitment (unwrap! (map-get? commitments commitment-id) ERR-COMMITMENT-NOT-FOUND))
      (stake-amount (unwrap! (map-get? commitment-stakes commitment-id) ERR-COMMITMENT-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender (get creator commitment)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status commitment) "active") ERR-COMMITMENT-ALREADY-FAILED)

    (map-set commitments commitment-id
      (merge commitment { status: "failed" })
    )

    (map-delete commitment-stakes commitment-id)
    (ok true)
  )
)

(define-public (expire-commitment (commitment-id uint))
  (let
    (
      (commitment (unwrap! (map-get? commitments commitment-id) ERR-COMMITMENT-NOT-FOUND))
      (stake-amount (unwrap! (map-get? commitment-stakes commitment-id) ERR-COMMITMENT-NOT-FOUND))
    )
    (asserts! (is-eq (get status commitment) "active") ERR-COMMITMENT-ALREADY-FAILED)
    (asserts! (> block-height (get deadline commitment)) ERR-COMMITMENT-EXPIRED)

    (map-set commitments commitment-id
      (merge commitment { status: "expired" })
    )

    (map-delete commitment-stakes commitment-id)
    (ok true)
  )
)

;; private functions

(define-private (validate-description (description (string-ascii 256)))
  (and
    (> (len description) u0)
    (<= (len description) u256)
    (not (is-eq description ""))
  )
)

(define-private (sanitize-description (description (string-ascii 256)))
  (if (validate-description description)
    description
    "Invalid description"
  )
)

;; read only functions

(define-read-only (get-commitment (commitment-id uint))
  (map-get? commitments commitment-id)
)

(define-read-only (get-commitment-stake (commitment-id uint))
  (map-get? commitment-stakes commitment-id)
)

(define-read-only (get-next-commitment-id)
  (var-get next-commitment-id)
)

(define-read-only (get-contract-balance)
  (stx-get-balance (as-contract tx-sender))
)
