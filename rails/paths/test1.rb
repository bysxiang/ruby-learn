require 'set'

module Rails
  module Paths
    class Root < ::Hash
      attr_accessor :path

      def initialize(path)
        raise "Argument should be a String of the physical root path" if path.is_a?(Array)
        @current = nil
        @path = path
        @root = self
        super()
      end

      def []=(path, value)
        value = Path.new(self, path, value) unless value.is_a?(Path)
        super(path, value)
      end

      def add(path, options={})
        with = options[:with] || path
        self[path] = Path.new(self, path, with, options)
      end

      def all_paths
        values.tap { |v| v.uniq! }
      end

      def autoload_once
        filter_by(:autoload_once?)
      end

      def eager_load
        filter_by(:eager_load?)
      end

      def autoload_paths
        filter_by(:autoload?)
      end

      def load_paths
        filter_by(:load_path?)
      end

    protected

      def filter_by(constraint)
        all = []
        all_paths.each do |path|
          if path.send(constraint)
            paths  = path.existent
            paths -= path.children.map { |p| p.send(constraint) ? [] : p.existent }.flatten
            all.concat(paths)
          end
        end
        all.uniq!
        all
      end
    end # .. end of Root

    class Path < Array
      attr_reader :path
      attr_accessor :glob

      def initialize(root, current, *paths)
        options = paths.last.is_a?(::Hash) ? paths.pop : {}
        super(paths.flatten)

        @current  = current
        @root     = root
        @glob     = options[:glob]

        options[:autoload_once] ? autoload_once! : skip_autoload_once!
        options[:eager_load]    ? eager_load!    : skip_eager_load!
        options[:autoload]      ? autoload!      : skip_autoload!
        options[:load_path]     ? load_path!     : skip_load_path!
      end

      def children
        keys = @root.keys.select { |k| k.include?(@current) }
        keys.delete(@current)
        @root.values_at(*keys.sort)
      end

      def first
        expanded.first
      end

      def last
        expanded.last
      end

      %w(autoload_once eager_load autoload load_path).each do |m|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{m}!        # def eager_load!
            @#{m} = true   #   @eager_load = true
          end              # end
                           #
          def skip_#{m}!   # def skip_eager_load!
            @#{m} = false  #   @eager_load = false
          end              # end
                           #
          def #{m}?        # def eager_load?
            @#{m}          #   @eager_load
          end              # end
        RUBY
      end

      # Expands all paths against the root and return all unique values.
      def expanded
        raise "You need to set a path root" unless @root.path
        result = []

        each do |p|
          # 获取绝对路径，p相对于@root.path
          path = File.expand_path(p, @root.path)

          if @glob
            if File.directory? path
              result.concat expand_dir(path, @glob)
            else
              result.concat expand_file(path, @glob)
            end
          else
            result << path
          end
        end

        result.uniq!
        result
      end

      # Returns all expanded paths but only if they exist in the filesystem.
      def existent
        expanded.select { |f| File.exists?(f) }
      end

      def existent_directories
        expanded.select { |d| File.directory?(d) }
      end

      alias to_a expanded

      private
      def expand_file(path, glob)
        Dir[File.join(path, glob)].sort
      end

      def expand_dir(path, glob)
        Dir.chdir(path) do
          Dir.glob(@glob).map { |file| File.join path, file }.sort
        end
      end
    end # .. end of Path
  end
end

root = Rails::Paths::Root.new("/media/sf_work/ruby-learn")
root.add("rails/paths")
root.add("rails/paths/test1")

path = root["rails/paths"]

p path.children

p path
p path.class