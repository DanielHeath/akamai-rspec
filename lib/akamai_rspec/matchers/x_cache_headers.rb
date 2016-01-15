require 'rspec'

module AkamaiRSpec
  module Helpers
    X_CACHE_HEADERS = [:x_true_cache_key, :x_cache_key]

    def have_matching_x_cache_headers(url, contents, match_fn)
      response = RestClient::Request.responsify url
      has_x_cache_headers(response)
      return false unless x_cache_headers_match(response, contents, match_fn)
      response.code == 200
    end

    def x_cache_headers_match(response, contents, match_fn)
      X_CACHE_HEADERS.each do |key|
        return true if response.headers[key] && match_fn.call(response.headers[key], contents)
      end
      false
    end

    def has_x_cache_headers(response)
      response.headers.keys.any? { |h| X_CACHE_HEADERS.include?(h) }
    end
  end
end


RSpec::Matchers.define :be_served_from_origin do |contents|
  include AkamaiRSpec::Helpers
  match do |url|
    match_fn = lambda { |header, expected| header && header =~ /\/#{expected}\// }
    have_matching_x_cache_headers(url, contents, match_fn)
  end
end

RSpec::Matchers.define :have_cp_code do |contents|
  include AkamaiRSpec::Helpers
  match do |url|
    match_fn = lambda { |header, expected| header.include?(expected) }
    have_matching_x_cache_headers(url, contents, match_fn)
  end
end
