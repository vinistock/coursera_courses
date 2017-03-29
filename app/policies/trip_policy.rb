class TripPolicy < ApplicationPolicy
  def create?
    originator?
  end

  def show
    true
  end

  def index?
    true
  end

  def update?
    organizer?
  end

  def destroy?
    organizer_or_admin?
  end

  class Scope < Scope
    def user_roles
      scope.select('Trips.*, r.role_name').joins("left join Roles r on r.mname='Trip' and r.mid=Trips.id and r.user_id #{user_criteria}")
    end

    def resolve
      user_roles
    end
  end
end
