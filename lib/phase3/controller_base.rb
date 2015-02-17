require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      contents = File.read("views/#{self.class.inspect.underscore}/#{template_name.to_s.underscore}.html.erb")
      erb_contents = ERB.new(contents).result(binding)
      render_content(erb_contents, "text/html")
    end
  end
end
