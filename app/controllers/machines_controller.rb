class MachinesController < ApplicationController
  def show
  end

  def index
    @machines = Machine.all
  end
end
