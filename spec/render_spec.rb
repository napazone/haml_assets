require 'spec_helper'

describe HamlAssets do

  it "should have the proper format" do
    RailsApp::Application.assets['link_to.jst.ejs.haml'].to_s.should == "(function() {\n  this.JST || (this.JST = {});\n  this.JST[\"link_to\"] = function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('');}return __p.join('');};\n}).call(this);\n"
  end

  context 'rendering' do
    let(:path) { 'app/assets/templates/quotes.haml' }

    it "quoted attributes" do
      template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'}}) }
      template.send(:render_haml, Object.new, {}).strip.should eq(%Q(<div data-bind='attr: { "data-something": someValue }'></div>))
    end

    it "renders with a partial" do
      template = HamlAssets::HamlSprocketsEngine.new('app/assets/templates/with_partial.haml') { %Q(%div= render 'partial') }
      partial = stub(identifier: 'identifier', render: 'partial')

      HamlAssets::HamlSprocketsEngine::LookupContext.any_instance.should_receive(:find_template).and_return(partial)

      context = Class.new do
        include HamlAssets::HamlSprocketsEngine::ViewContext
      end.new

      context.stub(environment_paths: [])

      template.send(:render_haml, context, {}).strip.should eq(%Q(<div>partial</div>))
    end
  end

  context 'rendering from app/views' do

    class Context
      include HamlAssets::HamlSprocketsEngine::ViewContext

      attr_accessor :environment
    end

    let(:context) { Context.new }
    let(:environment) { stub :environment, paths: paths }
    let(:paths) { ['path1', 'path2' ] }

    before { context.environment = environment }

    after { HamlAssets::Config.look_in_app_views = false }

    it 'when not on, just uses the environment paths to find templates' do
      HamlAssets::Config.look_in_app_views = false
      context.environment_paths.should eq(paths)
    end

    it 'when on, adds app/views to the environment paths to find templates' do
      HamlAssets::Config.look_in_app_views = true
      context.environment_paths.should eq(paths + [(Rails.root + 'app/views').to_s])
    end
  end
end
