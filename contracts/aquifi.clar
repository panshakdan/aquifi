;; Aquifi Airdrop Contract - Improved Version

;; Data Maps
(define-map eligibility principal {nft-held: bool, tx-count: uint, eligible: bool})
(define-map drops uint {amount: uint, start: uint, end: uint})
(define-map user-claims {user: principal, drop-id: uint} bool)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-DROP-NOT-FOUND (err u1))
(define-constant ERR-NOT-ELIGIBLE (err u2))
(define-constant ERR-USER-NOT-EVALUATED (err u3))
(define-constant ERR-ALREADY-CLAIMED (err u4))
(define-constant ERR-DROP-NOT-STARTED (err u5))
(define-constant ERR-DROP-ENDED (err u6))
(define-constant ERR-TRANSFER-FAILED (err u7))
(define-constant ERR-UNAUTHORIZED (err u8))

;; Helper function to check NFT ownership (placeholder implementation)
(define-private (check-nft-ownership (user principal))
  ;; This is a placeholder - in a real implementation, you would check
  ;; if the user owns a specific NFT contract
  ;; For now, we'll return true for demonstration
  true)

;; Helper function to get transaction count (placeholder implementation)
(define-private (get-tx-count (user principal))
  ;; This is a placeholder - in a real implementation, you would
  ;; query the user's transaction history or maintain a counter
  ;; For now, we'll return a default value of 10 for demonstration
  u10)

;; Public function to evaluate user eligibility
(define-public (evaluate-user (user principal))
  (let ((nft-held (check-nft-ownership user)) 
        (txs (get-tx-count user)))
    (map-set eligibility user {
      nft-held: nft-held, 
      tx-count: txs, 
      eligible: (and nft-held (>= txs u5))
    })
    (ok (get eligible (unwrap-panic (map-get? eligibility user))))))

;; Public function to claim airdrop
(define-public (claim-drop (drop-id uint))
  (let ((drop-data (map-get? drops drop-id)) 
        (user-eligibility (map-get? eligibility tx-sender))
        (already-claimed (default-to false (map-get? user-claims {user: tx-sender, drop-id: drop-id})))
        (current-block stacks-block-height))
    
    ;; Check if drop exists
    (asserts! (is-some drop-data) ERR-DROP-NOT-FOUND)
    
    ;; Check if user has been evaluated
    (asserts! (is-some user-eligibility) ERR-USER-NOT-EVALUATED)
    
    ;; Check if user hasn't already claimed this drop
    (asserts! (not already-claimed) ERR-ALREADY-CLAIMED)
    
    ;; Check if user is eligible
    (asserts! (get eligible (unwrap-panic user-eligibility)) ERR-NOT-ELIGIBLE)
    
    ;; Time-based validation
    (let ((drop (unwrap-panic drop-data)))
      (asserts! (>= current-block (get start drop)) ERR-DROP-NOT-STARTED)
      (asserts! (<= current-block (get end drop)) ERR-DROP-ENDED)
      
      ;; Record the claim
      (map-set user-claims {user: tx-sender, drop-id: drop-id} true)
      
      ;; Transfer tokens from contract to user
      (match (as-contract (stx-transfer? (get amount drop) (as-contract tx-sender) tx-sender))
        success (ok true)
        error ERR-TRANSFER-FAILED))))

;; Admin function to create a new drop
(define-public (create-drop (drop-id uint) (amount uint) (start uint) (end uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (map-set drops drop-id {amount: amount, start: start, end: end})
    (ok drop-id)))

;; Read-only function to check if user has claimed a specific drop
(define-read-only (has-claimed (user principal) (drop-id uint))
  (default-to false (map-get? user-claims {user: user, drop-id: drop-id})))

;; Read-only function to get drop information
(define-read-only (get-drop-info (drop-id uint))
  (map-get? drops drop-id))

;; Read-only function to get user eligibility
(define-read-only (get-user-eligibility (user principal))
  (map-get? eligibility user))