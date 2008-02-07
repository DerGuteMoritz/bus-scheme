;; Fibonacci sequence
(define fib (lambda (x)
	      (if (< x 2) 1
		  (+ (fib (- x 1))
		     (fib (- x 2))))))