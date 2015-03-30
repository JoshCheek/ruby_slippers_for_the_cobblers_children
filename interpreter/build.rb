# Docs for this file: https://docs.npmjs.com/files/package.json
package_json = {
  private: true, # npm won't publish this
  name:    "ruby_slippers_for_the_cobblers_children",
  scripts: {
    test: "gulp test"
  },
  devDependencies: {
    gulp:  "~3.8",
    babel: "~4.7",
    mocha: "~2.2",
  },
}

module FILES
  ROOT = File.expand_path '..', __FILE__
  PACKAGE_JSON = File.join ROOT, 'package.json'
end

require 'json'
File.write FILES::PACKAGE_JSON, JSON.dump(package_json)
