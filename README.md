# Haml for JavaScript templates with the asset pipeline

Writing JavaScript templates for Backbone.js (or other frameworks) in your app?
Would you like to use `haml` in the asset pipeline?

This gem adds `haml` support to the Rails 3.1+ asset pipeline. You will also
need a gem that creates a compiled JavaScript template like `hogan_assets` or
`handlebars_assets` as well.

## Installing

Add this to your `Gemfile`

    gem 'haml_assets'

### Upgrading from 0.0.x

`haml_assets` now works with the `haml` gem. Please update your gemfile to only
require `haml_assets.`.

## Writing your JavaScript templates

### Templates directory

You should located your templates under `app/assets`; we suggest
`app/assets/templates`. In your JavaScript manifest file (for example
`application.js`), use `require_tree`

    //= require_tree ../templates

### The template file

Inside your templates directory, add your template file. The file should be
named as follows

    your_template_name.mustache.haml

The asset pipeline will then generate the actual JavaScript asset

1. Convert your haml to HTML
1. Compile the HTML to an mustache Javascript template using `hogan_assets`

**Important!** The asset pipeline is not invoking a controller to generate the
templates. If you are using existing view templates, you may have to edit
templates to remove some references to controller helpers.

### Helpers

All the `ActionView` and route helpers are available in your template. If you use
`form_for` and the related helpers, you should use the *new* object style, even
if you are writing an *edit* template, for example

    = form_for :contact, url: "javascript_not_working", html: {:class => :edit_contact, :method => :put} do |f|
      = f.label :name, "Name"
      = f.text_field :name, class: 'text required', autofocus: true, value: '{{name}}'

## TODO

Make `render` available, so you can render a partial.

## Contributing

Once you've made your great commits:

1. Fork
1. Create a topic branch - git checkout -b my_branch
1. Push to your branch - git push origin my_branch
1. Create a Pull Request from your branch
1. That's it!

## Authors

* Les Hill  : @leshill
* Wes Gibbs : @wgibbs
