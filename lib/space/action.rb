module Space
  class Action
    autoload :Parser,      'space/action/parser'
    autoload :Builtin,     'space/action/builtin'
    autoload :Development, 'space/action/development'

    include Builtin, Development

    class << self
      def run(app, line)
        new(app, *Parser.new(app.repos.names).parse(line)).run
      end
    end

    attr_reader :app, :repos, :command, :args

    def initialize(app, repos, command, *args)
      @app     = app
      @repos   = app.repos.select_by_names(repos) if repos
      @command = normalize(command)
      @args    = args
    end

    def run
      if respond_to?(command)
        send(command)
      elsif command
        execute(command)
      end
    end

    private

      def run_scoped(refreshing = false)
        (repos || app.repos.scope).each { |repo| yield repo }
        confirm unless refreshing
      end

      def system(cmd)
        puts cmd
        super
      end

      def confirm
        puts "\n--- hit any key to continue ---\n"
        STDIN.getc
      end

      def normalize(command)
        command = (command || '').strip
        command = 'unscope' if command == '-'
        command = 'scope'   if command.empty?
        command
      end
  end
end
