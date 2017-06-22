class JiraTicketsController < ApplicationController
  def new
    @jira_ticket = JiraTicket.new
    @test = Test.find(params[:test])

    respond_to do |format|
      format.js
    end
  end

  def create
    JiraTicket.create(jira_params)
    @test = Test.find(params[:jira_ticket][:test_id])

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def jira_params
    params.require(:jira_ticket).permit(:ticket_number, :ticket_url, :test_id)
  end
end
