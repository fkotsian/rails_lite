require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params ||= {}
    parse_www_encoded_form(req.query_string)
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    return if www_encoded_form.nil?
    pairs = URI.decode_www_form(www_encoded_form)
    p pairs
    pairs.each do |pair|
      key = pair.first
      val = pair.last

      split_keys = parse_key(key)
      build_params(split_keys, val)
    end
  end

  def build_params(split_keys, val)
    return if split_keys.nil? || split_keys.empty?
    key = split_keys
    res = {}
    if split_keys.length == 1
      @params[key] = val
    else
      @params[key] = build_params(split_keys[1..-1], val)
    end
    # p @params
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    if key.include?('[') || key.include?(']')
      key.delete(']').split('[')
    else
      key
    end
  end
end
