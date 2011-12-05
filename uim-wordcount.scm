(require "wordcount.scm")
(define (read-input res)
  (let ((ch (read-char)))
    (if (eof-object? ch)
      res
      (read-input (cons ch res)))))

(define (main args)
  (let ((str (list->string (reverse (read-input '())))))
    (display
      (format "~a ~a ~a ~a\n"
        (number->string (wordcount-count-line str))
        (number->string (wordcount-count-word str))
        (number->string (wordcount-count-char str))
        (number->string (wordcount-count-byte str))))))
