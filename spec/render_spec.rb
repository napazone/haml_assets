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
  end
end
