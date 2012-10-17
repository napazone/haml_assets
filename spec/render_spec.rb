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

  context 'evaluating' do
    let(:path) { 'app/assets/templates/invalid.haml' }

    it "does not catch errors" do
      template = HamlAssets::HamlSprocketsEngine.new(path) { %Q(%div{ %invalid }) }
      template.should_receive(:view_context).with(:scope).and_return(Object.new)
      expect do
        template.evaluate(:scope, {})
      end.to raise_error(SyntaxError)
    end
  end
end
