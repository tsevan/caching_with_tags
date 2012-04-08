class Railtie < ::Rails::Railtie
  initializer 'caching_with_tags.on_rails_init' do
    ActiveSupport.on_load :before_configuration do
      ActiveSupport.send :include, CachingWithTags::StoreMethods
      ActiveSupport.send :include, CachingWithTags::EntryMethods
    end
  end
end
