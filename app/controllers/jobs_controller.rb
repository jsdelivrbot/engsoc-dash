class JobsController < ApplicationController

  load_and_authorize_resource

  skip_authorize_resource :only => [:new, :create]

  before_action :set_job, only: [:show, :assign, :destroy, :edit, :update]

  # GET /organizations/:organization_id/jobs/new
  def new
    @job = Job.new
    @organization = Organization.find(params[:organization_id])
  end

  # POST /organizations/:organization_id/jobs/new
  def create
    @job = Job.new(job_params)
    if @job.save
      flash[:success] = "Job Successfully Created!"
      redirect_to assign_job_path(@job.id)
    else
      flash[:danger] = "Could Not Save Job!"
      redirect_to root_path
    end
  end

  # GET /jobs/:id
  def show
    @organization = @job.organization
  end

  # GET /jobs/:id/edit
  def edit
  end

  # PUT /jobs/:id
  def update
    if @job.update_attributes(job_params)
      redirect_to job_path(@job)
    else
      render 'edit'
    end
  end

  # DELETE /jobs/:id
  def destroy
    @job.destroy
    redirect_to organization_path(@job.organization_id)
  end

  # GET /jobs/:id/assign
  def assign
  end

  private

    def job_params
      params.require(:job).permit(:title, :user_id, :organization_id, :description, :role, :job_type)
    end

    def set_job
      @job = Job.find(params[:id])
    end

end
