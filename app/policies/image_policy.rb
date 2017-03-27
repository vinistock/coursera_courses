class ImagePolicy < ApplicationPolicy
  def create?
    @user
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
      scope.select('Images.*, r.role_name').joins("left join Roles r on r.mname='Image' and r.mid=Images.id and r.user_id #{user_criteria}")
    end

    def resolve
      user_roles
    end
  end
end
