require 'set'
require 'thread'
require 'pathname'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
require 'pry-nav'
# require 'active_support/core_ext/module/aliasing'
# require 'active_support/core_ext/module/attribute_accessors'
# require 'active_support/core_ext/module/introspection'
# require 'active_support/core_ext/module/anonymous'
# require 'active_support/core_ext/module/qualified_const'
# require 'active_support/core_ext/object/blank'
# require 'active_support/core_ext/load_error'
# require 'active_support/core_ext/name_error'
# require 'active_support/core_ext/string/starts_ends_with'
# require 'active_support/inflector'

module ActiveSupport #:nodoc:
  module Dependencies #:nodoc:
    extend self

    # Should we turn on Ruby warnings on the first load of dependent files?
    # 是否在首次加载时打开ruby警告
    mattr_accessor :warnings_on_first_load
    self.warnings_on_first_load = false

    # All files ever loaded.
    # 所有加载过的文件，
    mattr_accessor :history
    self.history = Set.new

    # All files currently loaded.
    # 当前已加载文件
    mattr_accessor :loaded
    self.loaded = Set.new

    # Should we load files or require them?
    # 应该load文件还是require文件
    mattr_accessor :mechanism
    self.mechanism = ENV['NO_RELOAD'] ? :require : :load

    # The set of directories from which we may automatically load files. Files
    # under these directories will be reloaded on each request in development mode,
    # unless the directory also appears in autoload_once_paths.
    # 自动加载目录，在开发模式下
    # 重新加载每个请求。
    mattr_accessor :autoload_paths
    self.autoload_paths = []

    # The set of directories from which automatically loaded constants are loaded
    # only once. All directories in this set must also be present in +autoload_paths+.
    # 自动加载，只加载一次的常量路径集合
    # 此集合中的所有目录必须存在于+autoload_paths+中。
    mattr_accessor :autoload_once_paths
    self.autoload_once_paths = []

    # An array of qualified constant names that have been loaded. Adding a name to
    # this array will cause it to be unloaded the next time Dependencies are cleared.
    # 已加载的一组合格的常量名。当添加一个常量名，将导致下一次清除依赖项时被卸载
    mattr_accessor :autoloaded_constants
    self.autoloaded_constants = []

    # An array of constant names that need to be unloaded on every request. Used
    # to allow arbitrary constants to be marked for unloading.
    # 一组需要在每个请求上卸载的常量名。
    # 使用它，允许任何常量被标记为卸载。
    mattr_accessor :explicitly_unloadable_constants
    self.explicitly_unloadable_constants = []

    # The logger is used for generating information on the action run-time (including benchmarking) if available.
    # Can be set to nil for no logging. Compatible with both Ruby's own Logger and Log4r loggers.
    mattr_accessor :logger

    # Set to true to enable logging of const_missing and file loads
    # 设为true，日志记录常量和文件丢失情况
    mattr_accessor :log_activity
    self.log_activity = false

    # The WatchStack keeps a stack of the modules being watched as files are loaded.
    # If a file in the process of being loaded (parent.rb) triggers the load of
    # another file (child.rb) the stack will ensure that child.rb handles the new
    # constants.
    
    # If child.rb is being autoloaded, its constants will be added to
    # autoloaded_constants. If it was being `require`d, they will be discarded.
    
    # This is handled by walking back up the watch stack and adding the constants
    # found by child.rb to the list of original constants in parent.rb
    class WatchStack
      include Enumerable

      # @watching is a stack of lists of constants being watched. For instance,
      # if parent.rb is autoloaded, the stack will look like [[Object]]. If parent.rb
      # then requires namespace/child.rb, the stack will look like [[Object], [Namespace]].

      def initialize
        @watching = []
        @stack = Hash.new { |h,k| h[k] = [] }
      end

      def each(&block)
        @stack.each(&block)
      end

      def watching?
        !@watching.empty?
      end

      # return a list of new constants found since the last call to watch_namespaces
      def new_constants
        constants = []

        # Grab the list of namespaces that we're looking for new constants under
        # 获取我们正在寻找的新常量的命名空间列表
        @watching.last.each do |namespace|
          # Retrieve the constants that were present under the namespace when watch_namespaces
          # was originally called
          # 获得命名空间对应的常量数组，获取最后一个
          original_constants = @stack[namespace].last

          if Dependencies.qualified_const_defined?(namespace)
            mod = Inflector.constantize(namespace)

            # Get a list of the constants that were added
            # 新加入的常量列表
            new_constants = mod.local_constant_names - original_constants

            # self[namespace] returns an Array of the constants that are being evaluated
            # for that namespace. For instance, if parent.rb requires child.rb, the first
            # element of self[Object] will be an Array of the constants that were present
            # before parent.rb was required. The second element will be an Array of the
            # constants that were present before child.rb was required.
            # self[namespace] 返回当前命名空间被评估的常量数组。例如, 如果parent.rb require child.rb
            # 第一个元素是parent.rb的常量数组，第二个元素是child.rb的常量数组。
            # namespace_constants是namespace对应的数组
            @stack[namespace].each do |namespace_constants|
              namespace_constants.concat(new_constants)
            end

            # Normalize the list of new constants, and add them to the list we will return
            # 去除"Object"命名空间，并以::连接常量
            new_constants.each do |suffix|
              constants << ([namespace, suffix] - ["Object"]).join("::")
            end
          end # if .. end
        end
        constants
      ensure
        # A call to new_constants is always called after a call to watch_namespaces
        # new_constants总是在调用watch_namespaces之后调用
        # 因为watch_namespaces总是添加监视常量
        pop_modules(@watching.pop)
      end

      # Add a set of modules to the watch stack, remembering the initial constants
      # 将一组模块添加到监视堆栈中，记住初始常量
      # 监视一组命名空间中的模块，@watching记录模块名称
      # @stack[module_name] 记录模块内原始常量, @stack[module_name]每个值时一个数组
      def watch_namespaces(namespaces)
        watching = []
        namespaces.map do |namespace|
          module_name = Dependencies.to_constant_name(namespace)
          original_constants = Dependencies.qualified_const_defined?(module_name) ?
            Inflector.constantize(module_name).local_constant_names : []

          watching << module_name
          @stack[module_name] << original_constants
        end
        @watching << watching
      end

      private
      def pop_modules(modules)
        modules.each { |mod| @stack[mod].pop }
      end
    end # WatchStack .. end

    # An internal stack used to record which constants are loaded by any block.
    # 用于记录任何块加载哪些常量的内部堆栈
    mattr_accessor :constant_watch_stack
    self.constant_watch_stack = WatchStack.new

    # Module includes this module
    # 模块include此模块
    # 它将const_missing保存在@_const_missing实例变量中,并将方法移除
    # 此模块重载了const_missing方法
    module ModuleConstMissing #:nodoc:
      # 移除此模块的const_missing，并将这个方法复制给+@_const_missing+
      # @_const_missing记录原始方法
      def self.append_features(base)
        base.class_eval do
          # Emulate #exclude via an ivar
          return if defined?(@_const_missing) && @_const_missing
          @_const_missing = instance_method(:const_missing)
          remove_method(:const_missing)
        end
        super
      end

      # 恢复原base模块的const_missing方法
      def self.exclude_from(base)
        base.class_eval do
          define_method :const_missing, @_const_missing
          @_const_missing = nil
        end
      end

      # Use const_missing to autoload associations so we don't have to
      # require_association when using single-table inheritance.
      # 重载原const_missing方法
      # 使用const_missing自动加载关联，使我们使用单表继承时不用require_association
      # 依次通过load_missing_constant来加载常量，如果不存在，
      # 从父模块中加载常量
      def const_missing(const_name, nesting = nil)
        klass_name = name.presence || "Object"

        # 生成模块嵌套数组
        unless nesting
          # We'll assume that the nesting of Foo::Bar is ["Foo::Bar", "Foo"]
          # even though it might not be, such as in the case of
          # class Foo::Bar; Baz; end
          nesting = []
          klass_name.to_s.scan(/::|$/) { nesting.unshift $` }
        end

        # If there are multiple levels of nesting to search under, the top
        # level is the one we want to report as the lookup fail.
        # 如果有多层嵌套，当查找失败，我们希望报告
        error = nil

        nesting.each do |namespace|
          begin
            return Dependencies.load_missing_constant Inflector.constantize(namespace), const_name
          rescue NoMethodError then raise
          rescue NameError => e
            error ||= e
          end
        end

        # Raise the first error for this set. If this const_missing came from an
        # earlier const_missing, this will result in the real error bubbling
        # all the way up
        raise error
      end

      def unloadable(const_desc = self)
        super(const_desc)
      end
    end # ModuleConstMissing .. end

    # Object includes this module
    # Object include此模块
    # 它重载了从Kernel继承来的load方法
    # 它可以恢复,通过exclude_from方法
    module Loadable #:nodoc:
      # 恢复base.load为系统默认的load方法
      def self.exclude_from(base)
        base.class_eval { define_method(:load, Kernel.instance_method(:load)) }
      end

      def require_or_load(file_name)
        Dependencies.require_or_load(file_name)
      end

      def require_dependency(file_name, message = "No such file to load -- %s")
        unless file_name.is_a?(String)
          raise ArgumentError, "the file name must be a String -- you passed #{file_name.inspect}"
        end

        Dependencies.depend_on(file_name, false, message)
      end

      def require_association(file_name)
        Dependencies.associate_with(file_name)
      end

      def load_dependency(file)
        if Dependencies.load? && ActiveSupport::Dependencies.constant_watch_stack.watching?
          Dependencies.new_constants_in(Object) { yield }
        else
          yield
        end
      rescue Exception => exception  # errors from loading file
        exception.blame_file! file
        raise
      end

      # 重载load方法
      def load(file, wrap = false)
        result = false
        load_dependency(file) { result = super }
        result
      end

      def require(file)
        result = false
        load_dependency(file) { result = super }
        result
      end

      # Mark the given constant as unloadable. Unloadable constants are removed each
      # time dependencies are cleared.
      #
      # Note that marking a constant for unloading need only be done once. Setup
      # or init scripts may list each unloadable constant that may need unloading;
      # each constant will be removed for every subsequent clear, as opposed to for
      # the first clear.
      #
      # The provided constant descriptor may be a (non-anonymous) module or class,
      # or a qualified constant name as a string or symbol.
      #
      # Returns true if the constant was not previously marked for unloading, false
      # otherwise.
      def unloadable(const_desc)
        Dependencies.mark_for_unload const_desc
      end
    end # .. end Loable

    # Exception file-blaming
    # 记录异常相关的文件信息
    module Blamable #:nodoc:
      def blame_file!(file)
        (@blamed_files ||= []).unshift file
      end

      def blamed_files
        @blamed_files ||= []
      end

      def describe_blame
        return nil if blamed_files.empty?
        "This error occurred while loading the following files:\n   #{blamed_files.join "\n   "}"
      end

      def copy_blame!(exc)
        @blamed_files = exc.blamed_files.clone
        self
      end
    end # .. end Blamable

    def hook!
      Object.class_eval { include Loadable }
      Module.class_eval { include ModuleConstMissing }
      Exception.class_eval { include Blamable }
      true
    end

    def unhook!
      ModuleConstMissing.exclude_from(Module)
      Loadable.exclude_from(Object)
      true
    end

    def load?
      mechanism == :load
    end

    def depend_on(file_name, swallow_load_errors = false, message = "No such file to load -- %s.rb")
      # 根据file_name，搜索autoload_path中是否包含此文件(而非目录)
      # 如果不包含，尝试从当前file_name
      path = search_for_file(file_name)
      require_or_load(path || file_name)
    rescue LoadError => load_error
      unless swallow_load_errors
        file_name = load_error.message[/ -- (.*?)(\.rb)?$/, 1]
        if file_name
          raise LoadError.new(message % file_name).copy_blame!(load_error)
        else
          raise
        end
      end
    end

    def associate_with(file_name)
      depend_on(file_name, true)
    end

    def clear
      log_call
      loaded.clear
      remove_unloadable_constants!
    end

    # 加载一个文件
    # 通过require或load
    def require_or_load(file_name, const_path = nil)
      log_call file_name, const_path

      file_name = $1 if file_name =~ /^(.*)\.rb$/
      expanded = File.expand_path(file_name)
      return if loaded.include?(expanded)

      # Record that we've seen this file *before* loading it to avoid an
      # infinite loop with mutual dependencies.
      loaded << expanded

      begin
        if load?
          log "loading #{file_name}"

          # Enable warnings if this file has not been loaded before and
          # warnings_on_first_load is set.
          load_args = ["#{file_name}.rb"]
          load_args << const_path unless const_path.nil?

          if !warnings_on_first_load or history.include?(expanded)
            result = load_file(*load_args)
          else
            # bug 
            # enable_warnings { result = load_file(*load_args) }
            result = enable_warnings { load_file(*load_args) }
          end
        else
          log "requiring #{file_name}"
          result = require file_name
        end
      rescue Exception
        loaded.delete expanded
        raise
      end

      # Record history *after* loading so first load gets warnings.
      history << expanded
      return result
    end

    # Is the provided constant path defined?
    # 检测常量是否已定义
    if Module.method(:const_defined?).arity == 1
      def qualified_const_defined?(path)
        Object.qualified_const_defined?(path.sub(/^::/, ''))
      end
    else
      def qualified_const_defined?(path)
        Object.qualified_const_defined?(path.sub(/^::/, ''), false)
      end
    end

    # 模块中是否定义了常量?
    # 不包括继承来的常量
    if Module.method(:const_defined?).arity == 1
      # Does this module define this constant?
      # Wrapper to accommodate changing Module#const_defined? in Ruby 1.9
      def local_const_defined?(mod, const)
        mod.const_defined?(const)
      end
    else
      def local_const_defined?(mod, const) #:nodoc:
        mod.const_defined?(const, false)
      end
    end

    # Given +path+, a filesystem path to a ruby file, return an array of constant
    # paths which would cause Dependencies to attempt to load this file.
    # 给定一个+path+，在一个自动加载路径组里查找，是否path属于它们的子路径
    # 如果属于的化，将path转换为常量字符串
    def loadable_constants_for_path(path, bases = autoload_paths)
      path = $1 if path =~ /\A(.*)\.rb\Z/
      expanded_path = File.expand_path(path)
      paths = []

      bases.each do |root|
        expanded_root = File.expand_path(root)

        if %r{\A#{Regexp.escape(expanded_root)}(/|\\)} =~ expanded_path
          nesting = expanded_path[(expanded_root.size)..-1]
          nesting = nesting[1..-1] if nesting && nesting[0] == ?/

          if nesting.present?
            paths << nesting.camelize
          end
        end
      end

      paths.uniq!
      paths
    end

    # Search for a file in autoload_paths matching the provided suffix.
    # 从autoload_paths中搜索path_suffix,
    # path_suffix： action_record/base
    # 如果找到的是一个文件，返回文件完整路径
    # 否则，返回nil
    def search_for_file(path_suffix)
      # 将最后后缀名替换为.rb
      path_suffix = path_suffix.sub(/(\.rb)?$/, ".rb")

      path = nil
      autoload_paths.each do |root|
        _path = File.join(root, path_suffix)
        if File.file?(_path)
          path = _path
          break
        end
        
      end

      return path
    end

    # Does the provided path_suffix correspond to an autoloadable module?
    # Instead of returning a boolean, the autoload base for this module is returned.
    # 是否是自动加载里的一个模块
    def autoloadable_module?(path_suffix)
      path = nil
      autoload_paths.each do |load_path|
        if File.directory? File.join(load_path, path_suffix)
          path = load_path

          break
        end
      end

      return path
    end

    # autoload_once_paths路径中是否包含+path+
    def load_once_path?(path)
      # to_s works around a ruby1.9 issue where #starts_with?(Pathname) will always return false
      autoload_once_paths.any? { |base| path.starts_with? base.to_s }
    end

    # Attempt to autoload the provided module name by searching for a directory
    # matching the expected path suffix. If found, the module is created and assigned
    # to +into+'s constants with the name +const_name+. Provided that the directory
    # was loaded from a reloadable base path, it is added to the set of constants
    # that are to be unloaded.
    # 向into中加载一个模块常量
    def autoload_module!(into, const_name, qualified_name, path_suffix)
      base_path = autoloadable_module?(path_suffix)

      unless base_path
        return nil
      end

      mod = Module.new
      into.const_set const_name, mod

      unless autoload_once_paths.include?(base_path)
        autoloaded_constants << qualified_name
      end


       
      return mod
    end

    # Load the file at the provided path. +const_paths+ is a set of qualified
    # constant names. When loading the file, Dependencies will watch for the
    # addition of these constants. Each that is defined will be marked as
    # autoloaded, and will be removed when Dependencies.clear is next called.
    #
    # If the second parameter is left off, then Dependencies will construct a set
    # of names that the file at +path+ may define. See
    # +loadable_constants_for_path+ for more details.
    def load_file(path, const_paths = loadable_constants_for_path(path))
      log_call path, const_paths
      if const_paths.is_a?(Array) == false
        const_paths = [const_paths].compact
      end
      
      parent_paths = const_paths.collect { |const_path| /(.*)::[^:]+\Z/ =~ const_path ? $1 : :Object }

      # 之所以要传递parent_paths给new_constants_in
      # 是否因为在父模块/类中才可以访问到这些新加载的常量
      # 通过load path，返回新加入的常量
      result = nil
      newly_defined_paths = new_constants_in(*parent_paths) do
        result = Kernel.load path
      end

      if load_once_path?(path) == false
        autoloaded_constants.concat(newly_defined_paths)
      end
      autoloaded_constants.uniq!

      if newly_defined_paths.empty?() == false
        log "loading #{path} defined #{newly_defined_paths * ', '}"
      end

      return result
    end

    # Return the constant path for the provided parent and constant name.
    # 返回常量路径
    # 返回常量名称(字符串)-类似Java::App这样的形式
    def qualified_name_for(mod, name)
      mod_name = to_constant_name mod
      mod_name == "Object" ? name.to_s : "#{mod_name}::#{name}"
    end

    # Load the constant named +const_name+ which is missing from +from_mod+. If
    # it is not possible to load the constant into from_mod, try its parent module
    # using const_missing.
    # 尝试从from_mod加载常量(可能是文件或目录)
    # 如果都失败，且所有父结构都没有常量的化，
    # 调用parent.const_missing()
    def load_missing_constant(from_mod, const_name)
      log_call from_mod, const_name

      unless qualified_const_defined?(from_mod.name) && Inflector.constantize(from_mod.name).equal?(from_mod)
        raise ArgumentError, "A copy of #{from_mod} has been removed from the module tree but is still active!"
      end

      raise NameError, "#{from_mod} is not missing constant #{const_name}!" if local_const_defined?(from_mod, const_name)

      qualified_name = qualified_name_for from_mod, const_name
      path_suffix = qualified_name.underscore # 以下划线分隔的常量字符串,小写形式 -> acitve_record/base

      file_path = search_for_file(path_suffix)

      puts "输出file_path, #{file_path}"

      # 文件
      if file_path && ! loaded.include?(File.expand_path(file_path).sub(/\.rb\z/, '')) # We found a matching file to load
        require_or_load file_path

        unless local_const_defined?(from_mod, const_name)
          raise LoadError, "Expected #{file_path} to define #{qualified_name}"
        end
         
        return from_mod.const_get(const_name)
      else # 目录
        mod = autoload_module!(from_mod, const_name, qualified_name, path_suffix)
        puts "输出mod, #{mod}"
        if mod
          return mod
        elsif (parent = from_mod.parent) && parent != from_mod &&
            ! from_mod.parents.any? { |p| local_const_defined?(p, const_name) }

          # If our parents do not have a constant named +const_name+ then we are free
          # to attempt to load upwards. If they do have such a constant, then this
          # const_missing must be due to from_mod::const_name, which should not
          # return constants from from_mod's parents.
          begin
            return parent.const_missing(const_name)
          rescue NameError => e
            raise unless e.missing_name? qualified_name_for(parent, const_name)
          end
        end
      end

      raise NameError,
            "uninitialized constant #{qualified_name}",
            caller.reject {|l| l.starts_with? __FILE__ }
    end

    # Remove the constants that have been autoloaded, and those that have been
    # marked for unloading. Before each constant is removed a callback is sent
    # to its class/module if it implements +before_remove_const+.
    #
    # The callback implementation should be restricted to cleaning up caches, etc.
    # as the environment will be in an inconsistent state, e.g. other constants
    # may have already been unloaded and not accessible.
    # 移除autoload_constants中的常量, 清空autoloaded_constants
    # 移除被标记为卸载的常量
    def remove_unloadable_constants!
      autoloaded_constants.each { |const| remove_constant const }
      autoloaded_constants.clear
      Reference.clear!
      explicitly_unloadable_constants.each { |const| remove_constant const }
    end

    # 类缓存类
    class ClassCache
      def initialize
        @store = Hash.new
      end

      def empty?
        @store.empty?
      end

      def key?(key)
        @store.key?(key)
      end

      def get(key)
        key = key.name if key.respond_to?(:name)
        @store[key] ||= Inflector.constantize(key)
      end
      alias :[] :get

      def safe_get(key)
        key = key.name if key.respond_to?(:name)
        @store[key] || begin
          klass = Inflector.safe_constantize(key)
          @store[key] = klass
        end
      end

      def store(klass)
        return self unless klass.respond_to?(:name)
        raise(ArgumentError, 'anonymous classes cannot be cached') if klass.name.empty?
        @store[klass.name] = klass
        self
      end

      def clear!
        @store.clear
      end
    end # .. end ClassCache

    Reference = ClassCache.new

    # Store a reference to a class +klass+.
    # 存储一个类的引用
    def reference(klass)
      Reference.store klass
    end

    # Get the reference for class named +name+.
    # Raises an exception if referenced class does not exist.
    # 根据名称，获取一个类引用
    def constantize(name)
      Reference.get(name)
    end

    # Get the reference for class named +name+ if one exists.
    # Otherwise returns nil.
    # 根据名称，获取一个类引用，如果不存在，返回nil
    def safe_constantize(name)
      Reference.safe_get(name)
    end

    # Determine if the given constant has been automatically loaded.
    # 常量是否已被自动加载
    def autoloaded?(desc)
      # No name => anonymous module.
      return false if desc.is_a?(Module) && desc.anonymous?
      name = to_constant_name desc
      return false unless qualified_const_defined? name
      return autoloaded_constants.include?(name)
    end

    # Will the provided constant descriptor be unloaded?
    # 提供的常量描述符+const_desc+是否将被卸载
    def will_unload?(const_desc)
      autoloaded?(const_desc) ||
        explicitly_unloadable_constants.include?(to_constant_name(const_desc))
    end

    # Mark the provided constant name for unloading. This constant will be
    # unloaded on each request, not just the next one.
    # 标记提供的常量名进行卸载，这个是在每个请求上卸载，而不仅仅是下个请求。
    def mark_for_unload(const_desc)
      name = to_constant_name const_desc
      if explicitly_unloadable_constants.include? name
        return false
      else
        explicitly_unloadable_constants << name
        return true
      end
    end

    # Run the provided block and detect the new constants that were loaded during
    # its execution. Constants may only be regarded as 'new' once -- so if the
    # block calls +new_constants_in+ again, then the constants defined within the
    # inner call will not be reported in this one.
    
    # If the provided block does not run to completion, and instead raises an
    # exception, any new constants are regarded as being only partially defined
    # and will be removed immediately.
    # 运行提供的块并检测在其中加载的新常量
    # 如果块发生异常，删除已引入的部分常量
    # 如果成功，返回加载的新常量数组，否则返回空数组
    def new_constants_in(*descs)
      log_call(*descs)

      constant_watch_stack.watch_namespaces(descs)
      aborting = true

      new_constants = []

      begin
        # 
        yield # Now yield to the code that is to define new constants.
        aborting = false
      ensure
        new_constants = constant_watch_stack.new_constants

        log "New constants: #{new_constants * ', '}"

        if aborting
          log "Error during loading, removing partially loaded constants "
          new_constants.each {|c| remove_constant(c) }.clear
        end
      end

      return new_constants
    end

    # Convert the provided const desc to a qualified constant name (as a string).
    # A module, class, symbol, or string may be provided.
    # 将desc转换为一个限定的常量名，返回一个字符串
    # 以::开头的，将::替换为空字符串
    def to_constant_name(desc) #:nodoc:
      case desc
        when String then desc.sub(/^::/, '')
        when Symbol then desc.to_s
        when Module
          desc.name.presence ||
            raise(ArgumentError, "Anonymous modules have no name to be referenced by")
        else raise TypeError, "Not a valid constant descriptor: #{desc.inspect}"
      end
    end

    # 移除一个常量
    def remove_constant(const) #:nodoc:
      return false unless qualified_const_defined? const

      # Normalize ::Foo, Foo, Object::Foo, and ::Object::Foo to Object::Foo
      # 类似::Foo, Foo, 转换为Object::Foo， ::Object::Foo转换为Object::Foo
      names = const.to_s.sub(/^::(Object)?/, 'Object::').split("::")
      to_remove = names.pop
      parent = Inflector.constantize(names * '::')

      log "removing constant #{const}"
      constantized = constantize(const)
      constantized.before_remove_const if constantized.respond_to?(:before_remove_const)
      parent.instance_eval { remove_const to_remove }

      return true
    end

    protected
      def log_call(*args)
        if log_activity?
          arg_str = args.collect { |arg| arg.inspect } * ', '
          /in `([a-z_\?\!]+)'/ =~ caller(1).first
          selector = $1 || '<unknown>'
          log "called #{selector}(#{arg_str})"
        end
      end

      def log(msg)
        logger.debug "Dependencies: #{msg}" if log_activity?
      end

      def log_activity?
        logger && log_activity
      end
  end
end

ActiveSupport::Dependencies.hook!


path = File.expand_path(".")

ActiveSupport::Dependencies.autoload_paths << path
ActiveSupport::Dependencies.autoload_once_paths << path

a = Abc

p ActiveSupport::Dependencies.autoloaded_constants

p Object.local_constant_names

ActiveSupport::Dependencies.remove_unloadable_constants! #清除已加载常量
p ActiveSupport::Dependencies
b = Abc
