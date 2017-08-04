require 'haml'
require 'tilt'

module HamlAssets
  class HamlSprocketsEngine < Tilt::HamlTemplate
    self.default_mime_type = 'application/javascript'

    class LookupContext < ActionView::LookupContext
      def initialize(haml_context, path)
        super(path)
        @view_context = haml_context
      end

      def find_template(*args)
        super.tap do |r|
          @view_context.depend_on(r.identifier)
        end
      end
    end

    module ViewContext
      attr_accessor :output_buffer, :_view_renderer, :_lookup_context

      def view_renderer
        @_view_renderer ||= ActionView::Renderer.new(lookup_context)
      end

      def environment_paths
        paths = environment.paths.to_a
        paths += [(Rails.root + 'app/views').to_s] if HamlAssets::Config.look_in_app_views
        paths
      end

      def lookup_context
        @_lookup_context ||= LookupContext.new(self, environment_paths)
      end

      def output_buffer_with_haml
        return haml_buffer.buffer if is_haml?
        output_buffer_without_haml
      end

      def set_output_buffer_with_haml(new)
        if is_haml?
          new = String.new(new) if Haml::Util.rails_xss_safe? &&
            new.is_a?(ActiveSupport::SafeBuffer)
          haml_buffer.buffer = new
        else
          set_output_buffer_without_haml new
        end
      end

      def self.included(klass)
        klass.instance_eval do
          include Rails.application.routes.url_helpers
          include Rails.application.routes.mounted_helpers
          include ActionView::Helpers

          alias_method :output_buffer_without_haml, :output_buffer
          alias_method :output_buffer, :output_buffer_with_haml

          alias_method :set_output_buffer_without_haml, :output_buffer=
          alias_method :output_buffer=, :set_output_buffer_with_haml
        end
      end

      def protect_against_forgery?
        false
      end
    end

    def prepare
      if HamlAssets::Config.haml_options
        @options = @options.merge(HamlAssets::Config.haml_options)
      end
      super
    end

    def evaluate(scope, locals, &block)
      scope = view_context(scope)
      super
    end

    protected

    def view_context(scope)
      @view_context ||= scope.tap do |s|
        s.singleton_class.instance_eval { include HamlAssets::HamlSprocketsEngine::ViewContext }
      end
    end
  end
end
