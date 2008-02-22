class Array
  # Lisp-style list access
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest

  def to_list
    car = self.car
    # TODO: make this car-recursive?
    # car = car.to_list if car.respond_to?(:to_list)

    if self.cdr.nil? or self.cdr.empty?
      BusScheme::Cons.new(car, nil)
    else
      BusScheme::Cons.new(car, self.cdr.to_list)
    end
  end

  alias_method :sexp, :to_list
  include Callable
end

module Enumerable # for 1.9, zip is defined on Enumerable
  def to_hash
    {}.affect do |hash|
      self.each { |pair| hash[pair.first] = pair.last }
    end
  end
end
