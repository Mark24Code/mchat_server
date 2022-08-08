module Config
  # prepare
  # add root to search path
  require 'pathname'
  ROOT_DIR = Pathname.new('.') # 可以获得执行时候的目录
  $LOAD_PATH.unshift(ROOT_DIR) unless $LOAD_PATH.include?(ROOT_DIR)

  class << self
    def loads(load_paths)
      if load_paths.instance_of?(String)
        load_paths = [load_paths]
      end
      load_paths = load_paths.map { |s| "./#{s}" }
      ignores = []
      load_paths -= ignores

      load_paths.each do |setup_step|
        target = (ROOT_DIR.realpath + setup_step)
        if target.extname == '.rb'
          require target
        else
          # TODO 这在无差别载入其实会有问题
          target.glob("./**/*.rb").sort.uniq.each do |f|
            require f
          end
        end
      end
    end

    def load_tasks
      self.loads(['config/tasks'])
    end
  end
end

require_relative './base/base_setting'
require_relative './setting'
require_relative './log_tracker'
require_relative './redis_db'

