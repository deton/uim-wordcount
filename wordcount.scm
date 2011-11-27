;;; word counter on selection or clipboard.

(require-extension (srfi 1 2 8))

(define wordcount-selection-key? (make-key-predicate '("s")))
(define wordcount-clipboard-key? (make-key-predicate '("v")))
(define wordcount-line-key? (make-key-predicate '("l")))
(define wordcount-word-key? (make-key-predicate '("w")))
(define wordcount-char-key? (make-key-predicate '("c")))
(define wordcount-byte-key? (make-key-predicate '("b")))

;; widgets and actions

;; widgets
(define wordcount-widgets '(widget_wordcount_input_mode))

;; default activity for each widgets
(define default-widget_wordcount_input_mode 'action_wordcount_on)

;; actions of widget_wordcount_input_mode
(define wordcount-input-mode-actions
  '(action_wordcount_on))

;;; implementations

(register-action 'action_wordcount_on
                 (lambda (pc)
                   '(unknown
                     "W"
                     "wordcount"
                     "word count on selection"))
                 (lambda (pc) #t)
                 #f)  ;; no action handler

;; Update widget definitions based on action configurations. The
;; procedure is needed for on-the-fly reconfiguration involving the
;; custom API
(define wordcount-configure-widgets
  (lambda ()
    (register-widget 'widget_wordcount_input_mode
                     (activity-indicator-new wordcount-input-mode-actions)
                     (actions-new wordcount-input-mode-actions))))

(define wordcount-context-rec-spec
  (append
    context-rec-spec
    (list
      (list 'line "")
      (list 'word "")
      (list 'char "")
      (list 'byte ""))))

(define-record 'wordcount-context wordcount-context-rec-spec)
(define wordcount-context-new-internal wordcount-context-new)

(define wordcount-context-new
  (lambda args
    (let ((pc (apply wordcount-context-new-internal args)))
      (wordcount-context-set-widgets! pc wordcount-widgets)
      pc)))

(define wordcount-init-handler
  (lambda (id im arg)
    (let ((pc (wordcount-context-new id im)))
      pc)))

(define (wordcount-release-handler pc)
  (im-deactivate-candidate-selector pc))

(define (wordcount-key-press-handler pc key key-state)
  (if (ichar-control? key)
    (im-commit-raw pc)
    (cond
      ((wordcount-selection-key? key key-state)
        (wordcount-on-selection pc))
      ((wordcount-clipboard-key? key key-state)
        (wordcount-on-clipboard pc))
      ((wordcount-line-key? key key-state)
        (im-commit pc (wordcount-context-line pc)))
      ((wordcount-word-key? key key-state)
        (im-commit pc (wordcount-context-word pc)))
      ((wordcount-char-key? key key-state)
        (im-commit pc (wordcount-context-char pc)))
      ((wordcount-byte-key? key key-state)
        (im-commit pc (wordcount-context-byte pc)))
      (else
        (im-commit-raw pc)))))

(define (wordcount-key-release-handler pc key state)
  (im-commit-raw pc))

(define (wordcount-get-candidate-handler pc idx accel-enum-hint)
  (case idx
    ((0) (list (wordcount-context-line pc) "line" ""))
    ((1) (list (wordcount-context-word pc) "word" ""))
    ((2) (list (wordcount-context-char pc) "char" ""))
    ((3) (list (wordcount-context-byte pc) "byte" ""))
    ((4) (list "s:selection" "s" ""))
    ((5) (list "v:clipboard" "v" ""))))

(define (wordcount-set-candidate-index-handler pc idx)
  (case idx
    ((0) (im-commit pc (wordcount-context-line pc)))
    ((1) (im-commit pc (wordcount-context-word pc)))
    ((2) (im-commit pc (wordcount-context-char pc)))
    ((3) (im-commit pc (wordcount-context-byte pc)))
    ((4) (wordcount-on-selection pc))
    ((5) (wordcount-on-clipboard pc))))

(define (wordcount-focus-in-handler pc)
  (wordcount-on-selection pc))

(wordcount-configure-widgets)

(register-im
 'wordcount
 ""
 "UTF-8"
 (N_ "wordcount")
 (N_ "word counter")
 #f
 wordcount-init-handler
 wordcount-release-handler
 context-mode-handler
 wordcount-key-press-handler
 wordcount-key-release-handler
 #f
 wordcount-get-candidate-handler
 wordcount-set-candidate-index-handler
 context-prop-activate-handler
 #f
 wordcount-focus-in-handler
 #f
 #f
 #f
 )

(define (wordcount-acquire-text pc id)
  (and-let*
    ((ustr (im-acquire-text pc id 'beginning 0 'full))
     (latter (ustr-latter-seq ustr)))
    (and (pair? latter)
         (car latter))))

(define (wordcount-on-selection pc)
  (let ((str (wordcount-acquire-text pc 'selection)))
    (wordcount-on-str pc
      (if (string? str)
        str
        ""))))

(define (wordcount-on-clipboard pc)
  (let ((str (wordcount-acquire-text pc 'clipboard)))
    (wordcount-on-str pc
      (if (string? str)
        str
        ""))))

(define (wordcount-on-str pc str)
  (wordcount-context-set-line! pc (number->string (wordcount-count-line str)))
  (wordcount-context-set-word! pc (number->string (wordcount-count-word str)))
  (wordcount-context-set-char! pc (number->string (wordcount-count-char str)))
  (wordcount-context-set-byte! pc (number->string (wordcount-count-byte str)))
  (im-activate-candidate-selector pc 6 6)
  (im-select-candidate pc 0))

(define (wordcount-count-line str)
  (string-count str #\newline))

;;; Limited version of SRFI-13 string-count.
(define (string-count str char)
  (count (lambda (c) (char=? c char)) (string->list str)))

(define (wordcount-count-word str)
  (define (graphic? c)
    (let ((i (char->integer c)))
      (or (ichar-graphic? i)
          (>= i 128)))) ; TODO: exclude whitespace in UTF-8
  (let loop
    ((lis (string->list str))
     (count 0))
    (if (null? lis)
      count
      (receive (word rest) (span graphic? lis)
        (if (null? word)
          (loop (drop-while (lambda (c) (not (graphic? c))) lis) count)
          (loop rest (+ count 1)))))))

(define (wordcount-count-char str)
  (with-char-codec "UTF-8"
    (lambda ()
      (let ((u8str (string-copy str)))
        (string-length (%%string-reconstruct! u8str))))))

(define (wordcount-count-byte str)
  (string-length str))
