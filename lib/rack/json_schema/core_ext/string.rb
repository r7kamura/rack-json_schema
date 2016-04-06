class String
  # @return [Boolean] whether or not string is integer
  def is_integer?
    self.to_i.to_s == self
  end

  # @return [Boolean] whether or not string is float
  def is_float?
    self.to_f.to_s == self
  end
end