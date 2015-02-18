require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}

      if req.query_string
          query_hash = parse_www_encoded_form(req.query_string)
          @params.merge!(query_hash)
      end

      if req.body
        query_hash = parse_www_encoded_form(req.body)
        @params.merge!(query_hash)
      end

      @params.merge!(route_params)
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      params = {}

      pairs = www_encoded_form.split("&")
      # p pairs

      pairs.each do |pair|
        hash = params
        pair = pair.split("=")
        value = pair[1]

        keys = parse_key(pair[0])

        keys.each do |key|
          if hash[key].nil? && key != keys.last

            hash[key] = {}
            hash = hash[key]
          elsif hash[key].is_a?(Hash)
            hash = hash[key]
          else
            hash[key] = value
          end
        end
      end

      params
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
