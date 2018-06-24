module Daru
  module View
    class PlotList
      attr_reader :charts, :data
      attr_accessor :adapter
      class << self
        # class method
        #
        # @example
        #
        # Daru::View::PlotList.adapter = :googlecharts
        #
        # Plotting libraries are nyaplot, highcharts, googlecharts
        def adapter=(adapter)
          require "daru/view/adapters/#{adapter}"
          # rubocop:disable Style/ClassVars
          @@adapter = Daru::View::Adapter.const_get(
            adapter.to_s.capitalize + 'Adapter'
          )
          # rubocop:enable Style/ClassVars
        end
      end

      # @example
      #
      # Daru::View.plotting_library = :googlecharts
      #
      # df = Daru::DataFrame.new({a:['A', 'B', 'C', 'D', 'E'], b:[10,20,30,40,50]})
      # plot1 = Daru::View::Plot.new(
      #   df, type: :bar, x: :a, y: :b
      # )
      # plot2 = Daru::View::Plot.new(
      #   df, type: :column, x: :a, y: :b
      # )
      # plots = Daru::View::PlotList.new([plot1, plot2])
      #
      def initialize(data=[])
        @data = data
        @charts = plot_data(data)
      end

      # instance method
      def adapter=(adapter)
        require "daru/view/adapters/#{adapter}"
        @adapter = Daru::View::Adapter.const_get(
          adapter.to_s.capitalize + 'Adapter'
        )
      end

      # display in IRuby notebook
      def show_in_iruby
        @adapter.show_in_iruby @charts
      end

      # dependent js file, to include in head tag using the plot object.
      # @example:
      # plot_obj.init_script
      #
      # Note :
      # User can directly put the dependent script file into the head tag
      # using `Daru::View.dependent_script(:highcharts), by default it loads
      # Nyaplot JS files.
      #
      def init_script
        @adapter.init_script
      end

      # generat html code, to include in body tag
      def div
        @adapter.generate_body(@charts)
      end

      # generat html file
      def export_html_file(path='./plot.html')
        @adapter.export_html_file(@charts, path)
      end

      # load the corresponding JS files in IRuby notebook.
      # This is done automatically when plotting library is set using
      # Daru::View.plotting_library = :new_library
      def init_iruby
        @adapter.init_iruby
      end

      private

      def plot_data(data)
        # class variable @@aapter is used in instance variable @adapter.
        # so in each object `adapter` variable can be accessed.
        @adapter ||= @@adapter
        @adapter.init(data)
      end
    end
  end
end
