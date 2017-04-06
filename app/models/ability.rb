class Ability
  include CanCan::Ability

  # Good resources for cancancan gem used for authorization:
  # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  # https://github.com/CanCanCommunity/cancancan/wiki/Action-Aliases
  # https://github.com/CanCanCommunity/cancancan/wiki/Custom-Actions

  # Super Admin: highest level of admins, can perform any operation on any entity

  #define the actions users can perform based on their role and jobs they have
  def initialize(user)
    # set or retrieve the user object
    user ||= User.new

    #####################
    #GENERAL PERMISSIONS#
    #####################

    # super admins can perform any action on any object, this role is on the user not the jobs the user has
    if user.superadmin?
      can :manage, :all
    # for users that have a job where they are an admin
    elsif user.jobs.any? { |job| job.user_id == user.id && job.role == "admin" }
      #can manage pretty much everything except users
      can :manage, [Organization,JobPosting,JobApplication,JobPostingQuestion,JobPostingAnswer,Job,Interview]
    # for users that have a job where they are an manager
    elsif user.jobs.any? { |job| job.user_id == user.id && job.role == "management" }
      # can manage organizations they have a job under
      can :manage, Organization, id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id)
      # can manage jobs that fall under the organizations they are managers for
      can :manage, Job, id: Job.where(organization_id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id) ).pluck(:id)
      # can manage job postings fall under the jobs they can manage
      can :manage, JobPosting, id: JobPosting.where(job_id: Job.where(organization_id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id) ).pluck(:id)).pluck(:id)
      # can manage any job posting questions that fall under any job posting they can manage
      can :manage, JobPostingQuestion, id: JobPostingQuestion.where(job_posting_id: JobPosting.where(job_id: Job.where(organization_id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id) ).pluck(:id)).pluck(:id) ).pluck(:id)
      # can manage the job applications that fall under any job posting they can manage
      can :manage, JobApplication, id: JobApplication.where(job_posting_id: JobPosting.where(job_id: Job.where(organization_id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id) ).pluck(:id)).pluck(:id)).pluck(:id)
      # can manage the job interviews that fall under any job application they can manage
      can :manage, Interview, id: Interview.where(job_application_id: JobApplication.where(job_posting_id: JobPosting.where(job_id: Job.where(organization_id: Organization.joins(:jobs).where(jobs: { user_id: user.id }).pluck(:id) ).pluck(:id)).pluck(:id)).pluck(:id) ).pluck(:id)

      # users can apply to jobs, hence can perform actions on job applications
      can [:edit,:update, :create, :new, :user, :finalize], [JobApplication, JobPostingAnswer]
      
      can [:edit, :update], User, id: user.id
    # for normal users, they can only read things
    else
      # gneral users can see the organizations they are apart of
      can [:user], Organization
      # users can apply to jobs, hence can perform actions on job applications
      can [:edit,:update, :create, :new, :user, :finalize], [JobApplication, JobPostingAnswer]
      can :read, [Organization, JobPosting, JobPostingQuestion, Job, User, JobApplication]
      can [:edit, :update], User, id: user.id
    end
  end

end
