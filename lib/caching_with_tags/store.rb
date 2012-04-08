module CachingWithTags
  module StoreMethods
    class ActiveSupport::Cache::Store
      def read(name, options = nil)
        options = merged_options(options)
        key = namespaced_key(name, options)
        instrument(:read, name, options) do |payload|
          ########patched
          entry = read_entry(key, options)
          entry = nil if entry && entry.tags && !tags_actual?(entry.tags)
          #######patch end

          if entry
            if entry.expired?
              delete_entry(key, options)
              payload[:hit] = false if payload
              nil
            else
              payload[:hit] = true if payload
              entry.value
            end
          else
            payload[:hit] = false if payload
            nil
          end
        end
      end

      def fetch(name, options = nil)
        if block_given?
          options = merged_options(options)
          key = namespaced_key(name, options)
          ########patched
          unless options[:force]
            entry = instrument(:read, name, options) do |payload|
              payload[:super_operation] = :fetch if payload
              ent = read_entry(key, options)
              ent = nil if ent && ent.tags && !tags_actual?(ent.tags)
              ent
            end
          end
          ########end of patch
          if entry && entry.expired?
            race_ttl = options[:race_condition_ttl].to_f
            if race_ttl and Time.now.to_f - entry.expires_at <= race_ttl
              entry.expires_at = Time.now + race_ttl
              write_entry(key, entry, :expires_in => race_ttl * 2)
            else
              delete_entry(key, options)
            end
            entry = nil
          end

          if entry
            instrument(:fetch_hit, name, options) { |payload| }
            entry.value
          else
            result = instrument(:generate, name, options) do |payload|
              yield
            end
            write(name, result, options)
            result
          end
        else
          read(name, options)
        end
      end

      def write(name, value, options = nil)
        options = merged_options(options)
        instrument(:write, name, options) do |payload|
          ######patch
          entry = ActiveSupport::Cache::Entry.new(value, options)
          write_meta(entry, options[:tags]) if options[:tags]
          write_entry(namespaced_key(name, options), entry, options)
          ######end of patch
        end
      end

      def exist?(name, options = nil)
        options = merged_options(options)
        instrument(:exist?, name) do |payload|
          #####patched
          entry = read_entry(namespaced_key(name, options), options)
          entry = nil if entry && entry.tags && !tags_actual?(entry.tags)
          #####end of patch
          if entry && !entry.expired?
            true
          else
            false
          end
        end
      end

      #####patch

      def write_meta(entry, tags)
        t = if tags.is_a?(Array)
              tags.inject({}) do |res, el|
            res[el] = fetch(el, {:namespace => nil}) { 1 }
            res
          end
            end
        entry.tags = t
      end

      def tags_actual?(tags)
        if tags.is_a?(Hash)
          # We're doing dup here because of Dalli makes force_encoding
          # and ActiveSupport returns frozen values, so it raises an exception.
          # Ruby uses copy-on-write technique so it's extremely cheap to make a dup
          # of all tags.keys as far as we don't modify them
          actual_versions = read_multi(*tags.keys.map { |k| k.dup } << {:namespace => nil})
          actual_versions == tags
        else
          false
        end
      end

      def increment_tag(name, options = nil)
        options = merged_options(options)
        entry = read_entry(namespaced_key(name, {:namespace => nil}), options)
        value = entry ? entry.value + 1 : 1
        write_entry(namespaced_key(name, {:namespace => nil}), ActiveSupport::Cache::Entry.new(value), options)
      end
      ######end of patch
    end
  end

  module EntryMethods
    class ActiveSupport::Cache::Entry
      attr_accessor :tags
    end
  end
end
