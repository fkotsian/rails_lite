require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params ||= {}
    @permitted_keys = []
    self.parse_www_encoded_form(req.query_string)
    self.parse_www_encoded_form(req.body)
    p @params
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
    @permitted_keys += keys
    @params.dup.select { |k,v| @permitted_keys.include?(v) }
  end

  def require(key)
    raise AttributeNotFoundError if !@params.include?(key)
    @params.dup.select { |k, v| k == key }
  end

  def permitted?(key)
    @permitted_keys.include?(key)
  end

  def to_s
    @params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  # private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?

    queries = URI.decode_www_form(www_encoded_form)
    split_queries = queries.map do |keys, val|
      [parse_keys(keys), val]
    end

    hashed_queries = split_queries.map do |query|
      keys = query.first
      val  = query.last

      keys.reverse.inject(val) { |res, el| { el => res } }
    end

    hashed_queries.each do |hash_query|
      @params.deep_merge(hash_query)
    end

    @params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_keys(keys)
    if keys.include?('[') || keys.include?(']')
      keys.delete(']').split('[')
    else
      [keys]
    end
  end
end


class Hash
  def deep_merge(new_h)
    old_h = self
    key = new_h.keys.each do |key|

      #old hash and new hash have key
      #deep_merge the next levels of each
      #only new hash has key
      #old[key] = new[key]
      if old_h.is_a?(Hash) && old_h.has_key?(key) &&
         new_h.is_a?(Hash) && new_h.has_key?(key)
         old_h[key].deep_merge(new_h[key])
      elsif !old_h.has_key?(key) && new_h.has_key?(key)
         old_h[key] = new_h[key]
      elsif old_h.has_key?(key) && !new_h.has_key?(key)
        new_h[key] = old_h[key]
      end
    end
  end
end