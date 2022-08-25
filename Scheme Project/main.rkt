; sude konyalioglu
; 2019400204
; compiling: yes
; complete: no

#lang racket

(provide (all-defined-out))

; 10 points
(define := (lambda (var value) (list var value)))

; 10 points
(define -- (lambda args (cons 'let (list args))))

  
; 10 points
(define @ (lambda (bindings expr) (list (car bindings) (car (cdr bindings))(car expr))))

; 20 points
(define split_at_delim (lambda (delim args)
                         (define (helper args)
                           (if (or (empty? args) (equal? (car args) delim))
                               '()
                               (cons (car args) (helper (cdr args)))))
                         (let loop ((next args))
                           (if (empty? next)
                               '()
                               (let ((current (helper next)))
                                 (cons
                                  current
                                  (loop (let ((nxt (+ 1 (length current))))
                                          (if (< nxt (length next))
                                              (list-tail next nxt)
                                              '()))))))))
)
                                                                                  
                                             

