class Organization < ApplicationRecord
  has_many :jobs, dependent: :destroy
  has_many :users, :through => :jobs
  has_many :job_postings, :foreign_key => :organization_id, dependent: :destroy
  default_scope -> { order(name: :asc)}
  enum type: [:unspecified, :engsoc, :conferences, :design_team]
  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :description, presence: true, length: { minimum: 10, maximum: 4000 }
  accepts_nested_attributes_for :jobs
end