require 'spec_helper'

describe HamlAssets do

  it "should have the proper format" do
    RailsApp::Application.assets['link_to.jst.ejs.haml'].to_s.should == "(function() { this.JST || (this.JST = {}); this.JST[\"link_to\"] = function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};with(obj||{}){__p.push('');}return __p.join('');};\n}).call(this);\n"
  end

  context 'rendering' do
    let(:path) { 'app/assets/templates/quotes.haml' }

    context "quoted attributes" do
      after { Haml::Template.options[:attr_wrapper] = "'" }

      context 'with Haml::Template.options escape_attrs and escape_html being false' do
        before do
          Haml::Template.options[:escape_attrs] = false
          Haml::Template.options[:escape_html]  = false
        end

        it "handles data attributes" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'}}) }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div data-bind='attr: { "data-something": someValue }'></div>))
        end

        it "allows nested quotes with ()" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div(ng-model-options='{updateOn: "blur"}')| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options='{updateOn: "blur"}'></div>))
        end

        it "allows nested quotes with {}" do
          Haml::Template.options[:attr_wrapper] = '"'
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div{"ng-model-options" => "{updateOn: 'blur'}"}| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options="{updateOn: 'blur'}"></div>))
        end

        it "allows nested quote with {} ('\"\"')" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div{"ng-model-options" => '{updateOn: "blur"}'}| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options='{updateOn: "blur"}'></div>))
        end
      end

      context 'with Ham::Template.options escape_attrs and escape_html being true' do
        before do
          Haml::Template.options[:escape_attrs] = true
          Haml::Template.options[:escape_html]  = true
        end

        it "handles data attributes" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'}}) }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div data-bind='attr: { &quot;data-something&quot;: someValue }'></div>))
        end

        it "allows nested quotes with ()" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div(ng-model-options='{updateOn: "blur"}')| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options='{updateOn: &quot;blur&quot;}'></div>))
        end

        it "allows nested quotes with {}" do
          Haml::Template.options[:attr_wrapper] = '"'
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div{"ng-model-options" => "{updateOn: 'blur'}"}| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options=\"{updateOn: &#39;blur&#39;}\"></div>))
        end

        it "allows nested quote with {} ('\"\"')" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q|%div{"ng-model-options" => '{updateOn: "blur"}'}| }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div ng-model-options='{updateOn: &quot;blur&quot;}'></div>))
        end
      end

      context 'with HamlAssets::Config.haml_options escape_attrs and escape_html being true' do
        before do
          HamlAssets::Config.haml_options = {
            escape_attrs: true,
            escape_html: true
          }
        end

        it "escapes interpolated code" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'}}) }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div data-bind='attr: { &quot;data-something&quot;: someValue }'></div>))
        end
      end

      context 'with HamlAssets::Config.haml_options escape_attrs and escape_html being false' do
        before do
          HamlAssets::Config.haml_options = {
            escape_attrs: false,
            escape_html: false
          }
        end

        it "does not escapes interpolated code" do
          template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{data:{bind:'attr: { "data-something": someValue }'}}) }
          template.send(:evaluate, Object.new, {}).strip.should eq(%Q(<div data-bind='attr: { "data-something": someValue }'></div>))
        end
      end
    end


    it "renders with a partial" do
      template = HamlAssets::HamlSprocketsEngine.new('app/assets/templates/with_partial.haml') { %Q(%div= render 'partial') }
      partial = stub(identifier: 'identifier', render: 'partial', formats: [])

      HamlAssets::HamlSprocketsEngine::LookupContext.any_instance.should_receive(:find_template).and_return(partial)

      context = Class.new do
        include HamlAssets::HamlSprocketsEngine::ViewContext
      end.new

      context.stub(environment_paths: [])

      template.send(:evaluate, context, {}).strip.should eq(%Q(<div>partial</div>))
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
