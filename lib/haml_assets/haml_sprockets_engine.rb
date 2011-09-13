require 'haml'
require 'tilt'

module HamlAssets
  class HamlSprocketsEngine < Tilt::Template
    def self.default_mime_type
      'application/javascript'
    end

    module ViewContext
      include Rails.application.routes.url_helpers
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers

      attr_accessor :output_buffer

      def protect_against_forgery?
        false
      end
    end

    def evaluate(scope, locals, &block)
      begin
        "" + render_haml(view_context(scope), locals)
      rescue Exception => e
        Rails.logger.debug "ERROR: compiling #{file} RAISED #{e}"
        Rails.logger.debug "Backtrace: #{e.backtrace.join("\n")}"
      end
    end

    protected

    def context_class(scope)
      @context_class ||= Class.new(scope.environment.context_class)
    end

    def prepare; end

    def render_haml(context, locals)
      Haml::Engine.new(data, Haml::Template.options.merge(:escape_attrs => false)).render(context, locals)
    end

    # The Sprockets context is shared among all the processors, give haml its
    # own context
    def view_context(scope)
      @view_context ||=
        context_class(scope).new(
          scope.environment,
          scope.logical_path.to_s,
          scope.pathname).tap { |ctx| ctx.class.send(:include, ViewContext) }
    end
  end
end
