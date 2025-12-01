;; dmcoin - a simple fungible token implemented in Clarity

(define-constant CONTRACT-NAME "dmcoin")
(define-constant CONTRACT-SYMBOL "DMC")
(define-constant CONTRACT-DECIMALS u6) ;; 6 decimal places

;; Errors
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))

;; Total token supply
(define-data-var total-supply uint u0)

;; Balances map: account principal -> token balance
(define-map balances { owner: principal } uint)

;; --- Read-only helpers -----------------------------------------------------

(define-read-only (get-name)
  (ok CONTRACT-NAME))

(define-read-only (get-symbol)
  (ok CONTRACT-SYMBOL))

(define-read-only (get-decimals)
  (ok CONTRACT-DECIMALS))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (default-to u0 (map-get? balances { owner: who }))))

;; --- Public functions ------------------------------------------------------

;; Mint new tokens to a recipient address.
;; NOTE: this version allows anyone to call `mint`. In a production token,
;; you would typically restrict minting to an owner or governance contract.
(define-public (mint (recipient principal) (amount uint))
  (let ((current-balance (default-to u0 (map-get? balances { owner: recipient }))))
    (map-set balances { owner: recipient } (+ current-balance amount))
    (var-set total-supply (+ (var-get total-supply) amount))
    (ok amount)))

;; Transfer tokens from `sender` to `recipient`.
;; The tx-sender must match `sender`.
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq sender tx-sender) ERR-NOT-AUTHORIZED)
    (let (
          (sender-balance (default-to u0 (map-get? balances { owner: sender })))
          (recipient-balance (default-to u0 (map-get? balances { owner: recipient })))
         )
      (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
      (map-set balances { owner: sender } (- sender-balance amount))
      (map-set balances { owner: recipient } (+ recipient-balance amount))
      (ok amount))))
