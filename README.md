# origen_svf

An Origen plugin to render JTAG-based patterns in
[Serial Vector Format (SVF)](http://www.jtagtest.com/pdf/svf_specification.pdf).

To use, simply add the plugin to your app's Gemfile and require in your top-level lib file:

```ruby
# Gemfile
gem 'origen_svf'

# lib/my_app.rb
require 'origen_svf'
```

and then create an environment file for SVF:

```ruby
# environment/svf.rb
OrigenSVF::Tester.new
```

Use this environment to render your patterns in .svf format:

```text
origen g my_pattern -e svf
```

### Customizing the Output for SVF

This plugin will extend the OrigenTesters API to add a .svf? method to all testers, allowing you to do this in your code:

```ruby
unless tester.svf?
  # Something not suitable for SVF output
end
```

A common use case may be to customize the pin list:

```ruby
if tester.svf?
  # Only include these pin in .svf files
  pin_pattern_order :rstn, :trstn, :done, :fail, only: true
else
  # Full pin list
end
```




