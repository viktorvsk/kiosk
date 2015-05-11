# -*- encoding: utf-8 -*-
# stub: file_browser 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "file_browser"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Eric Anderson"]
  s.date = "2013-12-30"
  s.description = "    Provides a web-based UI to manage a filesystem. Useful as an\n    alternative to FTP and also to integrate with products such\n    as CKEditor.\n"
  s.email = "eric@pixelwareinc.com"
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc"]
  s.homepage = "http://wiki.github.com/eric1234/file_browser/"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.rubygems_version = "2.4.5"
  s.summary = "A Rails-gem for managing files"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 4.0.0"])
    else
      s.add_dependency(%q<rails>, [">= 4.0.0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 4.0.0"])
  end
end
