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
        queries = req.query_string.split("&")
        queries.each do |query|
          query_hash = parse_www_encoded_form(query)
          @params.merge!(query_hash)
        end

      end

      if req.body
        queries = req.body.split("&")
        queries.each do |query|
          query_hash = parse_www_encoded_form(query)
          @params.merge!(query_hash)
        end
      end

      # @params
    end

    def [](key)
      @params[key]
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
      parsed = {}

      pair = www_encoded_form.split("=")

      p pair

      p parse_key(pair[0])

      parsed[pair[0]] = pair[1]

      parsed
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
