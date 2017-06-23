class JiraTicketsController < ApplicationController
	def index
		@tickets = JiraTicket.edit_all_as_json
	end

  def create
    @ticket = JiraTicket.create(jira_params)
    @test = Test.find(params[:jira_ticket][:test_id])

		flash[:info] = "Successfully added JIRA ticket #{ @ticket.number }"
    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

	def update
		@ticket = JiraTicket.find(params[:id])
		@ticket.number = params[:jira_ticket][:number]
		@ticket.resolved = params[:jira_ticket][:resolved] == "yes"

    if @ticket.save
			flash[:info] = "Ticket #{ @ticket.number } successfully updated"
      render json: @ticket.edit_as_json
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
	end

  def destroy
    @ticket = JiraTicket.find(params[:id])
    @ticket.destroy
		flash[:info] = "Ticket #{ @ticket.number } successfully deleted"
    head :no_content
  end

  def resolve
    @ticket = JiraTicket.find(params[:id])
    @ticket.update(resolved: true)
    @test = @ticket.test

		flash[:info] = "Successfully resolved JIRA ticket #{ @ticket.number }"
    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def jira_params
    params.require(:jira_ticket).permit(:number, :test_id)
  end
end
