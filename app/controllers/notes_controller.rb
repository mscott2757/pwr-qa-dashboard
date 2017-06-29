class NotesController < ApplicationController
  def create
    @note = Note.new
    @note.author = params[:note][:author]
    @note.body = params[:note][:body]

    if @note.save
      render json: @note
    else
      render json: @note.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    head :no_content
  end
end
