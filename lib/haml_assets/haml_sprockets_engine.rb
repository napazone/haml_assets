require 'haml'
require 'tilt'

module HamlAssets
  class HamlSprocketsEngine < Tilt::Template
    attr_accessor :locals

    def self.default_mime_type
      'application/javascript'
    end

    class ViewContext
      include Rails.application.routes.url_helpers
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers

      attr_accessor :output_buffer

      def protect_against_forgery?
        false
      end
    end

    def evaluate(scope, locals, &block)
      self.locals = locals

      begin
        "" + render_haml
      rescue Exception => e
        Rails.logger.debug "ERROR: compiling #{file} RAISED #{e}"
        Rails.logger.debug "Backtrace: #{e.backtrace.join("\n")}"
      end
    end

    protected

    def prepare; end

    def render_haml
      Haml::Engine.new(data, Haml::Template.options.merge(:escape_attrs => false)).render(scope, locals)
    end

    def scope
      @scope ||= ViewContext.new
    end
  end
end
