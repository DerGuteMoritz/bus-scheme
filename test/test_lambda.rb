$LOAD_PATH << File.dirname(__FILE__)
require 'test_helper'

class BusScheme::Lambda
  attr_accessor :body, :formals, :environment
end

class BusSchemeLambdaTest < Test::Unit::TestCase
  def test_simple_lambda
    l = eval("(lambda () (+ 1 1))")
    assert l.is_a?(Lambda)
    assert_equal [[:+, 1, 1]], l.body
    assert_equal [], l.formals

    eval("(define foo (lambda () (+ 1 1)))")
    assert Lambda.scope[:foo].is_a?(Lambda)
    assert_evals_to 2, [:foo]
  end

  def test_lambda_with_arg
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_evals_to 2, [:foo, 1]
  end

  def test_eval_literal_lambda
    assert_evals_to 4, "((lambda (x) (* x x)) 2)"
  end

  def test_lambda_with_incorrect_arity
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_raises(ArgumentError) { assert_evals_to 2, [:foo, 1, 3] }
  end

  def test_lambda_args_dont_stay_in_scope
    clear_symbols(:x, :foo)
    eval("(define foo (lambda (x) (+ x 1)))")
    assert_nil Lambda.scope[:x]
    assert_evals_to 2, [:foo, 1]
    assert_nil Lambda.scope[:x]
  end

  def test_lambda_calls_lambda
    eval "(define f (lambda (x) (+ 3 x)))"
    eval "(define g (lambda (y) (* 3 y)))"
    assert_evals_to 12, "(f (g 3))"
  end

  def test_lambda_closures
    eval "(define foo (lambda (x) ((lambda (y) (+ x y)) (* x 2))))"
    assert_evals_to 3, [:foo, 1]
    eval "(define holder ((lambda (x) (lambda () x)) 2))"
    assert_evals_to 2, "(holder)"
  end

  def test_changes_to_enclosed_variables_are_in_effect_after_lambda_execution
    assert_evals_to 2, "((lambda (x) (begin ((lambda () (set! x 2))) x)) 1)"
  end

  def test_implicit_begin
    assert_evals_to 3, "((lambda () (intern \"hi\") (+ 2 2) (* 1 3)))"
  end

  def test_shadowed_vars_dont_stay_in_scope
    assert_evals_to Cons.new(:a, :b), "(let ((f (let ((x (quote a)))
          (lambda (y) (cons x y)))))
 (let ((x (quote not-a)))
  (f (quote b))))"
  end

  def test_lambda_rest_args
    eval "(define rest (lambda args args))"
    assert_evals_to [:a, :b, :c].to_list, "(rest 'a 'b 'c)"
  end

  def test_lambdas_know_what_file_they_were_defined_in
    filename = File.expand_path("#{File.dirname(__FILE__)}/../examples/fib.scm")
    eval "(load \"#{filename}\")"
    assert_equal filename, Lambda.scope[:fib].defined_in.first
  end

#   def test_lambdas_know_what_line_they_were_defined_in
#     filename = File.expand_path("#{File.dirname(__FILE__)}/../examples/fib.scm")
#     eval "(load \"#{filename}\")"
#     assert_equal 1, Lambda.scope[:fib].defined_in.last
#   end
end
