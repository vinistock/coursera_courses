class TripsController < ApplicationController
  before_action :set_trip, only: [:show, :update, :destroy]
  wrap_parameters :trip, include: %w(name description)
  before_action :authenticate_user!, only: %i(index create update destroy)
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize Trip
    trips = policy_scope(Trip.all)
    @trips = TripPolicy.merge(trips)
  end

  def show
    authorize @trip
    trips = policy_scope(Trip.where(id: @trip.id))
    @trip = TripPolicy.merge(trips).first
  end

  def create
    authorize Trip
    @trip = Trip.new(trip_params)

    User.transaction do
      if @trip.save
        role = current_user.add_role(Role::ORGANIZER, @trip)
        @trip.user_roles << role.role_name
        role.save!
        render :show, status: :created, location: @trip
      else
        render json: { errors: @trip.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @trip

    if @trip.update(trip_params)
      head :no_content
    else
      render json: { errors: @trip.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @trip
    @trip.destroy
    head :no_content
  end

  private

  def set_trip
    @trip = Trip.find(params[:id])
  end

  def trip_params
    params.require(:trip).tap do |p|
      p.require(:name) #throws ActionController::ParameterMissing
    end.permit(:name, :description)
  end
end
