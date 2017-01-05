require_relative './lib/version'

# rubocop:disable Metrics/BlockLength
Pod::Spec.new do |spec|
  spec.name = 'AtlasUI'
  spec.platform = :ios, '9.0'
  spec.version = ATLAS_VERSION
  spec.summary = 'Full UI for Zalando Checkout and Catalog APIs.'
  spec.homepage = 'https://github.com/zalando-incubator/atlas-ios'

  spec.description = <<-DESC
The purpose of this project is to provide seamless experience of Zalando
articles checkout integration to the 3rd party iOS apps.

Our goal is to allow end developer integrate and run Zalando checkout in
minutes using a few lines of code. There is an AtlasCheckout framework in place
to have end-to-end solution including UI part for the checkout flow.

If you want to have a full control over the UI and manage checkout flow by
yourself there is a low-level AtlasSDK framework that covers all Checkout API
calls and provide you high-level business objects to deal with.
  DESC

  spec.license = {
    type: 'MIT',
    file: 'LICENSE'
  }

  spec.authors = {
    'Ahmed Shehata' => 'ahmed.shehata@zalando.de',
    'Daniel Bauke' => 'daniel.bauke@zalando.de',
    'Gleb Galkin' => 'gleb.galkin@zalando.de',
    'Haldun Bayhantopcu' => 'haldun.bayhantopcu@zalando.de',
    'Hani Ibrahim' => 'hani.eloksh@zalando.de'
  }

  spec.source = {
    git: 'https://github.com/zalando-incubator/atlas-ios.git',
    tag: spec.version.to_s
  }

  spec.source_files = 'AtlasUI/AtlasUI/**/*.swift', \
                      'AtlasSDK/AtlasSDK/Extensions/StringOperators.swift', \
                      'AtlasSDK/AtlasSDK/Extensions/Debug.swift'
  spec.ios.resources = ['AtlasUI/AtlasUI/**/*.xcassets', 'AtlasUI/AtlasUI/**/Localizable.strings']
  spec.ios.frameworks = 'Foundation', 'UIKit'

  spec.dependency 'AtlasSDK', "= #{spec.version}"
end
