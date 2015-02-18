module Phase6

  class Route
    attr_reader :pattern, :http_method, :controller_class, :action_name

    def initialize(pattern, http_method, controller_class, action_name)
      @pattern = pattern.is_a?(Regexp) ? pattern : Regexp.new(pattern.to_s)
      @http_method = http_method.to_s
      @controller_class = controller_class
      @action_name = action_name
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      req.path.match(pattern).is_a?(MatchData) &&
      http_method == req.request_method.downcase
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      route_params = {}
      route_match = @pattern.match(req.path)

      route_params_keys = route_match.names

      route_params_keys.each do |key|
        route_params[key] = route_match[key].to_i
      end


      b = controller_class.new(req, res, route_params)
      b.invoke_action(action_name)
    end
  end

  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    # evaluate the proc in the context of the instance
    # for syntactic sugar :)
    def draw(&proc)
      self.instance_eval(&proc)
    end

    # make each of these methods that
    # when called add route
    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |*arg|
        add_route(arg[0], http_method, arg[1], arg[2])
      end
    end

    # should return the route that matches this request
    def match(req)
      match = nil
      @routes.each { |route| match = route if route.matches?(req) }
      match
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      # p match(req)
      route = match(req)
      if route
        route.run(req, res)
      else
        res.status = 404
      end
    end
  end
end
