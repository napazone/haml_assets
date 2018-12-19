require 'spec_helper'

describe HamlAssets do
  it "should have the proper format" do
    expect(RailsApp::Application.assets['link_to.jst.ejs.haml'].to_s).to eq("(function() { this.JST || (this.JST = {}); this.JST[\"link_to\"] = function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('');}return __p.join('');};\n}).call(this);\n")
  end

  context 'rendering' do
    let(:path) { 'app/assets/templates/quotes.haml' }

    context "quoted attributes" do
      after { Haml::Template.options[:attr_wrapper] = "'" }

      it "handles data attributes" do
        template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'.html_safe}}) }
        expect(template.send(:evaluate, Object.new, {}).strip).to eq(%Q(<div data-bind='attr: { "data-something": someValue }'></div>))
      end

      it "does not allow nested quotes with ()" do
        template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div(ng-model-options='{updateOn: "blur"}')| }
        expect(template.send(:evaluate, Object.new, {}).strip).to eq(%Q(<div ng-model-options='{updateOn: &quot;blur&quot;}'></div>))
      end

      it "allows nested quotes with {}" do
        template = HamlAssets::HamlSprocketsEngine.new(path, 1, {attr_wrapper: '"'}) { %Q|%div{"ng-model-options" => "{updateOn: 'blur'}".html_safe}| }
        expect(template.send(:evaluate, Object.new, {}).strip).to eq(%Q(<div ng-model-options="{updateOn: 'blur'}"></div>))
      end

      it "allows nested quote with {} ('\"\"')" do
        template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div{"ng-model-options" => '{updateOn: "blur"}'.html_safe}| }
        expect(template.send(:evaluate, Object.new, {}).strip).to eq(%Q(<div ng-model-options='{updateOn: "blur"}'></div>))
      end
    end

    it "renders with a partial" do
      template = HamlAssets::HamlSprocketsEngine.new('app/assets/templates/with_partial.haml') { %Q(%div= render 'partial') }
      partial = double(formats: [], identifier: 'identifier', render: 'partial', virtual_path: '')

      expect_any_instance_of(HamlAssets::HamlSprocketsEngine::LookupContext).to receive(:find_template).and_return(partial)

      context = Class.new do
        include HamlAssets::HamlSprocketsEngine::ViewContext
      end.new

      expect(context).to receive(:environment_paths).and_return([])

      expect(template.send(:evaluate, context, {}).strip).to eq(%Q(<div>partial</div>))
    end
  end

  context 'rendering from app/views' do
    class Context
      include HamlAssets::HamlSprocketsEngine::ViewContext

      attr_accessor :environment
    end

    let(:context) { Context.new }
    let(:environment) { double(paths: paths) }
    let(:paths) { ['path1', 'path2' ] }

    before { context.environment = environment }

    after { HamlAssets::Config.look_in_app_views = false }

    it 'when not on, just uses the environment paths to find templates' do
      HamlAssets::Config.look_in_app_views = false
      expect(context.environment_paths).to eq(paths)
    end

    it 'when on, adds app/views to the environment paths to find templates' do
      HamlAssets::Config.look_in_app_views = true
      expect(context.environment_paths).to eq(paths + [(Rails.root + 'app/views').to_s])
    end
  end
end
