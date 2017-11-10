class Hash
  def self.zip(keys,values) # from Facets of Ruby library, CREDIT: Trans, Ara T. Howard
    h = {}
    keys.size.times{ |i| h[ keys[i] ] = values[i] }
    h
  end
end
