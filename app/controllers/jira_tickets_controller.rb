class JiraTicketsController < ApplicationController
  before_action :set_ticket, only: [:update, :destroy]

  def set_ticket
    @ticket = JiraTicket.find(params[:id])
  end

	def index
		@tickets = JiraTicket.edit_all_as_json
	end

  def create
    @ticket = JiraTicket.create(jira_params)
    @ticket.save_data_from_jira
		flash[:info] = "Successfully added JIRA ticket #{ @ticket.number }"

    render json: @ticket
  end

	def update
    if @ticket.update(number: params[:jira_ticket][:number])
			flash[:info] = "Ticket #{ @ticket.number } successfully updated"
      render json: @ticket.edit_as_json
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
	end

  def destroy
    @ticket.destroy
		flash[:info] = "Ticket #{ @ticket.number } successfully removed"
    head :no_content
  end

  def jira_params
    params.require(:jira_ticket).permit(:number, :test_id)
  end
end
