class JiraTicketsController < ApplicationController
  def create
    @ticket = JiraTicket.create(jira_params)
    @test = Test.find(params[:jira_ticket][:test_id])

		flash[:info] = "Successfully added JIRA ticket #{ @ticket.ticket_number }"
    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def resolve
    @ticket = JiraTicket.find(params[:id])
    @ticket.update(resolved: true)
    @test = @ticket.test

		flash[:info] = "Successfully resolved JIRA ticket #{ @ticket.ticket_number }"
    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def jira_params
    params.require(:jira_ticket).permit(:ticket_number, :ticket_url, :test_id)
  end
end
