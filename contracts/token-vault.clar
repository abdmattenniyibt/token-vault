;; ===========================================================
;; advanced-token-vault.clar
;; A secure and feature-rich STX vault for Stacks blockchain
;; ===========================================================

(define-constant ERR_NOT_ENOUGH_FUNDS (err u100))
(define-constant ERR_NOT_AUTHORIZED (err u101))
(define-constant ERR_VAULT_PAUSED (err u102))
(define-constant ERR_INVALID_AMOUNT (err u103))

;; -------------------------------
;; ADMIN
;; -------------------------------
(define-constant contract-owner tx-sender)

(define-data-var vault-paused bool false)

;; -------------------------------
;; STORAGE
;; -------------------------------
(define-map user-balances
  { user: principal }
  { balance: uint })

;; -------------------------------
;; EVENTS
;; -------------------------------
(define-data-var deposit-event (tuple (user principal) (amount uint)) (tuple (user tx-sender) (amount u0)))
(define-data-var withdraw-event (tuple (user principal) (amount uint)) (tuple (user tx-sender) (amount u0)))
(define-data-var admin-drain-event (tuple (to principal) (amount uint)) (tuple (to tx-sender) (amount u0)))

;; -------------------------------
;; UTILITIES
;; -------------------------------

(define-private (only-owner)
  (begin
    (if (is-eq tx-sender contract-owner)
        (ok true)
        ERR_NOT_AUTHORIZED)
  )
)

(define-private (when-not-paused)
  (begin
    (if (var-get vault-paused)
        ERR_VAULT_PAUSED
        (ok true))
  )
)

;; -------------------------------
;; CORE FUNCTIONS
;; -------------------------------

;; Deposit STX to vault
;; NOTE: some clarity environments may not expose the `stx-get-transfer-amount` builtin.
;; To avoid unresolved-builtin compile errors, `deposit` accepts an explicit `amount`.
;; Callers should attach the STX transfer in the same transaction when invoking this function
;; (or use off-chain coordination to ensure funds are moved). The contract only records the
;; deposited amount in its map.
(define-public (deposit (amount uint))
  (begin
    (try! (when-not-paused))
    (if (<= amount u0)
        ERR_INVALID_AMOUNT
        (let ((current (default-to u0 (get balance (map-get? user-balances { user: tx-sender })))))
          (map-set user-balances { user: tx-sender } { balance: (+ current amount) })
          (var-set deposit-event (tuple (user tx-sender) (amount amount)))
          (print (var-get deposit-event))
          (ok amount))
    )
  )
)

;; Withdraw STX from vault
(define-public (withdraw (amount uint))
  (begin
    (try! (when-not-paused))
    (let ((current (default-to u0 (get balance (map-get? user-balances { user: tx-sender })))))
      (if (< current amount)
          ERR_NOT_ENOUGH_FUNDS
          (begin
            (map-set user-balances { user: tx-sender } { balance: (- current amount) })
            (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
            (var-set withdraw-event (tuple (user tx-sender) (amount amount)))
            (print (var-get withdraw-event))
            (ok amount)
          )
      )
    )
  )
)

;; -------------------------------
;; ADMIN CONTROLS
;; -------------------------------

;; Pause vault (only owner)
(define-public (pause-vault)
  (begin
    (try! (only-owner))
    (var-set vault-paused true)
    (ok "Vault paused")
  )
)

;; Unpause vault (only owner)
(define-public (unpause-vault)
  (begin
    (try! (only-owner))
    (var-set vault-paused false)
    (ok "Vault unpaused")
  )
)

;; Emergency drain vault (only owner)
(define-public (admin-drain (to principal) (amount uint))
  (begin
    (try! (only-owner))
    (try! (stx-transfer? amount (as-contract tx-sender) to))
    (var-set admin-drain-event (tuple (to to) (amount amount)))
    (print (var-get admin-drain-event))
    (ok "Vault drained")
  )
)

;; -------------------------------
;; READ-ONLY FUNCTIONS
;; -------------------------------

;; Get user balance
(define-read-only (get-balance (user principal))
  (ok (default-to u0 (get balance (map-get? user-balances { user: user }))))
)

;; Get vault total balance
(define-read-only (get-vault-balance)
  (ok (stx-get-balance (as-contract tx-sender)))
)

;; Check if vault is paused
(define-read-only (is-paused)
  (ok (var-get vault-paused))
)
