require 'active_support/concern'

module OrmEndpoint
  extend ActiveSupport::Concern

  protected
  def parse(fn, exception=Exception)
    begin
      send fn
    rescue exception => e

    end
  end
end
