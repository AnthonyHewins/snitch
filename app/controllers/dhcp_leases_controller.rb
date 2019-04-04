class DhcpLeasesController < ApplicationController
  before_action :set_dhcp_lease, only: [:show, :edit, :update, :destroy]

  # GET /dhcp_leases
  def index
    @dhcp_leases = DhcpLease.all
  end

  # GET /dhcp_leases/1
  def show
  end

  # GET /dhcp_leases/new
  def new
    @dhcp_lease = DhcpLease.new
  end

  # GET /dhcp_leases/1/edit
  def edit
  end

  # POST /dhcp_leases
  def create
    @dhcp_lease = DhcpLease.new(dhcp_lease_params)

    if @dhcp_lease.save
      redirect_to @dhcp_lease, notice: 'Dhcp lease was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /dhcp_leases/1
  def update
    if @dhcp_lease.update(dhcp_lease_params)
      redirect_to @dhcp_lease, notice: 'Dhcp lease was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /dhcp_leases/1
  def destroy
    @dhcp_lease.destroy
    redirect_to dhcp_leases_url, notice: 'Dhcp lease was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dhcp_lease
      @dhcp_lease = DhcpLease.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dhcp_lease_params
      params.require(:dhcp_lease).permit(:inet, :reference, :reference)
    end
end
