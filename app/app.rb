require 'sinatra/base'
require 'sinatra/namespace'
require_relative 'helpers/respond_helper'

class App < Sinatra::Base
  helpers Sinatra::JSON, RespondHelper
  register Sinatra::Namespace

  get('/') { json message: 'Welcome to IP Checker!' }

  namespace '/ips' do
    post                  { json create(params) }
    get                   { json list }
    get('/:id/enable')    { json enable(params[:id]) }
    get('/:id/disable')   { json disable(params[:id]) }
    get('/:id/stats')     { json stats_for(params[:id], params) }
    delete('/:id')        { json delete(params[:id]) }
  end

  not_found do
    json code: 'not_found'
  end

  private

  def create(params)
    result = Ips::CreateService.new.call(params)
    response.status = 201 if result.success?
    respond(result)
  end

  def list
    respond(Ips::ListService.new.call)
  end

  def enable(id)
    respond(Ips::EnableService.new.call(id: id))
  end

  def disable(id)
    respond(Ips::DisableService.new.call(id: id))
  end

  def delete(id)
    result = Ips::DeleteService.new.call(id: id)
    response.status = 204 if result.success?
    respond(result)
  end

  def stats_for(id, params)
    respond(Ips::StatsService.new.call(id: id, from: params['from'], to: params['to']))
  end
end
