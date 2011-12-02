require 'sinatra/base'
require 'fudge/queue'
require 'fudge/models/project'
require 'haml'

module Fudge
  module Application
    class Application < Sinatra::Base
      set :root, File.dirname(__FILE__)

      def initialize
        super
        @queue = Fudge::Queue.new
        Thread.new { @queue.start! }
      end

      get '/' do
        @projects = Fudge::Models::Project.all
        haml :index
      end

      get '/projects/:name' do
        @project = Fudge::Models::Project.load_by_name params[:name]
        haml :project
      end

      post '/projects/:name' do
        @project = Fudge::Models::Project.load_by_name params[:name]
        @queue << @project.next_build
        redirect '/projects/' + params[:name]
      end

      get '/projects/:name/builds/:number' do
        @project = Fudge::Models::Project.load_by_name params[:name]
        @build = @project.builds.select {|x| x.number.to_s == params[:number]}.first

        haml :build
      end
    end
  end
end
